unit baseaction;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,
  BrookHttpDefs,
  HTTPDefs,
  dmdatabase,
  SysUtils,
  session;

type

  { TBaseAction }

  TBaseAction = class(TBrookAction)
  private
    FPageSize: integer;
    FSession: TSession;
    FSorting: String;
    FStartIndex: Integer;
    FStartPage: integer;
    procedure Request(ARequest: TBrookRequest; {%H-}AResponse: TBrookResponse); override;
    procedure ActualizarCookie;
  protected
    procedure Post; override;
    procedure ActualizarOffSet;
  public
    constructor Create; override;
    destructor Destroy; override;
    property Session: TSession read FSession;
    property StartIndex :Integer read FStartIndex write FStartIndex;
    property PageSize :Integer read FPageSize write FPageSize;
    property Sorting  :String read FSorting write FSorting;
  end;


implementation

{ TBaseAction }

procedure TBaseAction.Request(ARequest: TBrookRequest; AResponse: TBrookResponse
  );
var
  C: TCookie;
begin
  if ARequest.PathInfo <> '/login' then
  begin
    FSession.Token := '';
    // Primero se fija si el cliente envió una cookie
    // llamada GTIRTOKEN con el token.
    if TheRequest.CookieFields.IndexOfName('GTIRTOKEN') > -1 then
    begin
      FSession.Token := TheRequest.CookieFields.Values['GTIRTOKEN'];
    end;
    if FSession.Token <> '' then
    begin
      if not FSession.FindSessionRecord(FSession.Token) then
      begin
        AResponse.Code:=401;
        AResponse.CodeText:= 'Session not found.';
      end
      else
      begin
        inherited Request(ARequest, AResponse);
        ActualizarCookie;
      end;
    end
    else
    begin
      // no mandó ni cookie ni token
      AResponse.Code:=401;
      AResponse.CodeText:= 'Session not found.';
    end;
  end
  else
  begin
    inherited Request(ARequest, AResponse);
    ActualizarCookie;
  end;
end;

procedure TBaseAction.ActualizarCookie;
begin
  with TheResponse.Cookies.Add do
  begin
    Name:= 'GTIRTOKEN';
    Value:= FSession.Token;
    FSession.UpdateExpiration;
    Expires := FSession.Expire;
    Path:= '/';
  end;
end;

procedure TBaseAction.ActualizarOffSet;
begin
  try
  StartIndex:= StrToInt(TheRequest.QueryFields.Values['jtStartIndex']);
  PageSize:=  StrToInt(TheRequest.QueryFields.Values['jtPageSize']);
  Sorting:=  TheRequest.QueryFields.Values['jtSorting'];

  if Sorting = 'undefined' then
    Sorting := '';

  except
    StartIndex:= 0;
    PageSize:=  0;
    Sorting := '';
  end;

end;

procedure TBaseAction.Post;
begin
  inherited Post;
  try
  StartIndex:= StrToInt(TheRequest.QueryFields.Values['jtStartIndex']);
  PageSize:=  StrToInt(TheRequest.QueryFields.Values['jtPageSize']);
  Sorting:=  TheRequest.QueryFields.Values['jtSorting'];
  except
    StartIndex:= 0;
    PageSize:=  0;
    Sorting := '';
  end;
end;

constructor TBaseAction.Create;
begin
  FSession := TSession.Create(datamodule1.PGConnection1);
  inherited Create;
end;

destructor TBaseAction.Destroy;
begin
  FSession.Free;
  inherited Destroy;
end;

end.

