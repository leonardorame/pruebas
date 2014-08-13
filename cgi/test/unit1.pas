unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  BrookAction;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Post; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Post;
begin
  Write('Files uploaded: ' + IntToStr(Files.Count));
end;

initialization
  TMyAction.Register('/testupload/:file');

end.
