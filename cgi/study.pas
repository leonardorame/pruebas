unit study;

{$mode objfpc}{$H+}

interface

uses
  fgl,
  Classes;

type
  { TStudy }

  TStudy = class
  private
    FIdStatus: Integer;
    FIdStudy: Integer;
    FPatient_BirthDate: string;
    FPatient_FirstName: string;
    FPatient_IdPatient: Integer;
    FPatient_LastName: string;
    FPatient_Sex: string;
    FPerform_FirstName: string;
    FPerform_IdProfessional: Integer;
    FPerform_LastName: string;
    FReport: string;
    FReport_FirstName: string;
    FReport_IdProfessonal: Integer;
    FReport_LastName: string;
    FStatus: string;
    FStudyDate: string;
  published
    property IdStudy: Integer read FIdStudy write FIdStudy;
    property StudyDate: string read FStudyDate write FStudyDate;
    property IdStatus: Integer read FIdStatus write FIdStatus;
    property Status: string read FStatus write FStatus;
    property Patient_IdPatient: Integer read FPatient_IdPatient write FPatient_IdPatient;
    property Patient_FirstName: string read FPatient_FirstName write FPatient_FirstName;
    property Patient_LastName: string read FPatient_LastName write FPatient_LastName;
    property Patient_Sex: string read FPatient_Sex write FPatient_Sex;
    property Patient_BirthDate: string read FPatient_BirthDate write FPatient_BirthDate;
    property Perform_IdProfessional: Integer read FPerform_IdProfessional write FPerform_IdProfessional;
    property Perform_FirstName: string read FPerform_FirstName write FPerform_FirstName;
    property Perform_LastName: string read FPerform_LastName write FPerform_LastName;
    property Report_IdProfessional: Integer read FReport_IdProfessonal write FReport_IdProfessonal;
    property Report_FirstName: string read FReport_FirstName write FReport_FirstName;
    property Report_LastName: string read FReport_LastName write FReport_LastName;
    property Report: string read FReport write FReport;
  end;

  TStudyList = class (specialize TFPGList<TStudy>);

implementation

end.

