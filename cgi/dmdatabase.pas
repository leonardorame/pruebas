unit dmdatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, pqconnection, sqldb, FileUtil,
  fpJson, db,
  BrookLogger,
  inifiles,
  fgl;

type

  { Tdatamodule1 }

  Tdatamodule1 = class(TDataModule)
    PGConnection1: TPQConnection;
    qryStudies: TSQLQuery;
    qryStatuses: TSQLQuery;
    qryPatients: TSQLQuery;
    qryTemplate: TSQLQuery;
    qryTemplates: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    qryStudy: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
  public
    procedure AddStatusesToJson(AJson: TJSONObject);
  end;

var
  datamodule1: Tdatamodule1;

implementation

{$R *.lfm}

{ Tdatamodule1 }

procedure Tdatamodule1.DataModuleCreate(Sender: TObject);
var
  lIni: TIniFile;
begin
  try
    PGConnection1.Params.Clear;
    lIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'tir.ini');
    try
      PGConnection1.DatabaseName:= lIni.ReadString('default', 'db', 'defaultdb');
      PGConnection1.HostName:= lIni.ReadString('default', 'host', '127.0.0.1');
      PGConnection1.Params.Add('port=' + lIni.ReadString('default', 'port', '5432'));
      PGConnection1.Connected:= True;
    finally
      lIni.Free;
    end;
  except
    on E: Exception do
      BrookLog.Info(E.Message);
  end;
end;

procedure Tdatamodule1.AddStatusesToJson(AJson: TJSONObject);
var
  lArray: TJSONArray;
  lItem: TJSONObject;
begin
  lArray := TJSONArray.Create;
  qryStatuses.Open;
  while not qryStatuses.EOF do
  begin
    lItem := TJSONObject.Create;
    lItem.Add('IdStatus', qryStatuses.FieldByName('IdStatus').AsInteger);
    lItem.Add('Status', qryStatuses.FieldByName('Status').AsString);
    lArray.Add(lItem);
    qryStatuses.Next;
  end;
  AJson.Add('Statuses', lArray);
  qryStatuses.Close;
end;

end.


