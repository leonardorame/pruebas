unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookUtils,
  BrookFCLCGIBroker;

implementation

initialization
  BrookSettings.DirectoryForUploads:= '/tmp/upload';
  BrookSettings.KeepUploadedNames:= True;
  BrookSettings.DeleteUploadedFiles:= False;

end.
