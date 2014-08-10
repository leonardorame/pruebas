unit actusers;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  BaseAction,
  fpjson,
  fpjsonrtti,
  fgl,
  SysUtils,
  user;

type

  { TUsers }

  TUsers = class(specialize TBaseGAction<TUser>)
  public
    procedure Get; override;
    procedure Post; override;
  end;


implementation

procedure TUsers.Get;
var
  lUser: TUser;
  lStreamer: TJSONStreamer;
  lQuery: TSqlQuery;
  lJson: TJSONObject;
begin
  lStreamer := TJSONStreamer.Create(nil);
  lUser := TUser.Create;
  try
    try
      lQuery := datamodule1.qryUser;
      lQuery.ParamByName('IdUser').AsInteger := StrToInt(Variable['iduser']);
      lQuery.Open;
      lUser.IdUser := lQuery.FieldByName('IdUser').AsInteger;
      lUser.IdProfessional := lQuery.FieldByName('IdProfessional').AsInteger;
      lUser.IdUserGroup := lQuery.FieldByName('IdUserGroup').AsInteger;
      lUser.UserName := lQuery.FieldByName('UserName').AsString;
      lUser.UserGroup := lQuery.FieldByName('UserGroup').AsString;
      lJson := lStreamer.ObjectToJSON(lUser);
      datamodule1.AddProfilesToJson(lJson);
      Write(lJson.AsJSON);
    finally
      lJson.Free;
      lUser.Free;
    end;
  except
    on E: Exception do
      write(E.message);
  end;
end;

procedure TUsers.Post;
var
  lList: TUserList;
  lUser: TUser;
  lSql: TSQLQuery;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lData: TJSONObject;
  lStreamer: TJSONStreamer;
  I: Integer;
  lStart: Integer;
  lLength: Integer;
  lTotalRecords: Integer;
  lWhere: string;
begin
  lStreamer := TJSONStreamer.Create(nil);
  lData := TJsonObject.Create;
  lList := TUserList.Create;
  lArray := TJSONArray.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(HttpRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryUsers;
    TBrookLogger.Service.Info(HttpRequest.ContentFields.Text);
    // filtros
    lUser := Entity;
    lWhere := '';

    if HttpRequest.ContentFields.Values['IdUser'] <> '' then
      lWhere := lWhere + 'IdUser=' + IntToStr(lUser.IdUser) + ' and ';
    if HttpRequest.ContentFields.Values['Name'] <> '' then
      lWhere := lWhere + 'Upper(Name) like ''' + UpperCase(lUser.UserName) + '%'' and ';
    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    TBrookLogger.Service.Debug(lSql.Sql.Text);

    lSql.Open;

    try
      while not lSql.EOF do
      begin
        lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
        lUser.IdUser := lSql.FieldByName('IdUser').AsInteger;
        lUser.UserName := lSql.FieldByName('UserName').AsString;
        lUser.IdUserGroup := lSql.FieldByName('IdUserGroup').AsInteger;
        lUser.UserGroup := lSql.FieldByName('UserGroup').AsString;
        lItem := lStreamer.ObjectToJSON(lUser);
        lArray.Add(lItem);
        lList.Add(lUser);
        lSql.Next;
      end;
    except
      on E: exception do
        TBrookLogger.Service.Error(E.message);
    end;
    lSql.Close;
    // se convierte el objeto en JSON
    lData := TJsonObject.Create;
    try
      lData.Add('data', lArray);
      lData.Add('recordsTotal', lTotalRecords);
      lData.Add('recordsFiltered', lList.Count);
      Write(ldata.AsJSON);
    finally
      lData.Free;
    end;
  finally
    lStreamer.Free;
    lList.Free;
  end;
end;

initialization
  TUsers.Register('/users');
  TUsers.Register('/users/:iduser');

end.
