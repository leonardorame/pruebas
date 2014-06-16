unit actturnos;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger,
  dmdatabase,
  sqldb,
  BaseAction,
  SysUtils;

type

  { TStudy }

  TStudy = class
  private
    FReport: string;
    FIdStudy: Integer;
    FIdUser: Integer;
  published
    property IdStudy: Integer read FIdStudy write FIdStudy;
    property Report: string read FReport write FReport;
    property IdUser: Integer read FIdUser write FIdUser;
  end;

  TActStudy = class(specialize TBaseGAction<TStudy>)
  public
    procedure Post; override;
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
      lSql := 'update study set report = :report, idprimaryinterpreterphysician = :iduser ' +
        'where idstudy = :idstudy';
      lQuery.SQL.Text := lSql;
      lQuery.ParamByName('report').AsString:= lTurno.Report;
      lQuery.ParamByName('idstudy').AsInteger:= lTurno.IdStudy;
      lQuery.ParamByName('iduser').AsInteger:= lTurno.IdUser;
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

initialization
  TActStudy.Register('/study');

end.
