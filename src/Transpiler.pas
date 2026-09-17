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
      else if CurrentToken.Lexeme = 'pwd' then
      begin
        Inc(Data.CurrentToken);
        Result := 'cd';
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