unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  Classes,
  BrookUtils,
  BrookAction;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Post; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Post;
Var
  D : String;
  F : TFileStream;
  lBoundary: string;
begin
  try
  F:=TFileStream.Create(BrookSettings.DirectoryForUploads + '/test.tmp',fmCreate);
  Try
    D:=Copy(HttpRequest.Content, Pos('boundary=', HttpRequest.Content) + 10, length(HttpRequest.Content));
    lBoundary := Copy(D, 0, Pos(#13, D));
    D := Copy(D, Pos('application/octet-stream', D) + Length('application/octet-stream'), Length(D));
    F.Write(D[1],Length(D));
  finally
    F.Free;
  end;
  except
    on E: Exception do
      write(E.message);
  end;

  Write(BrookSettings.DirectoryForUploads);
  Write('Files uploaded: ' + IntToStr(Files.Count));
end;

initialization
  TMyAction.Register('/testupload/:file');

end.
