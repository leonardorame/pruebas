unit actturno;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
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
        ':iduser)';

      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.ParamByName('report').AsString:= lTurno.Report;
      lQuery.ParamByName('IdRequestingPhysician').Value := null;
      lQuery.ParamByName('IdPerformingPhysician').Value := null;
      lQuery.ParamByName('IdPrimaryInterpreterPhysician').AsInteger := Session.User.IdProfessional;
      lQuery.ParamByName('IdSecondaryInterpreterPhysician').Value := null;
      lQuery.ParamByName('idstatus').AsInteger:= lTurno.IdStatus;
      lQuery.ParamByName('iduser').AsInteger:= Session.User.IdUser;
      lQuery.ExecSQL;
      // update study status
      lSql := 'insert into study_status(idstudy, idstatus, iduser) ' +
        'values(:idstudy, :idstatus, :iduser)';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.ParamByName('idstatus').AsInteger:= lTurno.IdStatus;
      lQuery.ParamByName('iduser').AsInteger:= Session.User.IdUser;
      lQuery.ExecSQL;
      datamodule1.SQLTransaction1.Commit;
    except
      on E: exception do
      begin
        BrookLog.Error(E.Message);
        TheResponse.Code := 401;
        TheResponse.CodeText := E.message;
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
      lQuery.ParamByName('IdStudy').AsInteger := StrToInt(TheRequest.QueryFields.Values['IdStudy']);
      lQuery.Open;
      lStudy.IdStudy := lQuery.FieldByName('IdStudy').AsInteger;
      lStudy.StudyDate := FormatDateTime('YYYY-MM-DD HH:NN:SS', lQuery.FieldByName('StudyDate').AsDateTime);
      lStudy.Status := lQuery.FieldByName('Status').AsString;
      lStudy.IdStatus := lQuery.FieldByName('IdStatus').AsInteger;
      lStudy.Patient_IdPatient := lQuery.FieldByName('Patient_IdPatient').AsInteger;
      lStudy.Patient_FirstName := lQuery.FieldByName('Patient_FirstName').AsString;
      lStudy.Patient_LastName := lQuery.FieldByName('Patient_LastName').AsString;
      lStudy.Patient_Sex := lQuery.FieldByName('Patient_Sex').AsString;
      lStudy.Patient_BirthDate := FormatDateTime('YYYY-MM-DD', lQuery.FieldByName('Patient_BirthDate').AsDateTime);
      lStudy.Perform_IdProfessional := lQuery.FieldByName('Perform_IdProfessional').AsInteger;
      lStudy.Perform_FirstName := lQuery.FieldByName('Perform_FirstName').AsString;
      lStudy.Perform_LastName := lQuery.FieldByName('Perform_LastName').AsString;
      lStudy.Report_IdProfessional := lQuery.FieldByName('Report_IdProfessional').AsInteger;
      lStudy.Report_FirstName := lQuery.FieldByName('Report_FirstName').AsString;
      lStudy.Report_LastName := lQuery.FieldByName('Report_LastName').AsString;
      lStudy.Report := lQuery.FieldByName('Report').AsString;
      lJson := lStreamer.ObjectToJSON(lStudy);
      datamodule1.AddStatusesToJson(lJson);
      datamodule1.AddProceduresToJson(lJson, lStudy.IdStudy);
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
