unit acttemplate;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  BaseAction,
  fpjson,
  fpjsonrtti,
  template,
  SysUtils;

type
  { TActTemplate }

  TActTemplate = class(specialize TBaseGAction<TTemplate>)
  public
    procedure Post; override;
    procedure Get; override;
  end;

implementation

procedure TActTemplate.Post;
var
  lQuery: TSQLQuery;
  lSql: String;
  lTemplate: TTemplate;
begin
  lTemplate := Entity;
  lQuery := TSQLQuery.Create(nil);
  try
    try
      lQuery.DataBase := datamodule1.PGConnection1;
      lSql := 'update templates set template = :template ' +
        'where idtemplate = :idtemplate';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('template').AsString:= lTemplate.Template;
      lQuery.ParamByName('idtemplate').AsInteger:= lTemplate.IdTemplate;
      lQuery.ExecSQL;
      datamodule1.SQLTransaction1.Commit;
    except
      on E: exception do
      begin
        BrookLog.Error(E.Message);
        TheResponse.Code := 401;
        TheResponse.CodeText := E.message;
      end;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TActTemplate.Get;
var
  lTemplate: TTemplate;
  lStreamer: TJSONStreamer;
  lQuery: TSqlQuery;
  lJson: TJSONObject;
begin
  lStreamer := TJSONStreamer.Create(nil);
  lTemplate := TTemplate.Create;
  try
    try
      lQuery := datamodule1.qryTemplate;
      lQuery.ParamByName('IdTemplate').AsInteger := StrToInt(TheRequest.QueryFields.Values['IdTemplate']);
      lQuery.Open;
      lTemplate.IdTemplate := lQuery.FieldByName('IdTemplate').AsInteger;
      lTemplate.Code := lQuery.FieldByName('Code').AsString;;
      lTemplate.Name := lQuery.FieldByName('Name').AsString;;
      lTemplate.Template := lQuery.FieldByName('Template').AsString;;
      lJson := lStreamer.ObjectToJSON(lTemplate);
      Write(lJson.AsJSON);
    finally
      lJson.Free;
      lTemplate.Free;
    end;
  except
    on E: Exception do
      write(E.message);
  end;
end;

initialization
  TActTemplate.Register('/template');

end.
