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
    lStart := (StrToInt(HttpRequest.ContentFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryStudies;
    // filtros
    lStudy := Entity;
    lWhere := '';
    if HttpRequest.ContentFields.Values['IdStudy'] <> '' then
      lWhere := lWhere + 'st.idstudy=' + IntToStr(lStudy.IdStudy) + ' and ';
    if (HttpRequest.ContentFields.Values['HasWav'] <> '') and (AnsiUpperCase(HttpRequest.ContentFields.Values['HasWav']) = 'SI') then
      lWhere := lWhere + 'not (sw.idstudyprocedure is null) and ';
    if (HttpRequest.ContentFields.Values['HasWav'] <> '') and (AnsiUpperCase(HttpRequest.ContentFields.Values['HasWav']) = 'NO') then
      lWhere := lWhere + '(sw.idstudyprocedure is null) and ';
    if HttpRequest.ContentFields.Values['StudyDate'] <> '' then
      lWhere := lWhere + 'st.studydate::varchar like ''' + lStudy.StudyDate + '%'' and ';
    if HttpRequest.ContentFields.Values['AccessionNumber'] <> '' then
      lWhere := lWhere + 'st.AccessionNumber like ''' + lStudy.AccessionNumber + '%'' and ';
    if HttpRequest.ContentFields.Values['Status'] <> '' then
      lWhere := lWhere + 'Upper(s.status) like ''' + UpperCase(lStudy.Status) + '%'' and ';
    if lStudy.Report_UserName <> '' then
      lWhere := lWhere + 'Upper(rfu.username) like ''' + UpperCase(lStudy.Report_UserName) + '%'' and ';
    if lStudy.Patient_LastName <> '' then
      lWhere := lWhere + 'Upper(p.lastname) like ''' + UpperCase(lStudy.Patient_LastName) + '%'' and ';
    if lStudy.Patient_FirstName <> '' then
      lWhere := lWhere + 'Upper(p.firstname) like ''' + UpperCase(lStudy.Patient_FirstName) + '%'' and ';
    if lStudy.Patient_OtherIDs <> '' then
      lWhere := lWhere + 'Upper(p.otherids) like ''' + UpperCase(lStudy.Patient_OtherIDs) + '%'' and ';
    if lStudy.ProcedureName <> '' then
      lWhere := lWhere + 'Upper(pr.procedure) like ''' + UpperCase(lStudy.ProcedureName) + '%'' and ';
    if lStudy.UserName <> '' then
      lWhere := lWhere + 'Upper(u.username) like ''' + UpperCase(lStudy.UserName) + '%'' and ';
    if HttpRequest.ContentFields.Values['Sucursal'] <> '' then
      lWhere := lWhere + 'suc.Sucursal like ''' + lStudy.Sucursal + '%'' and ';
    if lWhere <> '' then
    begin
      // eliminamos el ultimo " and "
      lWhere := Copy(lWhere, 1, Length(lWhere) - 4);
      lSql.SQL.Add('where ' + lWhere);
    end;
    lSql.SQL.Add('order by StudyDate desc, IdStudy desc ');

    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    TBrookLogger.Service.Info(lSql.Sql.Text);

    lSql.Open;

    while not lSql.EOF do
    begin
      lStudy := TStudy.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lStudy.IdStudy := lSql.FieldByName('IdStudy').AsInteger;
      lStudy.StudyDate := FormatDateTime('YYYY-MM-DD HH:NN:SS', lSql.FieldByName('StudyDate').AsDateTime);
      lStudy.Status := lSql.FieldByName('Status').AsString;
      lStudy.AccessionNumber := lSql.FieldByName('AccessionNumber').AsString;
      lStudy.Patient_IdPatient := lSql.FieldByName('Patient_IdPatient').AsInteger;
      lStudy.Patient_FirstName := lSql.FieldByName('Patient_FirstName').AsString;
      lStudy.Patient_LastName := lSql.FieldByName('Patient_LastName').AsString;
      lStudy.Patient_Sex := lSql.FieldByName('Patient_Sex').AsString;
      lStudy.Patient_OtherIDs := lSql.FieldByName('Patient_OtherIDs').AsString;
      lStudy.Patient_BirthDate := FormatDateTime('YYYY-MM-DD', lSql.FieldByName('Patient_BirthDate').AsDateTime);
      lStudy.Perform_IdProfessional := lSql.FieldByName('Perform_IdProfessional').AsInteger;
      lStudy.Perform_FirstName := lSql.FieldByName('Perform_FirstName').AsString;
      lStudy.Perform_LastName := lSql.FieldByName('Perform_LastName').AsString;
      lStudy.Report_IdProfessional := lSql.FieldByName('Report_IdProfessional').AsInteger;
      lStudy.Report_FirstName := lSql.FieldByName('Report_FirstName').AsString;
      lStudy.Report_LastName := lSql.FieldByName('Report_LastName').AsString;
      lStudy.Report_UserName := lSql.FieldByName('Report_UserName').AsString;
      lStudy.ProcedureName := lSql.FieldByName('Procedure').AsString;
      lStudy.IdProcedure := lSql.FieldByName('IdProcedure').AsInteger;
      lStudy.UserName:= lSql.FieldByName('UserName').AsString;
      lStudy.IdCurrentUser:= lSql.FieldByName('IdCurrentUser').AsInteger;
      lStudy.IdStudyProcedure := lSql.FieldByName('IdStudyProcedure').AsInteger;
      lStudy.HasWav := lSql.FieldByName('HasWav').AsString;
      lStudy.Sucursal:= lSql.FieldByName('Sucursal').AsString;
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
