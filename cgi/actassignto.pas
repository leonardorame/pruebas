unit actassignto;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger;

type
  TAssignTo = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TAssignTo.Post;
begin
  Write('Ok');
end;

initialization
  TAssignTo.Register('/assignto');

end.
