unit actprint;

{$mode objfpc}{$H+}

interface

uses
  classes,
  sqldb,
  BrookAction,
  BaseAction,
  BrookLogger,
  fpjson,
  jsonparser,
  sysutils,
  process,
  Math;

type
  { TPrint }

  TPrint = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TPrint.Post;
var
  lProcess: TProcess;
  lErrStream: TMemoryStream;
  lReadCount: Integer;
  lCharBuffer: array[0..511] of char;
  lOutput: TMemoryStream;
  lStudy: TJsonObject;
  lParser: TJSONParser;

begin
  lOutput := TMemoryStream.Create;
  lErrStream := TMemoryStream.Create;
  lProcess := TProcess.Create(nil);
  try
    lParser := TJSONParser.Create(HttpRequest.Content);
    lStudy := TJsonObject(lParser.Parse);
    lProcess.Environment.Add('PYTHONIOENCODING=utf-8');
    if FileExists('/usr/bin/python3') then
      lProcess.Executable := '/usr/bin/python3'
    else
      lProcess.Executable := '/usr/bin/python';

    lProcess.Parameters.Add( ExtractFilePath(ParamStr(0)) + 'crear_documento.py' );
    lProcess.Options := [poUsePipes];
    lProcess.Execute;

    // el contenido es JSON
    //BrookLog.Debug(lStudy.AsJSON);
    lProcess.Input.Write(  lStudy.AsJSON[1], Length(lStudy.AsJSON));
    lProcess.CloseInput;

    while lProcess.Running or (lProcess.Output.NumBytesAvailable > 0) do
    begin
      while lProcess.Stderr.NumBytesAvailable > 0 do
      begin
        lReadCount := Min(512, lProcess.Stderr.NumBytesAvailable);
        lProcess.Stderr.Read(lCharBuffer, lReadCount);
        lErrStream.Write(lCharBuffer, lReadCount);
      end;
      while lProcess.Output.NumBytesAvailable > 0 do
      begin
        lReadCount := Min(512, lProcess.Output.NumBytesAvailable);
        lProcess.Output.Read(lCharBuffer, lReadCount);
        lOutput.Write(lCharBuffer, lReadCount);
      end;
    end;

    if (lErrStream.Size > 0) then
    begin
     // lErrStream.SaveToFile('/tmp/salida.err');
     // Write('Error');
     // exit;
    end;

    lOutput.Position:= 0;
    HttpResponse.ContentStream := lOutput;
    HttpResponse.ContentStream.Position:= 0;
    HttpResponse.ContentType := 'application/pdf';
    HttpResponse.CustomHeaders.Values['Content-Disposition'] :=
      'attachment; filename=' + IntToStr(lStudy.Integers['IdStudy']) + '.pdf';
    HttpResponse.ContentLength := HttpResponse.ContentStream.Size;
    HttpResponse.SendContent;

  finally
    lParser.Free;
    lStudy.Free;
    lProcess.Free;
    lOutput.Free;
    lErrStream.Free;
  end;
end;

initialization
  TPrint.Register('/print');

end.
