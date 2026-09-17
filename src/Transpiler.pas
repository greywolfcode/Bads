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
      Result := 'exit /b ' + Data[Data.CurrentToken].Lexeme + ' ';
      Inc(Data.CurrenToken);
    end;
  end;
  function ProcessExport(var Data: TranspilerData): string
  begin
    Result := 'set ' + Data.Tokens[Data.CurrentToken] + ' ';
    Inc(Data.CurrentToken)
  end;
  function ProcessRead(var Data: TranspilerData): string
  begin
    Result := 'set /p ' + Data.Tokens[Data.CurrentToken] + ' ';
    Inc(Data.CurrentToken)
  end;
  function ProcessVar(var Data: TranspilerData): string
  begin
    if (Data.Tokens[Data.CurrentToken].TokenType = TRightCurlyBracket then
    begin
      Inc(Data.CurrentToken);
      Result := '%' + Data.Tokens[Data.CurrentTokens].Lexeme + '%'; //should be var name
      Inc(Data.CurrentToken);
      Inc(Data.CurrentToken); //bypass closing }
    end
    else if (Data.Tokens[Data.CurrentToken].TokenType = TWord then
    begin
      if Data.Tokens[Data.CurrentToken].Lexeme in [1..9] then
      begin
        Result := '%' + Data.Tokens[Data.CurrentToken].Lexeme + '% ';
        Inc(Data.CurrentToken);
      end
      if Data.Tokens[Data.CurrentToken].Lexeme = '0' then
      begin
        Result := '%~0 ';
        Inc(Data.CurrentToken);
      end
      if Data.Tokens[Data.CurrentToken].Lexeme = '?' then
      begin
        Result := '%ERRORLEVEL% ';
        Inc(Data.CurrentToken);
      end
      if Data.Tokens[Data.CurrentToken].Lexeme = '$' then
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
    else if CurrentT