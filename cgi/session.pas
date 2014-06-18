unit session;

{$mode objfpc}{$H+}

interface

uses
  DmDatabase,
  sqldb,
  Classes,
  lazutf8sysutils,
  SysUtils;

type
  { TSession }

  TSession = class
  private
    FSessionDatabase: TSQLConnection;
    FToken: string;
    FExpire: TDateTime;
    procedure DeleteExpiredSessions;
    procedure ExecQuery(ASql: string);
    function Match(ASql: string): boolean;
  public
    constructor Create(ADatabase: TSQLConnection);
    function NewSession(ASessionData: string): string;
    function FindSessionRecord(ASessionId: string): boolean;
    function GetSessionData(ASessionId: string): string;
    procedure DeleteSession(ASessionId: string);
    procedure UpdateExpiration;
    property Token: String read FToken write FToken;
    property Expire: TDateTime read FExpire;
  end;


implementation

uses
  dateutils;

constructor TSession.Create(ADatabase: TSQLConnection);
begin
  inherited Create;
  FSessionDatabase := ADatabase;
end;

function TSession.NewSession(ASessionData: string): string;
var
  lSql: string;
  SID: LongInt;
begin
  //Delete any expired sessions before createing a new one
  DeleteExpiredSessions;

  randomize;
  SID := Random(2000000000);
  FToken := IntToStr(SID);
  FExpire := IncMinute(NowUTC(), 30);

  lSql :=
    'INSERT INTO sessions(SESSIONID,SESSIONTIMESTAMP,SESSIONDATA)' +
    'VALUES (%d, ''%s'', ''%s'')';

  lSql := Format(lSql, [SID, FormatDateTime('yyyy-mm-dd hh:mm:ss', FExpire), ASessionData]);
  ExecQuery(lSql);

  Result := FToken;
end;

procedure TSession.DeleteExpiredSessions;
var
   lSql: string;
begin
  lSql := 'DELETE From SESSIONS WHERE (SESSIONTIMESTAMP < ';
  lSql := lSql + '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ''' ';
  lSql := lSql + ')';
  ExecQuery(lSql);
end;

procedure TSession.ExecQuery(ASql: string);
var
   lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := FSessionDatabase;
    lQuery.SQL.Text:= ASql;
    lQuery.ExecSQL;
    datamodule1.SQLTransaction1.Commit;
  finally
    lQuery.Free;
  end;
end;

function TSession.Match(ASql: string): boolean;
var
  lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := FSessionDatabase;
    lQuery.SQL.Text:= ASql;
    lQuery.Open;
    Result := lQuery.RecordCount > 0;
  finally
    lQuery.Free;
  end;
end;

function TSession.FindSessionRecord(ASessionId: string): boolean;
var
  lSql: string;
begin
  try
  Result := False;
  DeleteExpiredSessions;
  lSql := Format('select SESSIONID, SESSIONTIMESTAMP, SESSIONDATA from SESSIONS Where SESSIONID = %s', [ASessionID]);
  Result := Match(lSql);
  if Result then
  begin
    lSql :=
      'update sessions set SESSIONTIMESTAMP = ''%s'' where sessionid=''%s''';

    lSql := Format(lSql, [
      FormatDateTime('yyyy-mm-dd hh:mm:ss', IncMinute(Now, 30)), ASessionId]);
    ExecQuery(lSql);
  end;

  except
    on E: Exception do
      raise Exception.Create(E.message);
  end;
end;

function TSession.GetSessionData(ASessionId: string): string;
var
  lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := FSessionDatabase;
    lQuery.SQL.Text:= Format('select SESSIONID, SESSIONTIMESTAMP, SESSIONDATA from SESSIONS Where SESSIONID = %s', [ASessionID]);
    lQuery.Open;
    if lQuery.RecordCount > 0 then
    begin
      Result := lQuery.FieldByName('SESSIONDATA').AsString;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TSession.DeleteSession(ASessionId: string);
var
  lSql: string;
begin
  lSql := 'DELETE From SESSIONS WHERE sessionid=''%s''';
  lSql := Format(lSql, [ASessionId]);
  ExecQuery(lSql);
end;

procedure TSession.UpdateExpiration;
begin
  FExpire := IncMinute(NowUTC(), 30);
end;

end.

