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

  { TNewTemplate }

  TNewTemplate = class(specialize TBaseGAction<TTemplate>)
  public
    procedure Get; override;
  end;

implementation

{ TNewTemplate }

procedure TNewTemplate.Get;
var
  lQuery: TSQLQuery;
  lSql: String;

begin
  lQuery := TSQLQuery.Create(nil);
  try
    try
      lQuery.DataBase := datamodule1.PGConnection1;
      datamodule1.SQLTransaction1.StartTransaction;
      lSql := 'insert into templates(Code, Name) values(:code, :name)';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('code').AsString:= 'NEW-CODE';
      lQuery.ParamByName('name').AsString:= 'NEW-NAME';
      lQuery.ExecSQL;

      lSql := 'SELECT currval(''templates_idtemplate_seq'')';
      lQuery.Sql.Text := lSql;
      lQuery.Open;
      With TJSONObject.Create do
      begin
        Add('IdTemplate', lQuery.Fields[0].AsInteger);
        Write(AsJSON);
        Free;
      end;
      datamodule1.SQLTransaction1.Commit;
    except
      on E: exception do
      begin
        TBrookLogger.Service.Error(E.Message);
        HttpResponse.Code := 500;
        HttpResponse.CodeText := E.message;
      end;
    end;
  finally
    lQuery.Free;
  end;
end;

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
      lSql := 'update templates set template = :template, code = :code, name = :name ' +
        'where idtemplate = :idtemplate';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('template').AsString:= lTemplate.Template;
      lQuery.ParamByName('code').AsString:= lTemplate.Code;
      lQuery.ParamByName('name').AsString:= lTemplate.Name;
      lQuery.ParamByName('idtemplate').AsInteger:= lTemplate.IdTemplate;
      lQuery.ExecSQL;
      With TJSONObject.Create do
      begin
        Add('IdTemplate', lTemplate.IdTemplate);
        Add('Code', lTemplate.Code);
        Add('Name', lTemplate.Name);
        Write(AsJSON);
        Free;
      end;
      datamodule1.SQLTransaction1.Commit;
    except
      on E: exception do
      begin
        TBrookLogger.Service.Error(E.Message);
        HttpResponse.Code := 401;
        HttpResponse.CodeText := E.message;
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
      lQuery.ParamByName('IdTemplate').AsInteger := StrToInt(HttpRequest.QueryFields.Values['IdTemplate']);
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
  TNewTemplate.Register('/template/new');

end.
