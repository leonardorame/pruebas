unit actprint;

{$mode objfpc}{$H+}

interface

uses
  classes,
  sqldb,
  BrookAction,
  BaseAction,
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
  lStr: TStringList;
  lErrStream: TMemoryStream;
  lReadCount: Integer;
  lCharBuffer: array[0..511] of char;
  lOutput: TMemoryStream;
  lIdStudy: string;

begin
  lStr := TStringList.Create;
  lOutput := TMemoryStream.Create;
  lErrStream := TMemoryStream.Create;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := '/usr/bin/python3';
    lProcess.Parameters.Add( ExtractFilePath(ParamStr(0)) + 'crear_documento.py' );
    lProcess.Options := [poUsePipes];
    lProcess.Execute;

    lIdStudy := TheRequest.ContentFields.Values['IdStudy'];
    lStr.Text := TheRequest.ContentFields.Values['Report'] + LineEnding;

    lProcess.Input.Write(lStr.Text[1], Length(lStr.Text));
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

    lOutput.Position:= 0;
    TheResponse.ContentStream := lOutput;
    TheResponse.ContentStream.Position:= 0;
    TheResponse.ContentType := 'application/pdf';
    TheResponse.CustomHeaders.Values['Content-Disposition'] :=
      'attachment; filename=' + lIdStudy + '.pdf';
    TheResponse.ContentLength := TheResponse.ContentStream.Size;
    TheResponse.SendContent;

  finally
    lStr.Free;
    lProcess.Free;
    lOutput.Free;
    lErrStream.Free;
  end;
end;

initialization
  TPrint.Register('/print');

end.
