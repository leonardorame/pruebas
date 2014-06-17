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
  SysUtils;

type

  { TStudy }

  TStudy = class
  private
    FIdStudy: Integer;
    FPatient_BirthDate: TDate;
    FPatient_FirstName: string;
    FPatient_LastName: string;
    FPatient_Sex: string;
    FPerform_FirstName: string;
    FPerform_LastName: string;
    FReport_FirstName: string;
    FReport_LastName: string;
    FStatus: string;
    FStudyDate: TDateTime;
  published
    property IdStudy: Integer read FIdStudy write FIdStudy;
    property StudyDate: TDateTime read FStudyDate write FStudyDate;
    property Status: string read FStatus write FStatus;
    property Patient_FirstName: string read FPatient_FirstName write FPatient_FirstName;
    property Patient_LastName: string read FPatient_LastName write FPatient_LastName;
    property Patient_Sex: string read FPatient_Sex write FPatient_Sex;
    property Patient_BirthDate: TDate read FPatient_BirthDate write FPatient_BirthDate;
    property Perform_FirstName: string read FPerform_FirstName write FPerform_FirstName;
    property Perform_LastName: string read FPerform_LastName write FPerform_LastName;
    property Report_FirstName: string read FReport_FirstName write FReport_FirstName;
    property Report_LastName: string read FReport_LastName write FReport_LastName;
  end;

  TStudyList = class (specialize TFPGList<TStudy>);

  TStudies = class(specialize TBaseGAction<TStudy>)
  public
    procedure Get; override;
  end;

implementation

procedure TStudies.Get;
var
  lList: TSTudyList;
  lStudy: TStudy;
  lSql: TSQLQuery;
  lData: TJSONObject;
  lStreamer: TJSONStreamer;
  I: Integer;
  lStart: Integer;
  lLength: Integer;
begin
  lList := TStudyList.Create;
  try
    // se ejecuta la consulta y se la convierte en un objeto
    lStart := (StrToInt(TheRequest.QueryFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.studies;
    lSql.ServerFilter := Format('limit %d offset %d', [lStart, lStart + lLength]);
    lSql.ServerFiltered := True;
    lSql.Open;
    while not lSql.EOF do
    begin
      lStudy := TStudy.Create;
      lStudy.IdStudy := lSql.FieldByName('IdStudy').AsInteger;
      lStudy.StudyDate := lSql.FieldByName('StudyDate').AsDateTime;
      lStudy.Status := lSql.FieldByName('Status').AsString;
      lStudy.Patient_FirstName := lSql.FieldByName('Patient_FirstName').AsString;
      lStudy.Patient_LastName := lSql.FieldByName('Patient_LastName').AsString;
      lStudy.Patient_Sex := lSql.FieldByName('Patient_Sex').AsString;
      lStudy.Patient_BirthDate := lSql.FieldByName('Patient_BirthDate').AsDateTime;
      lStudy.Perform_FirstName := lSql.FieldByName('Perform_FirstName').AsString;
      lStudy.Perform_LastName := lSql.FieldByName('Perform_LastName').AsString;
      lStudy.Report_FirstName := lSql.FieldByName('Report_FirstName').AsString;
      lStudy.Report_LastName := lSql.FieldByName('Report_LastName').AsString;
      lList.Add(lStudy);
    end;
    lSql.Close;

    // se convierte el objeto en JSON
    lStreamer := TJSONStreamer.Create(nil);
    try
      lData := lStreamer.ObjectToJSON(lList);
      lData.Add('data', lData);
      lData.Add('draw', lLength);
      lData.Add('recordsTotal', 20);
      lData.Add('recordsFiltered', 20);

      Write(lData.AsJson);
      BrookLog.Info(ldata.AsJSON);
  finally
    lList.Free;
    lStreamer.Free;
    lData.Free;
  end;
  finally
  end;
  Write('Your content here ...');
end;

initialization
  TStudies.Register('/studies/');

end.
