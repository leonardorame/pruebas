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
  Write('--->' + Files.FileByName('name').FileName);
end;

initialization
  TActAudio.Register('/audio/:file');

end.
