unit actturno;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  pqconnection,
  BaseAction,
  fpjson,
  fpjsonrtti,
  study,
  SysUtils;

type
  { TActStudy }

  TActStudy = class(specialize TBaseGAction<TStudy>)
  public
    procedure Post; override;
    procedure Get; override;
  end;

implementation

procedure TActStudy.Post;
var
  lQuery: TSQLQuery;
  lSql: String;
  lTurno: TStudy;
begin
  lTurno := Entity;
  lQuery := TSQLQuery.Create(nil);
  try
    try
      lQuery.DataBase := datamodule1.PGConnection1;
      datamodule1.SQLTransaction1.StartTransaction;
      // update study
      lSql := 'select update_study(' +
        ':idstudy, ' +
        ':report, ' +
        ':IdRequestingPhysician, ' +
        ':IdPerformingPhysician, ' +
        ':IdPrimaryInterpreterPhysician, ' +
        ':IdSecondaryInterpreterPhysician, ' +
        ':idstatus, ' +
        ':iduser, ' +
        ':idprocedure, ' +
        ':qty, ' +
        ':title)';

      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.ParamByName('report').AsString:= lTurno.Report;
      lQuery.ParamByName('IdRequestingPhysician').Value := null;
      lQuery.ParamByName('IdPerformingPhysician').AsInteger := lTurno.Perform_IdProfessional;
      if lTurno.Report_IdProfessional <> 0 then
        lQuery.ParamByName('IdPrimaryInterpreterPhysician').AsInteger := lTurno.Report_IdProfessional
      else
        lQuery.ParamByName('IdPrimaryInterpreterPhysician').AsInteger := Session.User.IdProfessional;
      lQuery.ParamByName('IdSecondaryInterpreterPhysician').Value := null;
      lQuery.ParamByName('idstatus').AsInteger:= lTurno.IdStatus;
      lQuery.ParamByName('iduser').AsInteger:= Session.User.IdUser;
      lQuery.ParamByName('IdProcedure').AsInteger := lTurno.IdProcedure;
      lQuery.ParamByName('Qty').AsInteger := lTurno.Qty;
      lQuery.ParamByName('Title').AsString := lTurno.Title;
      lQuery.ExecSQL;
      datamodule1.SQLTransaction1.Commit;
    except
      on E: EPQDatabaseError do
      begin
        datamodule1.SQLTransaction1.RollBack;
        HttpResponse.Code := 403;
        HttpResponse.Content := E.message_primary;
      end;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TActStudy.Get;
var
  lStudy: TStudy;
  lStreamer: TJSONStreamer;
  lQuery: TSqlQuery;
  lJson: TJSONObject;
begin
  lStreamer := TJSONStreamer.Create(nil);
  lStudy := TStudy.Create;
  try
    try
      lQuery := datamodule1.qryStudy;
      lQuery.ParamByName('IdStudyProcedure').AsInteger := StrToInt(HttpRequest.QueryFields.Values['IdStudyProcedure']);
      lQuery.Open;
      lStudy.IdStudy := lQuery.FieldByName('IdStudy').AsInteger;
      lStudy.AccessionNumber := lQuery.FieldByName('accessionnumber').AsString;
      lStudy.StudyDate := FormatDateTime('YYYY-MM-DD HH:NN:SS', lQuery.FieldByName('StudyDate').AsDateTime);
      lStudy.Status := lQuery.FieldByName('Status').AsString;
      lStudy.IdStatus := lQuery.FieldByName('IdStatus').AsInteger;
      lStudy.Title := lQuery.FieldByName('Title').AsString;
      lStudy.Patient_IdPatient := lQuery.FieldByName('Patient_IdPatient').AsInteger;
      lStudy.Patient_FirstName := lQuery.FieldByName('Patient_FirstName').AsString;
      lStudy.Patient_LastName := lQuery.FieldByName('Patient_LastName').AsString;
      lStudy.Patient_Sex := lQuery.FieldByName('Patient_Sex').AsString;
      lStudy.Patient_OtherIDs := lQuery.FieldByName('Patient_OtherIDs').AsString;
      lStudy.Patient_BirthDate := FormatDateTime('YYYY-MM-DD', lQuery.FieldByName('Patient_BirthDate').AsDateTime);
      lStudy.Perform_IdProfessional := lQuery.FieldByName('Perform_IdProfessional').AsInteger;
      lStudy.Perform_FirstName := lQuery.FieldByName('Perform_FirstName').AsString;
      lStudy.Perform_LastName := lQuery.FieldByName('Perform_LastName').AsString;
      lStudy.Report_IdProfessional := lQuery.FieldByName('Report_IdProfessional').AsInteger;
      lStudy.Report_FirstName := lQuery.FieldByName('Report_FirstName').AsString;
      lStudy.Report_LastName := lQuery.FieldByName('Report_LastName').AsString;
      lStudy.Report := lQuery.FieldByName('Report').AsString;
      lStudy.IdStudyProcedure := lQuery.FieldByName('IdStudyProcedure').AsInteger;
      lStudy.IdProcedure := lQuery.FieldByName('IdProcedure').AsInteger;
      lStudy.Qty:= lQuery.FieldByName('Qty').AsInteger;
      lStudy.UserName:= lQuery.FieldByName('username').AsString;
      lStudy.Modality:= lQuery.FieldByName('Modality').AsString;
      lStudy.DiagnosticoPresuntivo := lQuery.FieldByName('DiagnosticoPresuntivo').AsString;
      lStudy.Observaciones := lQuery.FieldByName('Observaciones').AsString;
      lJson := lStreamer.ObjectToJSON(lStudy);
      datamodule1.AddStatusesToJson(lJson);
      datamodule1.AddProcedureToJson(lJson, lStudy.IdStudyProcedure);
      Write(lJson.AsJSON);
    finally
      lJson.Free;
      lStudy.Free;
    end;
  except
    on E: Exception do
      write(E.message);
  end;
end;

initialization
  TActStudy.Register('/study');

end.
