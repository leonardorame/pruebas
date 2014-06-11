unit actLogin;

{$mode objfpc}{$H+}

interface

uses
  dmdatabase,
  sqldb,
  BaseAction,
  fpjson;

type
  TActLogin = class(TBaseAction)
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
      lSql := 'select * from v_usuarios where usuario='''+Params.Values['user']+''' and clave='''+Params.Values['password']+'''';
      lQuery.SQL.Text := lSql;
      lQuery.Open;
      if lQuery.RecordCount > 0 then
        begin
          lJson := TJSONObject.Create;
          try
            lJson.Strings['idusuario'] := lQuery.FieldByName('idusuario').AsString;
            lJson.Strings['usuario'] := lQuery.FieldByName('usuario').AsString;
            lJson.Strings['perfil'] := lQuery.FieldByName('perfil').AsString;
            Write(Session.NewSession(lJson.AsJSON));
          finally
            lJson.Free;
          end;
        end
        else
        begin
          TheResponse.Code:=401;
          TheResponse.CodeText:= 'User name or password invalid';
        end;
    finally
      lQuery.Free;
    end;
end;

initialization
  TActLogin.Register('/login');

end.
