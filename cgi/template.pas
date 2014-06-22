unit template;

{$mode objfpc}{$H+}

interface

uses
  fgl,
  Classes;

type
  { TTemplate }

  TTemplate = class
  private
    FCode: string;
    FIdTemplate: Integer;
    FName: string;
    FTemplate: string;
  published
    property IdTemplate: Integer read FIdTemplate write FIdTemplate;
    property Code: string read FCode write FCode;
    property Name: string read FName write FName;
    property Template: string read FTemplate write FTemplate;
  end;

  TTemplateList = class (specialize TFPGList<TTemplate>);

implementation

end.
