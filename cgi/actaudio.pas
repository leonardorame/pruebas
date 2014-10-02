unit actaudio;

{$mode objfpc}{$H+}


interface

uses
  Classes,BrookAction, BrookConsts, BrookUtils, SysUtils,
  BrookLogger,
  Math,
  process,
  strutils,
  dmdatabase;

type

  { TActAudio }

  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
    procedure Get; override;
  end;


implementation

procedure TActAudio.Post;
var
  lWav: TMemoryStream;
  lIdStudyProcedure: string;
begin
  lWav := TMemoryStream.Create;
  try
    lWav.Write(HttpRequest.Content[1], HttpRequest.ContentLength);
    lWav.Position:= 0;
    lIdStudyProcedure := Variable['filename'];
    lIdStudyProcedure := AnsiReplaceStr(lIdStudyProcedure, '.wav', '');
    datamodule1.SaveWav(lWav, StrToInt(lIdStudyProcedure));
    Write('Size: ' + IntToStr(HttpRequest.ContentLength));
  finally
    lWav.Free;
  end;
end;

procedure TActAudio.Get;
var
  lWav: TMemoryStream;
  lIdStudyProcedure: string;
  lProcess: TProcess;
  lBuf: array[0..511] of byte;
  lReadCount: Integer;
begin
  lIdStudyProcedure := Variable['filename'];
  lIdStudyProcedure := AnsiReplaceStr(lIdStudyProcedure, '.wav', '');

  {lWav := TMemoryStream.Create;
  try
    if datamodule1.LoadWav(lWav, StrToInt(lIdStudyProcedure)) then
    begin
      lWav.Position := 0;
      HttpResponse.ContentStream := lWav;
      HttpResponse.ContentLength:= lWav.Size;
      HttpResponse.ContentType := 'audio/x-wav';
      HttpResponse.SendContent;
    end
    else
      Write('No audio');
  finally
    lWav.Free;
  end;}

  // obtenemos el WAV y lo convertimos a MP3.
  lWav := TMemoryStream.Create;
  try
    lProcess := TProcess.Create(nil);
    if datamodule1.LoadWav(lWav, StrToInt(lIdStudyProcedure)) then
    begin
      lProcess.Executable := '/usr/bin/lame';
      lProcess.Parameters.Add('-');  // el primer - es lectura por stdin
      lProcess.Parameters.Add('-');  // el 2do - es escritura eb stdout
      lProcess.Options := [poUsePipes];
      lProcess.Execute;
      lWav.Position:= 0;
      lWav.SaveToStream(lProcess.Input);
      lProcess.CloseInput;

      lWav.Clear;
      while lProcess.Running or (lProcess.Output.NumBytesAvailable > 0) do
      begin
        {while lProcess.Stderr.NumBytesAvailable > 0 do
        begin
          lReadCount := Min(512, lProcess.Stderr.NumBytesAvailable);
          lProcess.Stderr.Read(lCharBuffer, lReadCount);
          lErrStream.Write(lCharBuffer, lReadCount);
        end;}
        while lProcess.Output.NumBytesAvailable > 0 do
        begin
          lReadCount := Min(512, lProcess.Output.NumBytesAvailable);
          lProcess.Output.Read(lBuf, lReadCount);
          lWav.Write(lBuf, lReadCount);
        end;
      end;

      lWav.Position:= 0;

      HttpResponse.ContentStream := lWav;
      HttpResponse.ContentLength:= lWav.Size;
      HttpResponse.ContentType := 'audio/mpeg';
      HttpResponse.SendContent;
    end
    else
      Write('No audio');
  finally
    lProcess.Free;
    lWav.Free;
  end;
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
