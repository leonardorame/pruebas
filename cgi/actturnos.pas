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
begin
  lStreamer := TJSONStreamer.Create(nil);
  lList := TStudyList.Create;
  lArray := TJSONArray.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(TheRequest.QueryFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryStudies;
    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
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
      lItem := lStreamer.ObjectToJSON(lStudy);
      lArray.Add(lItem);
      lList.Add(lStudy);
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
  TStudies.Register('/studies');

end.
