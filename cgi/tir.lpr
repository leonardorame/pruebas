program tir;

{$mode objfpc}{$H+}

uses
  pthreads, BrookApplication, BrookUtils, Brokers, countries, baseaction,
  dmdatabase, session, actLogin, actturno, actturnos, actprint, actuserdata,
  study, acttemplates, template, acttemplate, actpatients, patient, user, 
  actaudio, actusers;

begin
  datamodule1 := Tdatamodule1.Create(nil);
  BrookApp.Run;
end.
