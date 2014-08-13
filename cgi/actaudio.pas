unit actaudio;

{$mode objfpc}{$H+}


interface

uses
  Classes,BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils,
  BrookLogger;

type
  TActAudio = class(TBrookAction)
  public
    procedure Post; override;
  end;


implementation

procedure TActAudio.Post;
Var
  D : String;
  F : TFileStream;
begin
  {try
  F:=TFileStream.Create(BrookSettings.DirectoryForUploads + 'test2.tmp',fmCreate);
  Try
    D:='aaa';
    F.Write(D[1],Length(D));
  finally
    F.Free;
  end;
  except
    on E: Exception do
      write(E.message); // here I get: Unable to create file "/tmp/test.tmp"
  end;}
  write(IntToStr(Files.Count));
  exit;
  Write('--->' + Files.FileByName('Filename').FileName);
end;

initialization
  TActAudio.Register('/audio/:filename');

end.
