program tir;

{$mode objfpc}{$H+}

uses
  pthreads, BrookApplication, BrookUtils, Brokers, countries, baseaction,
  dmdatabase, session, actLogin, actturno, actturnos, actprint, actuserdata;

begin
  datamodule1 := Tdatamodule1.Create(nil);
  BrookApp.Run;
end.
