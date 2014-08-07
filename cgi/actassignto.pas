unit actassignto;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger,
  dmdatabase,
  sqldb,
  jsonparser,
  fpjson;

type
  TAssignTo = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TAssignTo.Post;
var
  lParser: TJSONParser;
  lJson: TJSONObject;
  lSql: TSQLQuery;
  I: Integer;
begin
  lParser := TJSONParser.Create(HttpRequest.Content);
  lSql := TSQLQuery.Create(nil);
  lSql.DataBase := datamodule1.PGConnection1;
  try
    lJson := TJSONObject(lParser.Parse);
    lSql.SQL.Text := 'Update study set IdCurrentUser = :IdCurrentUser where IdStudy = :IdStudy';
    datamodule1.SQLTransaction1.StartTransaction;
    for I := 0 to lJson.Arrays['studies'].Count - 1 do
    begin
      lSql.ParamByName('IdStudy').AsInteger:= lJson.Arrays['studies'].Integers[I];
      lSql.ParamByName('IdCurrentUser').AsInteger:= lJson.Objects['user'].Integers['IdUser'];
      lSql.ExecSQL;
    end;
    datamodule1.SQLTransaction1.Commit;
  finally
    lSql.Free;
    lJson.Free;
    lParser.Free;
  end;
end;

initialization
  TAssignTo.Register('/assignto');

end.
