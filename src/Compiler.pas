unit Compiler;

  interface

  uses
    SysUtils;

  procedure Compile(const FileName: string; const OutputPath: string);

  implementation

  uses
    PathUtils,
    StringUtils;

  function CompileCD(const Line: string): string;
  var
    SplitLoc: Integer;
  begin
    SplitLoc := Pos('cd ', Line) + 3;
    Result := Copy(Line, SplitLoc, MaxInt);
  end;

  function CompileEcho(Line: string): string;
  var
    SplitLoc: Integer;
  begin
    //handle escape charachters
    if Pos(' -e ', Line) > 0 then //no new line after echo
    begin
      //uses user input but sending nul for input value to get no newline
      Result := '<nul set /p="' + Copy(Line, 5, MaxInt) + '"';  
    end;
    if Pos(' -n ', Line) > 0 then //no new line after echo
    begin
      //uses user input but sending nul for input value to get no newline
      Result := '<nul set /p="' + Copy(Line, 5, MaxInt) + '"';
    end
    else
    begin
      Result := 'echo ' + Copy(Line, 5, MaxInt); //split after 'echo '
    end;
  end;

  function CompileExit(const Line: string): string;
  begin
    if Length(Line) > 5 then
    begin
      Result := 'exit /B'; //don't want to close terminal window
    end
    else //Has exit code
    begin
      Result := 'exit /B ' + Copy(Line, 6, MaxInt);
    end;
  end;



  function CompileLine(Line: string): string;
  var
    OutputLine: string;
  begin
    OutputLine := '';

    if Line = ':' then //Null Instruction
    begin
      OutputLine := ':';
    end
    //TODO: running seperate file (. filename)
    //TODO: bind
    //TODO: builtin
    else if Pos('cd ', Line) > 0 then //want space after to ensure it is the command
    begin
      OutputLine :=  CompileCD(Line);
    end
    //TODO: command
    //TODO: continue
    //TODO: declare
    else if Pos('echo', Line) > 0 then
    begin
      OutputLine :=  CompileEcho(Line);
    end
    //TODO: enable
    //TODO: eval
    //TODO: exec
    else if Pos('exit ', Line) > 0 then
    begin
      OutputLine :=  CompileExit(Line);
    end
    //TODO: getopts
    //TODO: hash
    //TODO: help
    //TODO: let
    //TODO: local
    //TODO: logout
    //TODO: printf
    else if Pos('pwd', Line) > 0 then //ignore symbolic links args
    begin
      OutputLine := 'echo %cd%';
    end;
    //TODO: read
    //TODO: readonly
    //TODO: return
    //TODO: set
    //TODO: shift
    //TODO: shopt
    //TODO: source
    //TODO: type
    //TODO: typeset
    //TODO: test
    //TODO: times
    //TODO: trap
    //TODO: ulimit
    //TODO: unmask
    //TODO: unset
    Result := OutputLine;
  end;
  
  procedure Compile(const FileName: string; const OutputPath:string);
  var
    FileData: TextFile;
    OutputFile: TextFile;
    OutputFileName: string;
    Line: string;
  begin
    if not FileExists(FileName) then
    begin
      writeln('Error: File "', FileName, '" does not exist');
      Halt(2); //DOS exit code for File not found
    end;

    OutputFileName := GetFileName(FileName) + '.bat';

    AssignFile(FileData, FileName);
    Reset(FileData);

    try
      while not Eof(FileData) do
      begin
        AssignFile(OutputFile, OutputFileName);
        Rewrite(OutputFile);
        try
          readln(FileData, Line);
          writeln(OutputFile, CompileLine(Line));
        finally
          CloseFile(OutputFile);
        end;
      end;
    finally
      CloseFile(FileData);
    end;
  end;
  
end.