unit TokenData;

  interface

  type
    TokenType = (
      //Grouping
      TSemicolon,
      TAnd,
      TOr,

      //Redirection
      TRedirectInput,
      TRedirectOutput,
      TRedirectOutputAppend,
      TPipe,

      //Blocks
      TIf,
      TThen,
      TElif,
      TElse,
      TFi,
      TWhile,
      TUntil,
      TDo,
      TDone,
      TFor,
      TIn,

      //Assignemnt/Variables
      TAssignment,
      TExtract,
      TPosition,
      TEvalMath,
    );

    Token = record
      Lexeme: string,
      Line: Integer,
      LexemeType: TokenType,
    end;

    TTokenArray = array of Token;

  implementation

end.