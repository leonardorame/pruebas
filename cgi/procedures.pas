unit procedures;

{$mode objfpc}{$H+}

interface

uses
  fgl,
  Classes;

type
  { TProcedure }

  TProcedure = class
  private
    FCodProcedure: string;
    FIdProcedure: Integer;
    FProcedureName: string;
  published
    property IdProcedure: Integer read FIdProcedure write FIdProcedure;
    property CodProcedure: string read FCodProcedure write FCodProcedure;
    property ProcedureName: string read FProcedureName write FProcedureName;
  end;

  TProcedureList = class (specialize TFPGList<TProcedure>);

implementation

end.

