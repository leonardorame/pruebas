unit actstudystatuses;

{$mode objfpc}{$H+}

interface

uses
  StudyStatus,
  SqlDb,
  fpjson,
  fpjsonrtti,
  BaseAction,
  dmdatabase,
  SysUtils;

type

  { TStudystatuses }

  TStudystatuses = class(specialize TBaseGAction<TStudyStatus>)
  public
    procedure Post; override;
  end;

implementation

{ TStudystatuses }

procedure TStudystatuses.Post;
var
  lList: TStudyStatusList;
  lStudyStatus: TStudyStatus;
  lSql: TSQLQuery;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lData: TJSONObject;
  lStreamer: TJSONStreamer;
  lStart: Integer;
  lLength: Integer;
  lTotalRecords: Integer;
  lWhere: string;
begin
  lTotalRecords := 0;
  lStreamer := TJSONStreamer.Create(nil);
  lList := TStudystatusList.Create;
  lArray := TJSONArray.Create;
  lData := TJsonObject.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(HttpRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryStudyStatuses;
    // filtros
    lStudyStatus := Entity;
    lWhere := '';
    if HttpRequest.ContentFields.Values['IdStudy'] <> '' then
      lWhere := lWhere + 'ss.idstudy=' + IntToStr(lStudyStatus.IdStudy) + ' and ';

    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;
    lSql.SQL.Add('order by Updated desc, IdStudyStatus desc ');

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    //TBrookLogger.Service.Info(lSql.Sql.Text);

    lSql.Open;

    while not lSql.EOF do
    begin
      lStudyStatus := TStudyStatus.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lStudyStatus.IdStudy := lSql.FieldByName('IdStudy').AsInteger;
      lStudyStatus.IdStatus:=lSql.FieldByName('IdStatus').AsInteger;
      lStudyStatus.IdStudyStatus:=lSql.FieldByName('IdStudyStatus').AsInteger;
      lStudyStatus.Status :=lSql.FieldByName('Status').AsString;
      lStudyStatus.Updated := lSql.FieldByName('Updated').AsString;
      lStudyStatus.UserName:= lSql.FieldByName('UserName').AsString;
      lItem := lStreamer.ObjectToJSON(lStudyStatus);
      lArray.Add(lItem);
      lList.Add(lStudyStatus);
      lSql.Next;
    end;
    lSql.Close;
    // se convierte el objeto en JSON
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
  TStudystatuses.Register('/studystatuses');

end.
