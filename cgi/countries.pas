unit countries;

{$mode objfpc}{$H+}

interface

uses
  baseaction,
  BrookLogger,
  SysUtils,
  fpjson;

type

  { TCountry }

  TCountry = class
  private
    FFirstName: string;
  published
    property FirstName: string read FFirstName write FFirstName;
  end;

  TMyAction = class(specialize TBaseGAction<TCountry>)
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
    lStart := 0; //StrToInt(TheRequest.ContentFields.Values['iDisplayStart']);
    lLength := 10; //StrToInt(TheRequest.ContentFields.Values['iDisplayLength']);
    for I := lStart to (lStart + lLength) - 1 do
    begin
      lArrayItem := TJsonObject.Create;
      lArrayItem.Add('name', 'Tiger Nixon ' + IntToStr(I));
      lArrayItem.Add('email', 'nombre@address.com');
      lArrayItem.Add('city', 'Edinburgh');
      lArrayItem.Add('id', IntToStr(I));
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
    BrookLog.Info(ldata.AsJSON);

  except
    on E: exception do
      Write(TheRequest.Content);
  end;

end;

initialization
  TMyAction.Register('/countries');

end.
