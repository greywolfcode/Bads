program Bads;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Output,
  Compiler,
  Lexer,
  TokenData;

var
  i: Integer;
  arg: String;

begin

  if (ParamCount = 0)
     or (ParamStr(1) = '-h')
     or (ParamStr(1) = '--help') then
  begin
    DisplayHelp();
  end
  else if (ParamStr(1) = 'compile') then
  begin
    if (ParamCount < 3) then
    begin
      writeln('Invalid Arguments');
      Halt(3);
    end;

    Compile(ParamStr(2), ParamStr(3));
  end;

end.