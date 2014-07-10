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
  if HttpRequest.CookieFields.IndexOfName('GTIRTOKEN') > -1 then
  begin
    FSession.Token := HttpRequest.CookieFields.Values['GTIRTOKEN'];
    if not FSession.FindSessionRecord(FSession.Token) then
    begin
      HttpResponse.Code:=401;
      HttpResponse.CodeText:= 'Session not found.';
    end
    else
    begin
      Write(FSession.GetSessionData(FSession.Token));
    end;
  end
  else
  begin
    HttpResponse.Code:=401;
    HttpResponse.CodeText:= 'Session not found.';
  end;
end;

initialization
  TUserData.Register('/sessiondata');

end.
