unit user;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type

  { TUser }

  TUser = class
  private
    FIdProfessional: Integer;
    FIdUser: Integer;
  published
    property IdUser: Integer read FIdUser write FIdUser;
    property IdProfessional: Integer read FIdProfessional write FIdProfessional;
  end;

implementation

end.

