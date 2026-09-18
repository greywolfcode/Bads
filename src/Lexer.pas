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
        '[': AddToken(Output, '[', LineNum, TLeftSquareBracket);
        ']': AddToken(Output, ']', LineNum, TRightSquareBracket);
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
      begin
        Lexeme := '';
        while (Offset + 1 <= Leng