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
  public
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

end.


