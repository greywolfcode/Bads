unit Transpiler;

  interface

  uses
    PathUtils,
    TokenData;

  procedure Transpile(Tokens: TTokenArray; InputFilePath: string; OutputFolder: string);

  implementation

  type
    TranspilerData = record
      Tokens: TTokenArray;
      CurrentToken: Integer;
    end;

  function ProcessEcho(var Data: TranspilerData): string;
  var
    Output: string;
  begin
    //handle outputing new line
    if (Data.CurrentToken = Length(Data.Tokens))
       or (Data.Tokens[Data.CurrentToken + 1].LexemeType = TEOL) then
    begin
      Result := 'echo. ';
    end
    else
    //TODO: -n or -e flags maybe?
    begin
      Result := 'echo '; //What to output will be transpiled in main function
    end;
  end;
  function ProcessExit(var Data: TranspilerData): string
  begin
    if (Data.CurrentToken = Length(Data.Tokens)) then
    begin
      Result := 'exit /b ';
    end
    else
    begin
      Inc(Data.CurrenToken);
      Result := 'exit /b ' + Data[Data.CurrentToken].Lexeme + ' ';
    end;
  end;
  function ProcessExport(var Data: TranspilerData): string
  begin
    Inc(Data.CurrentToken)
    Result := 'set ' + Data.Tokens[Data.CurrentToken] + ' ';
  end;
  function ProcessRead(var Data: TranspilerData): string
  begin
    Inc(Data.CurrentToken)
    Result := 'set /p ' + Data.Tokens[Data.CurrentToken] + ' ';
  end;

  function TranspileTokens(var Data: TranspilerData): string;
  var
    CurrentToken: Token;
  begin
    Result := '';

    CurrentToken := Data.Tokens[Data.CurrentToken];

    //Word based types: commands, etc.
    if CurrentToken.LexemeType = TWord then
    begin
      if CurrentToken.Lexeme = 'clear' then
      begin
        Inc(Data.CurrentToken);
        Result := 'cls';
      end
      else if CurrentToken.Lexeme = 'echo' then
      begin
        Inc(Data.CurrentToken);
        Result := ProcessEcho(Data);
      end
      else if CurrentToken.Lexeme = 'exit' then
      begin
        Inc(Data.CurrentToken);
        Result := ProcessExit(Data);
      end
      else if CurrentToken.Lexeme = 'export' then
      begin
        Inc(Data.CurrentToken);
        Result := ProcessExport(Data);
      end
      else if CurrentToken.Lexeme = 'false' then
      begin
        Inc(Data.CurrentToken);
        Result := '(call) ';
      end
      else if CurrentToken.Lexeme = 'pwd' then
      begin
        Inc(Data.CurrentToken);
        Result := 'cd';
      end
      else if CurrentToken.Lexeme = 'read' then
      begin
        Inc(Data.CurrentToken);
        Result := ProcessRead(Data);
      end
      else if CurrentToken.Lexeme = 'true' then
      begin
        Inc(Data.CurrentToken);
        Result := 'ver > nul ';
      end;

    end
    else if CurrentToken.LexemeType = TEOL then
    begin
      Result := #10; //newline
    end;
    else if CurrentToken.LexemeType = TSemiColon then
    begin
      Result := #10; //newline
    end;
  end;

  procedure Transpile(Tokens: TTokenArray; InputFilePath: string; OutputFolder: string);
  var
    Data: TranspilerData;
    FileName: string;
    OutputPath: string;
    OutputFile: TextFile;
  begin
    Data.Tokens := Tokens;
    Data.CurrentToken := 0;

    FileName := GetFileName(InputFilePath);
    OutputPath := OutputFolder + FileName + '.bat';

    AssignFile(OutputFile, OutputPath);
    Rewrite(OutputFile);

    try
      while Data.CurrentToken < Length(Data.Tokens) do
      begin
        write(OutputFile, TranspileTokens(Data));
      end;
    finally
      CloseFile(OutputFile);
    end;

  end;

end.