unit status;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  Fgl;

type

  { TStatus }

  TStatus = class
  private
    FIdStatus: Integer;
    FStatus: string;
  published
    property IdStatus: Integer read FIdStatus write FIdStatus;
    property Status: string read FStatus write FStatus;
  end;

  TStatusList = class (specialize TFPGList<TStatus>);

implementation

end.
