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
    FIdTemplate: Integer;
    FTemplate: string;
  published
    property IdTemplate: Integer read FIdTemplate write FIdTemplate;
    property Template: string read FTemplate write FTemplate;
  end;

  TTemplateList = class (specialize TFPGList<TTemplate>);

implementation

end.

