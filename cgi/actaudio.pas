unit actaudio;

{$mode objfpc}{$H+}


interface

uses
  Classes,BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger;

type
  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TActAudio.Post;
var
  lWav: TMemoryStream;
begin
  Write(IntToStr(HttpRequest.ContentLength));
  lWav := TMemoryStream.Create;
  try
    lWav.WriteAnsiString(HttpRequest.Content);
    lWav.Position:= 0;
    lWav.SaveToFile('/tmp/' + Variable['filename']);
  finally
    lWav.Free;
  end;
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
