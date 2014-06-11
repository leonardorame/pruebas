unit countries;

{$mode objfpc}{$H+}

interface

uses
  baseaction,
  SysUtils,
  fpjson;

type
  TMyAction = class(TBaseAction)
  public
    procedure Post; override;
  end;

implementation

procedure TMyAction.Post;
var
  lData: TJSONObject;
  lArray: TJsonArray;
  lArrayItem: TJsonObject;
  I: Integer;
  lStart: Integer;
  lLength: Integer;
begin
  lArray := TJsonArray.Create;

  try

  lStart := StrToInt(TheRequest.ContentFields.Values['iDisplayStart']);
  lLength := StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
  for I := lStart to (lStart + lLength) - 1 do
  begin
    lArrayItem := TJsonObject.Create;
    lArrayItem.Add('FirstName', 'Tiger Nixon ' + IntToStr(I));
    lArrayItem.Add('Title', 'System Architect');
    lArrayItem.Add('City', 'Edinburgh');
    lArrayItem.Add('Id', '5421');
    lArrayItem.Add('Date', '2011/04/25');
    lArrayItem.Add('Salary', '$320,800');
    lArray.Add(lArrayItem);
  end;

  lData := TJSONObject.Create;
  lData.Add('data', lArray);
  lData.Add('draw', lLength);
  lData.Add('recordsTotal', 20);
  lData.Add('recordsFiltered', 20);

  Write(lData.AsJson);

  except
    on E: exception do
      Write(TheRequest.Content);
  end;

end;

initialization
  TMyAction.Register('/countries');

end.
