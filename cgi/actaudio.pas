unit actaudio;

{$mode objfpc}{$H+}


interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger;

type
  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TActAudio.Post;
begin
  try
  write(BrookSettings.DirectoryForUploads);
  write(IntToStr(Files.Count));

  except
    on E: Exception do
      write(E.message);
  end;
  exit;
  Write('--->' + Files.FileByName('Filename').FileName);
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
