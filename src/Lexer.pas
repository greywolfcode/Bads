unit Lexer;

  interface

  uses
    TokenData;

  function ParseFile(Path: string): TTokenArray;

  implementation

  procedure AddToken(var Arr: TTokenArray, Lexeme: Token)
  begin
    SetLength(Arr, Length(Arr) + 1); //will always be full
    Arr[Length(Arr)] = Lexeme;
  end;

  function ParseLine(Line: string): TTokenArray
  var
    Output: TTokenArray;
    Start: Integer;
    Offset: Integer
  begin
    Start := 1;
    Offset := 1;
    SetLength(Output, 0);

    while not (Line.Offset = Length(Line) do
    begin
      start := offset;
    end;
  end;

  function ParseFile(Path: string): TTokenArray;
  var
    FileData: TextFile;
    Line: string;
    Output: TTokenArray;
  begin
    if not FileExists(Path) then
    begin
      writeln('Error: File "', Path, '" does not exist');
      Halt(2); //DOS exit code for File not found
    end;

    AssignFile(FileData, Path);
    Reset(FileData);

    try
      while not Eof(FileData) do
      begin
        readln(FileData, Line);
      end;
    finally
      CloseFile(FileData);
    end;

    Result := Output;
  end;

end.