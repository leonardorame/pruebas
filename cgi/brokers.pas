unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLEventLogBroker,
  //BrookFCLHttpAppBroker,
  BrookFCLCGIBroker,
  BrookUtils,
  SysUtils;

implementation

initialization
  //BrookSettings.Port := 1024;
  BrookSettings.LogActive := True;
  BrookSettings.LogFile := '/tmp/tir.log';

  // Nota: Aplicar estos permisos al directorio de upload
  // de lo contrario Apache no podrá escribir allí.
  // sudo mkdir /tmp/upload
  // sudo chown www-data:www-data /tmp/upload
  BrookSettings.KeepUploadedNames:= True;
  BrookSettings.DeleteUploadedFiles:= False;
  BrookSettings.DirectoryForUploads:= '/tmp/';


end.
