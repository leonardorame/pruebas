unit dmdatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, pqconnection, sqldb, FileUtil,
  fpJson, db;

type

  { Tdatamodule1 }

  Tdatamodule1 = class(TDataModule)
    PGConnection1: TPQConnection;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
    function SqlToJSON(SqlQuery: TSQLQuery; APagina,
      ATotalPaginas: integer; ATotalRegistros: integer): string; overload;
    function SqlToJSON(SqlQuery: TSQLQuery): string; overload;
    function SqlToJSONGenerica(SqlQuery: TSQLQuery): string; overload;
  public
    function ConsultaGenerica(AConsulta:String; AStartIndex,APageSize: Integer;AFiltro, ASorting: String): String; overload;
    function EjecutarConsulta(AConsulta: string; APagina: integer): string; overload;
    function EjecutarConsulta(AConsulta: string): string; overload;
  end;

var
  datamodule1: Tdatamodule1;

implementation

{$R *.lfm}

{ Tdatamodule1 }

procedure Tdatamodule1.DataModuleCreate(Sender: TObject);
begin
  PGConnection1.Connected:= True;
end;

function Tdatamodule1.SqlToJSON(SqlQuery: TSQLQuery; APagina,
  ATotalPaginas: integer; ATotalRegistros: integer): string;
var
  lJsonAux: TJSONObject;
  lJsonRoot: TJSONObject;
  lJsonArray: TJSONArray;
  I: integer;
  lValue: string;
begin
  Result := '';
  lJsonRoot := TJSONObject.Create;
  lJsonArray := TJSONArray.Create;

  try
    while not SqlQuery.EOF do
    begin
      lJsonAux := TJSONObject.Create;
      for I := 0 to SqlQuery.FieldCount - 1 do
      begin
        lValue := SqlQuery.Fields[I].AsString;
        lJSonAux.Add(SqlQuery.Fields[I].FieldName, TJsonString.Create(lValue));
      end;
      lJsonArray.Add(lJSonAux);
      SqlQuery.Next;
    end;
    lJsonRoot.Add('page', APagina);
    lJsonRoot.Add('total', ATotalPaginas);
    lJsonRoot.Add('records', SqlQuery.RecordCount);
    lJsonRoot.Add('recordsTotal', ATotalRegistros);
    lJsonRoot.Add('rows', lJsonArray);
    Result := lJsonRoot.AsJSON;
  finally
    lJsonRoot.Free;
  end;
end;

function Tdatamodule1.SqlToJSON(SqlQuery: TSQLQuery): string;
var
  lJsonAux: TJSONObject;
  lJsonRoot: TJSONObject;
  lJsonArray: TJSONArray;
  I: integer;
  lValue: TJSONData;
begin
  Result := '';
  lJsonRoot := TJSONObject.Create;
  lJsonArray := TJSONArray.Create;

  try
    while not SqlQuery.EOF do
    begin
      lJsonAux := TJSONObject.Create;
      for I := 0 to SqlQuery.FieldCount - 1 do
      begin
        if SqlQuery.Fields[I].DataType = ftInteger then
          lValue := TJSONIntegerNumber.Create( SqlQuery.Fields[I].AsInteger )
        else
          lValue := TJsonString.Create(SqlQuery.Fields[I].AsString);
        lJSonAux.Add(SqlQuery.Fields[I].FieldName, lValue);
      end;
      lJsonArray.Add(lJSonAux);
      SqlQuery.Next;
    end;
    if lJsonArray.Count > 0 then
      Result := lJsonArray[0].AsJSON;
  finally
    lJsonRoot.Free;
  end;
end;

function Tdatamodule1.SqlToJSONGenerica(SqlQuery: TSQLQuery): string;
var
  lJsonAux: TJSONObject;
  lJsonRoot: TJSONObject;
  lJsonArray: TJSONArray;
  I: integer;
  lValue: string;
  lTotal: Integer;
begin
  Result := '';
  lJsonRoot := TJSONObject.Create;
  lJsonArray := TJSONArray.Create;
  lTotal := 0;

  try
    while not SqlQuery.EOF do
    begin
      lJsonAux := TJSONObject.Create;
      for I := 0 to SqlQuery.FieldCount - 1 do
      begin
        if (I = 0) then
          lTotal := SqlQuery.FieldByName('TotalJsonSQL').AsInteger;
        lValue := SqlQuery.Fields[I].AsString;
        lJSonAux.Add(SqlQuery.Fields[I].FieldName, TJsonString.Create(lValue));
      end;
      lJsonArray.Add(lJSonAux);
      SqlQuery.Next;
    end;
    lJsonRoot.Add('TotalRecordCount', lTotal);
    lJsonRoot.Add('Result', 'OK');
    lJsonRoot.Add('Records', lJsonArray);
    Result := lJsonRoot.AsJSON;
  finally
    lJsonRoot.Free;
  end;
end;


function Tdatamodule1.ConsultaGenerica(AConsulta: String; AStartIndex,
  APageSize: Integer; AFiltro, ASorting: String): String;
Var
  AuxSql :TSQLQuery;
  lTotalRegistros,
  lTotalPaginas: Integer;
  lOrder: String;


begin
  if Length (ASorting)>0 then
    lOrder := ' order by '+ASorting else
    lOrder := '';

  Result:= '';
  AConsulta:= Copy(AConsulta, 1, 7)+
 ' count(*) over() as TotalJsonSQL, '+
  Copy(AConsulta, 8, Length(AConsulta))+
  ' '+AFiltro+
  ' '+lOrder+
 ' OFFSET '+IntToStr(AStartIndex)+' LIMIT '+IntToStr(APageSize);

  AuxSql:= TSQLQuery.Create(nil);
  try
    AuxSql.DataBase:= PGConnection1;
    AuxSql.SQL.Text:= AConsulta;
    AuxSql.Open;
    Result:= SqlToJSONGenerica(AuxSql);
    AuxSql.Close;
  finally
    AuxSql.Free;
  end;
end;


function Tdatamodule1.EjecutarConsulta(AConsulta: string; APagina: integer): string;
Var
  AuxSql :TSQLQuery;
  lCntFilas: Integer;
  lTotalRegistros,
    lTotalPaginas: Integer;
begin
  Result:= '';
  lCntFilas:=100;
  AuxSql:= TSQLQuery.Create(nil);
  try
    AuxSql.DataBase:= PGConnection1;
    AuxSql.SQL.Text:= AConsulta+ ' limit 100 offset '+IntToStr(lCntFilas*(APagina-1));
    AuxSql.Open;
    lTotalRegistros := AuxSql.RecordCount;
    if lTotalRegistros > lCntFilas then
     begin
       lTotalPaginas := lTotalRegistros div lCntFilas;
       if (lTotalRegistros mod lCntFilas) > 0 then
         lTotalPaginas := lTotalPaginas + 1;
     end
     else
       lTotalPaginas := 1;
    Result:= SqlToJSON(AuxSql, APagina, lTotalPaginas, lTotalRegistros);

    AuxSql.Close;
  finally
    AuxSql.Free;
  end;
end;

function Tdatamodule1.EjecutarConsulta(AConsulta: string): string;
Var
  AuxSql :TSQLQuery;
  lTotalRegistros,
    lTotalPaginas: Integer;
begin
  Result:= '';
  AuxSql:= TSQLQuery.Create(nil);
  try
    AuxSql.DataBase:= PGConnection1;
    AuxSql.SQL.Text:= AConsulta;
    AuxSql.Open;
    if AuxSql.RecordCount > 0 then
      Result:= SqlToJSON(AuxSql);
  finally
    AuxSql.Free;
  end;
end;

end.


