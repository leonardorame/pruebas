unit actaudio;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
  end;

implementation

procedure TActAudio.Post;
begin
  //TheRequest.ContentFields.Values['];
end;

initialization
  TActAudio.Register('/audio');

end.
