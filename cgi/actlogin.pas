unit actLogin;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  BaseAction,
  fpjson;

type
  TUser = class
  private
    FFirstName: string;
  published
    property FirstName: string read FFirstName write FFirstName;
  end;

  TActLogin = class(specialize TBaseGAction<TUser>)
  public
    procedure Get; override;
  end;

implementation

procedure TActLogin.Get;
var
  lJson: TJSONObject;
  lQuery: TSQLQuery;
  lSql: String;
begin
  // recibe usuario y password
  // si está todo ok, genera un token
  // activo por un tiempo.

    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := dmdatabase.datamodule1.PGConnection1;
      lSql := 'select ug.usergroup, u.iduser, u.username, u.password, p.idprofessional, p.lastname||'', ''||p.firstname as fullname ' +
        'from users u ' +
        'join user_groups ug on u.idusergroup=ug.idusergroup ' +
        'join professional p on p.idprofessional = u.idprofessional ' +
        'where u.username='''+Params.Values['user']+''' and u.password='''+Params.Values['password']+'''';
      lQuery.SQL.Text := lSql;
      lQuery.Open;
      if lQuery.RecordCount > 0 then
        begin
          lJson := TJSONObject.Create;
          try
            lJson.Strings['id'] := lQuery.FieldByName('iduser').AsString;
            lJson.Integers['idprofessional'] := lQuery.FieldByName('idprofessional').AsInteger;
            lJson.Strings['name'] := lQuery.FieldByName('username').AsString;
            lJson.Strings['profile'] := lQuery.FieldByName('usergroup').AsString;
            lJson.Strings['fullname'] := lQuery.FieldByName('fullname').AsString;
            Session.NewSession(lJson.AsJSON);
            Write(lJson.AsJSON);
          finally
            lJson.Free;
          end;
        end
        else
        begin
          HttpResponse.Code:=401;
          HttpResponse.CodeText:= 'User name or password invalid';
        end;
    finally
      lQuery.Free;
    end;
end;

initialization
  TActLogin.Register('/login');

end.
