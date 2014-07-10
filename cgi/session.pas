unit session;

{$mode objfpc}{$H+}

interface

uses
  DmDatabase,
  sqldb,
  Classes,
  fpjson,
  jsonparser,
  lazutf8sysutils,
  user,
  BrookLogger,
  SysUtils;

type
  { TSession }

  TSession = class
  private
    FSessionDatabase: TSQLConnection;
    FToken: string;
    FExpire: TDateTime;
    FUser: TUser;
    procedure ParseSessionData(ASessionData: string);
    procedure DeleteExpiredSessions;
    procedure ExecQuery(ASql: string);
    function Match(ASql: string): boolean;
  public
    constructor Create(ADatabase: TSQLConnection);
    destructor Destroy; override;
    function NewSession(ASessionData: string): string;
    function FindSessionRecord(ASessionId: string): boolean;
    function GetSessionData(ASessionId: string): string;
    procedure DeleteSession(ASessionId: string);
    procedure UpdateExpiration;
    property Token: String read FToken write FToken;
    property Expire: TDateTime read FExpire;
    property User: TUser read FUser;
  end;


implementation

uses
  dateutils;

constructor TSession.Create(ADatabase: TSQLConnection);
begin
  inherited Create;
  FSessionDatabase := ADatabase;
  FUser := TUser.Create;
end;

destructor TSession.Destroy;
begin
  FUser.Free;
  inherited Destroy;
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
  ParseSessionData(ASessionData);
  ExecQuery(lSql);

  Result := FToken;
end;

procedure TSession.ParseSessionData(ASessionData: string);
var
  lJson: TJSONObject;
  lParser: TJSONParser;
begin
  lParser := TJSONParser.Create(ASessionData);
  lJson := TJSONObject(lParser.Parse);
  try
    FUser.IdUser:= lJson.Integers['id'];
    FUser.IdProfessional:= lJson.Integers['idprofessional'];
  finally
    lJson.Free;
    lParser.Free;
  end;
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
    TBrookLogger.Service.Info(ASql);
    lQuery.DataBase := FSessionDatabase;
    lQuery.SQL.Text:= ASql;
    if not datamodule1.SQLTransaction1.Active then
      datamodule1.SQLTransaction1.StartTransaction;
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
    GetSessionData(ASessionId);
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
    FSessionDatabase.Transaction.StartTransaction;
    lQuery.SQL.Text:= Format('select SESSIONID, SESSIONTIMESTAMP, SESSIONDATA from SESSIONS Where SESSIONID = %s', [ASessionID]);
    lQuery.Open;
    if lQuery.RecordCount > 0 then
    begin
      Result := lQuery.FieldByName('SESSIONDATA').AsString;
      ParseSessionData(Result);
    end;
  finally
    FSessionDatabase.Transaction.Commit;
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

