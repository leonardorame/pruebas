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
begin
  lStreamer := TJSONStreamer.Create(nil);
  lList := TTemplateList.Create;
  lArray := TJSONArray.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(TheRequest.QueryFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryTemplates;
    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    lSql.Open;

    while not lSql.EOF do
    begin
      lTemplate := TTemplate.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lTemplate.IdTemplate := lSql.FieldByName('IdTemplate').AsInteger;
      lTemplate.Template := lSql.FieldByName('Template').AsString;
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
