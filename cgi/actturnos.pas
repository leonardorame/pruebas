unit actturnos;

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
  study;

type
  TStudies = class(specialize TBaseGAction<TStudy>)
  public
    procedure Post; override;
  end;

implementation

procedure TStudies.Post;
var
  lList: TSTudyList;
  lStudy: TStudy;
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
  lTotalRecords := 0;
  lStreamer := TJSONStreamer.Create(nil);
  lList := TStudyList.Create;
  lArray := TJSONArray.Create;
  lData := TJsonObject.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(TheRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryStudies;
    // filtros
    lStudy := Entity;
    lWhere := '';
    if TheRequest.ContentFields.Values['IdStudy'] <> '' then
      lWhere := lWhere + 'st.idstudy=' + IntToStr(lStudy.IdStudy) + ' and ';
    if TheRequest.ContentFields.Values['StudyDate'] <> '' then
      lWhere := lWhere + 'st.studydate::varchar like ''' + lStudy.StudyDate + '%'' and ';
    if TheRequest.ContentFields.Values['Status'] <> '' then
      lWhere := lWhere + 's.status like ''' + lStudy.Status + '%'' and ';
    if lStudy.Patient_LastName <> '' then
      lWhere := lWhere + 'p.lastname like ''' + lStudy.Patient_LastName + '%'' and ';
    if lStudy.Patient_FirstName <> '' then
      lWhere := lWhere + 'p.firstname like ''' + lStudy.Patient_FirstName + '%'' and ';
    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    BrookLog.Info(lSql.Sql.Text);

    lSql.Open;

    while not lSql.EOF do
    begin
      lStudy := TStudy.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lStudy.IdStudy := lSql.FieldByName('IdStudy').AsInteger;
      lStudy.StudyDate := FormatDateTime('YYYY-MM-DD HH:NN:SS', lSql.FieldByName('StudyDate').AsDateTime);
      lStudy.Status := lSql.FieldByName('Status').AsString;
      lStudy.Patient_IdPatient := lSql.FieldByName('Patient_IdPatient').AsInteger;
      lStudy.Patient_FirstName := lSql.FieldByName('Patient_FirstName').AsString;
      lStudy.Patient_LastName := lSql.FieldByName('Patient_LastName').AsString;
      lStudy.Patient_Sex := lSql.FieldByName('Patient_Sex').AsString;
      lStudy.Patient_BirthDate := FormatDateTime('YYYY-MM-DD', lSql.FieldByName('Patient_BirthDate').AsDateTime);
      lStudy.Perform_IdProfessional := lSql.FieldByName('Perform_IdProfessional').AsInteger;
      lStudy.Perform_FirstName := lSql.FieldByName('Perform_FirstName').AsString;
      lStudy.Perform_LastName := lSql.FieldByName('Perform_LastName').AsString;
      lStudy.Report_IdProfessional := lSql.FieldByName('Report_IdProfessional').AsInteger;
      lStudy.Report_FirstName := lSql.FieldByName('Report_FirstName').AsString;
      lStudy.Report_LastName := lSql.FieldByName('Report_LastName').AsString;
      lStudy.ProcedureName := lSql.FieldByName('Procedure').AsString;
      lStudy.IdProcedure := lSql.FieldByName('IdProcedure').AsInteger;
      lItem := lStreamer.ObjectToJSON(lStudy);
      lArray.Add(lItem);
      lList.Add(lStudy);
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
  TStudies.Register('/studies');

end.
