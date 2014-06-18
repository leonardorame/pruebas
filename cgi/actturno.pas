unit actturno;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  BaseAction,
  fpjsonrtti,
  SysUtils;

type

  { TStudy }

  TStudy = class
  private
    FIdProfessional: Integer;
    FReport: string;
    FIdStudy: Integer;
    FIdUser: Integer;
  published
    property IdStudy: Integer read FIdStudy write FIdStudy;
    property Report: string read FReport write FReport;
    property IdUser: Integer read FIdUser write FIdUser;
    property IdProfessional: Integer read FIdProfessional write FIdProfessional;
  end;

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
      lSql := 'update study set report = :report, idprimaryinterpreterphysician = :idprofessional ' +
        'where idstudy = :idstudy';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('report').AsString:= lTurno.Report;
      lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.ParamByName('idprofessional').AsInteger:= lTurno.IdProfessional;
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
  lQuery: TSQLQuery;
  lSql: String;
  lTurno: TStudy;
begin
  lTurno := Entity;
  lQuery := TSQLQuery.Create(nil);
  try
    try
      lQuery.DataBase := datamodule1.PGConnection1;
      lSql := 'select report from study where idstudy = ' + TheRequest.QueryFields.Values['IdStudy'];
      IntToStr(lTurno.IdStudy);
      //Write(TJSONStreamer.Create(nil).ObjectToJSON(lTurno).AsJson);
      //BrookLog.Info(lSql);
      lQuery.SQL.Text := lSql;
      //lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.Open;
      Write(lQuery.FieldByName('report').AsString);

    except
      on E: Exception do
        write(E.message);
    end;
  finally
    lQuery.Free;
  end;
end;

initialization
  TActStudy.Register('/study');

end.
