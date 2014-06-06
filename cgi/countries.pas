unit countries;

{$mode objfpc}{$H+}

interface

uses
  BrookAction,
  SysUtils,
  fpjson;

type
  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TMyAction.Get;
var
  lData: TJSONObject;
  lArray: TJsonArray;
  lArrayItem: TJsonObject;
  I: Integer;
begin
  lArray := TJsonArray.Create;

  for I := StrToInt(TheRequest.QueryFields.Values['start']) to StrToInt(TheRequest.QueryFields.Values['start']) + StrToInt(TheRequest.QueryFields.Values['length']) do
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
  lData.Add('draw', StrToInt(TheRequest.QueryFields.Values['draw']));
  lData.Add('recordsTotal', 20);
  lData.Add('recordsFiltered', 20);

  Write(lData.AsJson);

end;

initialization
  TMyAction.Register('/countries');

end.
