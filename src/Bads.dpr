program Bads;
{$R *.res}
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Output,
  Compiler;

var
  OutputPath: string;

begin

  if (ParamCount = 0)
     or (ParamStr(1) = '-h')
     or (ParamStr(1) = '--help') then
  begin
    DisplayHelp();
  end
  else if (ParamStr(1) = 'compile') then
  begin
    if (ParamCount < 2) then
    begin
      writeln('Invalid Arguments');
      Halt(3);
    end
    else if (ParamCount = 2) then //no output path
    begin
      OutputPath := './'; //current directory on Dos
    end
    else
    begin
      OutputPath := ParamStr(3);
    end;

    Compile(ParamStr(2), OutputPath);
  end;

end.