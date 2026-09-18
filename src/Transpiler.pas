unit Transpiler;

  interface

  uses
    StringUtils,
    PathUtils,
    TokenData;

  procedure Transpile(Tokens: TTokenArray; InputFilePath: string; OutputFolder: string);

  implementation

  type
    TranspilerData = record
      Tokens: TTokenArray;
      CurrentToken: Integer;
    end;

  function ProcessString(var Data: TranspilerData): string ;
  var
    Lexeme: string;
  begin
    Lexeme := Data.Tokens[Data.CurrentToken].Lexeme;
    Result := Copy(Lexeme, 2, Length(Lexeme) - 1); //remove ' marks
  end;
  function ProcessWeakString(var Data: TranspilerData; StripQuotes: Boolean): string;
  var
    Lexeme: string;
    Offset: Integer;
    VarPos: Integer;
  begin
    Lexeme := Data.Tokens[Data.CurrentToken].Lexeme;

    if StripQuotes then
    begin
      Lexeme := Copy(Lexeme, 2, Length(Lexeme) - 1); //remove " marks
    end;
    
    //expand variables inside
    VarPos := Pos('$', Lexeme);
    while VarPos > 0 do
    begin
      Offset := VarPos + 1;

      while (not Offset > Length(Lexeme))
            and (not IsWhitespace(Lexeme[Offset + 1])) do
      begin
        Inc(Offset);
      end;

      Lexeme := Copy(Lexeme, 1, VarPos - 1) + '%'
                + Copy(Lexeme, VarPos + 1, Offset - VarPos + 1)
                + Copy(Lexeme, VarPos + 1 + Offset, MaxInt);

      VarPos := Pos('$', Lexeme);
    end;
    
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
  function ProcessExit(var Data: TranspilerData): string;
  begin
    if (Data.CurrentToken = Length(Data.Tokens)) then
    begin
      Result := 'exit /b ';
    end
    else
    begin
      Result := 'exit /b ' + Data.Tokens[Data.CurrentToken].Lexeme + ' ';
      Inc(Data.CurrentToken);
    end;
  end;
  function ProcessExport(var Data: TranspilerData): string;
  begin
    Result := 'set ' + Data.Tokens[Data.CurrentToken].Lexeme + ' ';
    Inc(Data.CurrentToken)
  end;
  function ProcessRead(var Data: TranspilerData): string;
  begin
    Result := 'set /p ' + Data.Tokens[Data.CurrentToken].Lexeme + ' ';
    Inc(Data.CurrentToken)
  end;
  function ProcessVar(var Data: TranspilerData): string;
  begin
    if Data.Tokens[Data.CurrentToken].LexemeType = TRightCurlyBracket then
    begin
      Inc(Data.CurrentToken);
      Result := '%' + Data.Tokens[Data.CurrentToken].Lexeme + '%'; //should be var name
      Inc(Data.CurrentToken);
      Inc(Data.CurrentToken); //bypass closing }
    end
    else if Data.Tokens[Data.CurrentToken].LexemeType = TWord then
    begin
      if Data.Tokens[Data.CurrentToken].Lexeme[1] in ['1'..'9'] then
      begin
        Result := '%' + Data.Tokens[Data.CurrentToken].Lexeme + '% ';
        Inc(Data.CurrentToken);
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '0' then
      begin
        Result := '%~0 ';
        Inc(Data.CurrentToken);
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '?' then
      begin
        Result := '%ERRORLEVEL% ';
        Inc(Data.CurrentToken);
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '$' then
      begin
        Result := '%RANDOM% '; //No PID on Win98/DOS
        Inc(Data.CurrentToken);
      end
      else
      begin
        Result := '%' + Data.Tokens[Data.CurrentToken].Lexeme + ' ';
        Inc(Data.CurrentToken);
      end;
    end
  end;
  function ProcessTest(var Data: TranspilerData): string;
  var
    Output: string;
  begin
    Output := '';

    if Data.Tokens[Data.CurrentToken].LexemeType = TLeftSquareBracket then
    begin
      Inc(Data.CurrentToken);
    end;

    if Data.Tokens[Data.CurrentToken].LexemeType = TWeakString then
    begin
      Output := Output + ProcessWeakString(Data, False);
      Inc(Data.CurrentToken);

      if Data.Tokens[Data.CurrentToken].Lexeme = '=' then
      begin
        Output := Output + '==';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '!=' then
      begin
        Output := 'NOT ' + Output + '==';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-eq' then
      begin
        Output := Output + ' EQU ';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-ne' then
      begin
        Output := Output + ' NEQ ';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-lt' then
      begin
        Output := Output + ' LSS ';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-le' then
      begin
        Output := Output + ' LEQ ';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-gt' then
      begin
        Output := Output + ' GTR ';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-ge' then
      begin
        Output := Output + ' GEQ ';
      end
    end
    else if Data.Tokens[Data.CurrentToken].LexemeType = TWord then
    begin
      if Data.Tokens[Data.CurrentToken].Lexeme = '-z' then
      begin
        Inc(Data.CurrentToken);
        Output := ProcessWeakString(Data, False) + '==""'
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-n' then
      begin
        Inc(Data.CurrentToken);
        Output := 'Not ' + ProcessWeakString(Data, False) + '==""'
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-f' then
      begin
        Inc(Data.CurrentToken);
        Output := 'EXIST '
                  + FixPathSeperators(ProcessWeakString(Data, False))
                  + '==""';
      end
      else if Data.Tokens[Data.CurrentToken].Lexeme = '-n' then
      begin
        Inc(Data.CurrentToken);
        Output := 'EXIST '
                  + FixPathSeperators(ProcessWeakString(Data, False))
                  + '\' + '==""';
      end
    end;

  Result := Output;  
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
      //Builtin Commands
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
    else if CurrentToken.LexemeType = TDollar then
    begin
      Result := ProcessVar(Data);
    end
    else if CurrentToken.LexemeType = TLeftSquareBracket then
    begin
      Result := ProcessTest(Data);
    end

    //strings
    else if CurrentToken.LexemeType = TString then
    begin
      Result := ProcessString(Data);
    end
    else if CurrentToken.LexemeType = TWeakString then
    begin
      Result := ProcessWeakString(Data, False);
    end

    //newline charachters
    else if CurrentToken.LexemeType = TEOL then
    begin
      Inc(Data.CurrentToken);
      Result := #10; //newline
    end
    else if CurrentToken.LexemeType = TSemiColon then
    begin
      Inc(Data.CurrentToken);
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