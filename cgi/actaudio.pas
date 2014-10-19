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
  private
    procedure WavToMP3(AWav: TMemoryStream);
  public
    procedure Post; override;
    procedure Get; override;
  end;


implementation

procedure TActAudio.WavToMP3(AWav: TMemoryStream);
var
  lOut: TMemoryStream;
  lProcess: TProcess;
  lBuf: array[0..511] of byte;
  lReadCount: Integer;
begin
  lOut := TMemoryStream.Create;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := '/usr/bin/lame';
    lProcess.Parameters.Add('-');  // el primer - es lectura por stdin
    lProcess.Parameters.Add('-');  // el 2do - es escritura eb stdout
    lProcess.Options := [poUsePipes];
    lProcess.Execute;
    AWav.Position:= 0;

    while lProcess.Running or (lProcess.Output.NumBytesAvailable > 0) do
    begin
      // now write data to be encoded.
      lReadCount := AWav.Read(lBuf, SizeOf(lBuf));
      lProcess.Input.Write(lBuf, lReadCount);

      // stdout
      while lProcess.Output.NumBytesAvailable > 0 do
      begin
        lReadCount := lProcess.Output.Read(lBuf, SizeOf(lBuf));
        if lReadCount > 0 then
          lOut.Write(lBuf, lReadCount);
      end;

      // stderr
      while lProcess.StdErr.NumBytesAvailable > 0 do
      begin
        lReadCount := lProcess.StdErr.Read(lBuf, SizeOf(lBuf));
        if lReadCount > 0 then
        begin
          // do something with Stderr data
        end;
      end;
    end;

    AWav.Clear;
    lOut.Position := 0;
    lOut.SaveToStream(AWav)
  finally
    lProcess.Free;
    lOut.Free;
  end;
end;

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
begin
  lIdStudyProcedure := Variable['filename'];
  lIdStudyProcedure := AnsiReplaceStr(lIdStudyProcedure, '.wav', '');

  // obtenemos el WAV y lo convertimos a MP3.
  lWav := TMemoryStream.Create;
  try
    if datamodule1.LoadWav(lWav, StrToInt(lIdStudyProcedure)) then
    begin
      WavToMP3(lWav);
      lWav.Position:= 0;
      HttpResponse.ContentStream := lWav;
      HttpResponse.ContentLength:= lWav.Size;
      HttpResponse.ContentType := 'audio/mpeg';
      HttpResponse.SendContent;
    end
    else
      Write('No audio');
  finally
    lWav.Free;
  end;
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
