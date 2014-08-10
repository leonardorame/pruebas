unit user;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  Fgl;

type

  { TUser }

  TUser = class
  private
    FIdProfessional: Integer;
    FIdUser: Integer;
    FIdUserGroup: Integer;
    FUserName: string;
    FUserGroup: string;
  published
    property IdUser: Integer read FIdUser write FIdUser;
    property IdProfessional: Integer read FIdProfessional write FIdProfessional;
    property IdUserGroup: Integer read FIdUserGroup write FIdUserGroup;
    property UserName: string read FUserName write FUserName;
    property UserGroup: string read FUserGroup write FUserGroup;
  end;

  TUserList = class (specialize TFPGList<TUser>);

implementation

end.

