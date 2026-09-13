program Bads;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Output;

var
  i: Integer;
  arg: String;

begin

  if (ParamCount = 0)
     or (ParamStr(1) = '-h')
     or (ParamStr(1) = '--help') then
  begin
    DisplayHelp();
  end;

end.