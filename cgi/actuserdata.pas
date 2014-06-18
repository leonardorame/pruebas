unit actuserdata;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,
  BrookHttpDefs,
  BrookLogger,
  HTTPDefs,
  dmdatabase,
  SysUtils,
  session;

type

  { TUserData }

  TUserData = class(TBrookAction)
  private
    FSession: TSession;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Get; override;

  end;

implementation

{ TUserData }

constructor TUserData.Create;
begin
  FSession := TSession.Create(datamodule1.PGConnection1);
  inherited Create;
end;

destructor TUserData.Destroy;
begin
  FSession.Free;
  inherited Destroy;
end;

procedure TUserData.Get;
begin
  if TheRequest.CookieFields.IndexOfName('GTIRTOKEN') > -1 then
  begin
    FSession.Token := TheRequest.CookieFields.Values['GTIRTOKEN'];
    if not FSession.FindSessionRecord(FSession.Token) then
    begin
      TheResponse.Code:=401;
      TheResponse.CodeText:= 'Session not found.';
    end
    else
    begin
      Write(FSession.GetSessionData(FSession.Token));
    end;
  end
  else
  begin
    TheResponse.Code:=401;
    TheResponse.CodeText:= 'Session not found.';
  end;
end;

initialization
  TUserData.Register('/sessiondata');

end.
