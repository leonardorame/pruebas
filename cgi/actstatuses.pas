unit actstatuses;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger,
  BaseAction,
  dmdatabase,
  fpjsonrtti,
  status,
  sqldb,
  jsonparser,
  fpjson;

type

  { TStatuses }

  TStatuses = class(specialize TBaseGAction<TStatus>)
  public
    procedure Post; override;
  end;


implementation


{ TStatuses }

procedure TStatuses.Post;
var
  lList: TStatusList;
  lStatus: TStatus;
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
  lList := TStatusList.Create;
  lArray := TJSONArray.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(HttpRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryStatuses;
    // filtros
    lStatus := Entity;
    lWhere := '';

    if HttpRequest.ContentFields.Values['IdStatus'] <> '' then
      lWhere := lWhere + 'IdStatus=' + IntToStr(lStatus.IdStatus) + ' and ';
    if HttpRequest.ContentFields.Values['Status'] <> '' then
      lWhere := lWhere + 'Upper(Status) like ''' + UpperCase(lStatus.Status) + '%'' and ';
    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));

    lSql.Open;

    try
      while not lSql.EOF do
      begin
        //lTemplate := TTemplate.Create;
        lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
        lStatus.IdStatus := lSql.FieldByName('IdStatus').AsInteger;
        lStatus.Status := lSql.FieldByName('Status').AsString;
        lItem := lStreamer.ObjectToJSON(lStatus);
        lArray.Add(lItem);
        lList.Add(lStatus);
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
  TStatuses.Register('/statuses');

end.
