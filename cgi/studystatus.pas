unit studystatus;

{$mode objfpc}{$H+}

interface

uses
  Classes, fgl;

type

  { TStudyStatus }

  TStudyStatus = class
  private
    FIdStatus: Integer;
    FIdStudy: Integer;
    FIdStudyStatus: Integer;
    FStatus: string;
    FUpdated: string;
    FUserName: string;
  published
    property IdStudyStatus: Integer read FIdStudyStatus write FIdStudyStatus;
    property IdStudy: Integer read FIdStudy write FIdStudy;
    property IdStatus: Integer read FIdStatus write FIdStatus;
    property Status: string read FStatus write FStatus;
    property Updated: string read FUpdated write FUpdated;
    property UserName: string read FUserName write FUserName;
  end;

  TStudyStatusList = class (specialize TFPGList<TStudyStatus>);

implementation

end.

