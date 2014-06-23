unit actpatients;

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
  patient;

type
  TPatients = class(specialize TBaseGAction<TPatient>)
  public
    procedure Post; override;
  end;

implementation

procedure TPatients.Post;
var
  lList: TPatientList;
  lPatient: TPatient;
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
  lList := TPatientList.Create;
  lArray := TJSONArray.Create;
  lData := TJsonObject.Create;

  try
    try
    // se ejecuta la consulta y se la convierte en un objeto

    lStart := (StrToInt(TheRequest.QueryFields.Values['pageNumber']) * 10) - 10;
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    lSql := datamodule1.qryPatients;
    lSql.SQL.Add(Format('limit %d offset %d', [lLength, lStart]));
    lSql.Open;

    while not lSql.EOF do
    begin
      lPatient := TPatient.Create;
      lTotalRecords := lSql.FieldByName('TotalRecords').AsInteger;
      lPatient.IdPatient := lSql.FieldByName('IdPatient').AsInteger;
      lPatient.FirstName := lSql.FieldByName('FirstName').AsString;
      lPatient.LastName := lSql.FieldByName('LastName').AsString;
      lPatient.Sex := lSql.FieldByName('Sex').AsString;
      lPatient.BirthDate := FormatDateTime('YYYY-MM-DD', lSql.FieldByName('BirthDate').AsDateTime);
      lItem := lStreamer.ObjectToJSON(lPatient);
      lArray.Add(lItem);
      lList.Add(lPatient);
      lSql.Next;
    end;
    lSql.Close;
    // se convierte el objeto en JSON
    lData.Add('data', lArray);
    lData.Add('recordsTotal', lTotalRecords);
    lData.Add('recordsFiltered', lList.Count);

    Write(ldata.AsJSON);

    except
      on E: Exception do
        write(E.message);
    end;
  finally
    lList.Free;
    lStreamer.Free;
    lData.Free;
  end;
end;

initialization
  TPatients.Register('/patients');

end.
