unit actaudio;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger;

type
  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TActAudio.Post;
begin
  Write(Files[0].FileName);
  Write(Fields.Text);
end;

initialization
  TActAudio.Register('/audio');

end.
