unit patient;

{$mode objfpc}{$H+}

interface

uses
  fgl,
  Classes;

type
  { TPatient }

  TPatient = class
  private
    FBirthDate: string;
    FFirstName: string;
    FIdPatient: Integer;
    FLastName: string;
    FSex: string;
  published
    property IdPatient: Integer read FIdPatient write FIdPatient;
    property FirstName: string read FFirstName write FFirstName;
    property LastName: string read FLastName write FLastName;
    property Sex: string read FSex write FSex;
    property BirthDate: string read FBirthDate write FBirthDate;
  end;

  TPatientList = class (specialize TFPGList<TPatient>);

implementation

end.

