unit Lexer;

  interface

  uses
    SysUtils,
    StringUtils,
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
    Lexeme: string;
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
        '|': begin
               if (Offset + 1 > Length(Line))
                   or (not (Line[Offset + 1] = '|')) then
               begin
                 AddToken(Output, '|', LineNum, TPipe);
               end
               else
               begin
                 AddToken(Output, '||', LineNum, TOr);
               end;
             end;
        '&': begin
               if (Offset + 1 > Length(Line))
                   or (not (Line[Offset + 1] = '&')) then
               begin
                 
               end
               else
               begin
                 AddToken(Output, '&&', LineNum, TAnd);
               end;
             end;

        //redirection
        '<': AddToken(Output, '<', LineNum, TRedirectInput);
        '>': begin
               if (Offset + 1 > Length(Line))
                   or (not (Line[Offset + 1] = '>')) then
               begin
                 AddToken(Output, '>', LineNum, TRedirectOutput);
               end
               else
               begin
                 AddToken(Output, '>>', LineNum, TRedirectOutputAppend);
               end;
             end;

        //assignment/variables
        '=': AddToken(Output, '=', LineNum, TAssignment);
        '$': AddToken(Output, '$', LineNum, TDollar);

        //data
        #39: begin //single quote '
               while (Offset + 1 <= Length(Line))
                and (not (Line[Offset + 1] = #39)) do
               begin
                 Inc(Offset);
               end;
               Lexeme := Copy(Line, Start, Offset);
               AddToken(Output, Lexeme, LineNum, TString);
             end;
        '"': begin
               Lexeme := '';
               while (Offset + 1 <= Length(Line))
                and (not (Line[Offset + 1] = '"')) do
               begin
                 if Line[Offset + 1] = '\' then
                 begin
                   if Line[Offset + 2] in ['"', '$', '\'] then
                   begin
                     Inc(Offset); //increment twice to get charachter after slash
                     Lexeme := Lexeme + Line[Offset + 2];
                   end
                   else
                   begin
                     Lexeme := Lexeme + Line[Offset + 2];
                   end;
                 end
                 else
                 begin
                   Lexeme := Lexeme + Line[Offset + 1];
                 end;
                 Inc(Offset);
               end;
               AddToken(Output, Lexeme, LineNum, TWeakString);
             end;
      else
        if IsAlphaNumeric(CurrentToken) then
        begin
          Lexeme := '';
          while (Offset + 1 <= Length(Line))
                and (IsAlphaNumeric(Line[Offset + 1]))
                or (Line[Offset + 1] = '_')
                or (Line[Offset + 1] = '\')do
          begin
            if Line[Offset + 1] = '\' then
            begin
              Inc(Offset); //increment twice to get charachter after slash
              Lexeme := Lexeme + Line[Offset + 2];
            end
            else
            begin
              Lexeme := Lexeme + Line[Offset + 1];
            end;
            Inc(Offset);
          end;

          Lexeme := Copy(Line, Start, Offset);
          //check for keyword
          if Lexeme = 'if' then
          begin
            AddToken(Output, 'if', LineNum, TIf);
          end
          else if Lexeme = 'then' then
          begin
            AddToken(Output, 'then', LineNum, TThen);
          end
          else if Lexeme = 'elif' then
          begin
            AddToken(Output, 'elif', LineNum, TElif);
          end
          else if Lexeme = 'else' then
          begin
            AddToken(Output, 'else', LineNum, TElse);
          end
          else if Lexeme = 'fi' then
          begin
            AddToken(Output, 'fi', LineNum, TFi);
          end
          else if Lexeme = 'while' then
          begin
            AddToken(Output, 'while', LineNum, TWhile);
          end
          else if Lexeme = 'until' then
          begin
            AddToken(Output, 'until', LineNum, TUntil);
          end
          else if Lexeme = 'do' then
          begin
            AddToken(Output, 'do', LineNum, TDo);
          end
          else if Lexeme = 'done' then
          begin
            AddToken(Output, 'done', LineNum, TDone);
          end
          else if Lexeme = 'for' then
          begin
            AddToken(Output, 'for', LineNum, TFor);
          end
          else if Lexeme = 'in' then
          begin
            AddToken(Output, 'in', LineNum, TIn);
          end
          else
          begin
            AddToken(Output, Lexeme, LineNum, TWord);
          end;
        end;    
      end;

      AddToken(Output, #10, LineNum, TEOL);
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