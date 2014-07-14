unit acttemplates;

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
  template;

type

  { TTemplates }

  TTemplates = class(specialize TBaseGAction<TTemplate>)
  public
    procedure Post; override;
  end;

implementation



procedure TTemplates.Post;
var
  lList: TTemplateList;
  lTemplate: TTemplate;
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
  lList := TTemplateList.Create;
  lArray := TJSONArray.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(HttpRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryTemplates;
    // filtros
    lTemplate := Entity;
    lWhere := '';
    if HttpRequest.ContentFields.Values['IdTemplate'] <> '' then
      lWhere := lWhere + 'IdTemplate=' + IntToStr(lTemplate.IdTemplate) + ' and ';
    if HttpRequest.ContentFields.Values['Code'] <> '' then
      lWhere := lWhere + 'Upper(Code) like ''' + UpperCase(lTemplate.Code) + '%'' and ';
    if HttpRequest.ContentFields.Values['Name'] <> '' then
      lWhere := lWhere + 'Upper(Name) like ''' + UpperCase(lTemplate.Name) + '%'' and ';
    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    TBrookLogger.Service.Info(lSql.Sql.Text);

    lSql.Open;

    while not lSql.EOF do
    begin
      //lTemplate := TTemplate.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lTemplate.IdTemplate := lSql.FieldByName('IdTemplate').AsInteger;
      lTemplate.Code := lSql.FieldByName('Code').AsString;
      lTemplate.Name := lSql.FieldByName('Name').AsString;
      lItem := lStreamer.ObjectToJSON(lTemplate);
      lArray.Add(lItem);
      lList.Add(lTemplate);
      lSql.Next;
    end;
    lSql.Close;
    // se convierte el objeto en JSON
    lData := TJsonObject.Create;
    lData.Add('data', lArray);
    lData.Add('recordsTotal', lTotalRecords);
    lData.Add('recordsFiltered', lList.Count);

    Write(ldata.AsJSON);
  finally
    lList.Free;
    lStreamer.Free;
    lData.Free;
  end;
end;

initialization
  TTemplates.Register('/templates');

end.
