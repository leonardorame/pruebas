unit actaudio;

{$mode objfpc}{$H+}


interface

uses
  Classes,BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger,
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
  lStudyId: string;
begin
  lWav := TMemoryStream.Create;
  try
    lWav.Write(HttpRequest.Content[1], HttpRequest.ContentLength);
    lWav.Position:= 0;
    lStudyId := Variable['filename'];
    lStudyId := AnsiReplaceStr(lStudyId, '.wav', '');
    datamodule1.SaveWav(lWav, StrToInt(lStudyId));
    //lWav.Position:= 0;
    //lWav.SaveToFile('/tmp/salida.wav');
    Write('Size: ' + IntToStr(HttpRequest.ContentLength));
  finally
    lWav.Free;
  end;
end;

procedure TActAudio.Get;
var
  lWav: TMemoryStream;
  lStudyId: string;
begin
  lStudyId := Variable['filename'];
  lStudyId := AnsiReplaceStr(lStudyId, '.wav', '');

  lWav := TMemoryStream.Create;
  try
    if datamodule1.LoadWav(lWav, StrToInt(lStudyId)) then
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
  end;
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
