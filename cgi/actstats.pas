unit actstats;

{$mode objfpc}{$H+}

interface

uses
  dmdatabase,
  sqlDb,
  jsonparser,
  fpjson,
  BaseAction,
  sysutils;

type

  { TStats }

  TStats = class
  private
  published
  end;

  { TActStats }

  TActStats = class(specialize TBaseGAction<TStats>)
  public
    procedure Get; override;
  end;

implementation

{ TActStats }

procedure TActStats.Get;
var
  lResult: string;
  lQuery: TSQLQuery;
begin
  lQuery := TSqlQuery.Create(nil);
  try
    lQuery.DataBase := datamodule1.PGConnection1;
    if (Variable['statType'] = 'byModalityLast12Months') then
      lQuery.Sql.Text :=
        'select json_agg(st.*)::text as "Stats" from view_studiesbymodality st'
    else
    if (Variable['statType'] = 'globalByModality') then
      lQuery.Sql.Text :=
        'select json_agg(st.*)::text as "Stats" from view_globalByModality st'
    else
    if (Variable['statType'] = 'totalByMonth') then
      lQuery.Sql.Text :=
        'select json_agg(st.*)::text as "Stats" from view_totalByMonth st';
    lQuery.Open;
    lResult := lQuery.Fields[0].AsString;
    write(lResult);
  finally
    lQuery.Free;
  end;
end;

initialization
  TActStats.Register('/stats/:statType');

end.
