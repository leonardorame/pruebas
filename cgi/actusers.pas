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
    procedure Post; override;
  end;

implementation


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

end.
