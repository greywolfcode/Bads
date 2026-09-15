unit Lexer;

  interface

  uses
    SysUtils,
    TokenData;

  function ParseFile(Path: string): TTokenArray;

  implementation

  procedure AddToken(var Arr: TTokenArray; Lexeme: string; Line: Integer; LexemeType: TokenType);
  var
    TokenData: Token;
  begin
    TokenData.Lexeme := Lexeme;
    TokenData.Line := Line;
    TokenData.LexemeType := LexemeType;
    
    SetLength(Arr, Length(Arr) + 1); //will always be full
    Arr[Length(Arr)] := TokenData;
  end;

  function ParseLine(Line: string; LineNum: Integer): TTokenArray;
  var
    Output: TTokenArray;
    Start: Integer;
    Offset: Integer;
    CurrentToken: Char;
  begin
    Start := 1;
    Offset := 1;
    SetLength(Output, 0);
    
    while not (Offset = Length(Line)) do
    begin
      start := offset;
      CurrentToken := Line[Offset];
      Inc(Offset);

      case CurrentToken of
        //grouping
        ';': AddToken(Output, ';', LineNum, TSemiColon);
        '(': AddToken(Output, '(', LineNum, TLeftParen);
        ')': AddToken(Output, ')', LineNum, TRightParen);
        '{': AddToken(Output, '{', LineNum, TLeftCurlyBracket);
        '}': AddToken(Output, '}', LineNum, TRightCurlyBracket);

        //redirection
        '>': AddToken(Output, '>', LineNum, TRedirectOutput);

        //assignment/variables
        '=': AddToken(Output, '=', LineNum, TAssignment);
      else
        
      end;
      
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