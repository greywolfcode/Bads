unit Compiler;

  interface

  uses
    SysUtils;

  procedure Compile(const FileName: string; const OutputPath: string);

  implementation

  uses
    PathUtils;

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
          Readln(FileData, Line);
          WriteLn(OutputFile, Line);
        finally
          CloseFile(OutputFile);
        end;
      end;
    finally
      CloseFile(FileData);
    end;

  end;

end.