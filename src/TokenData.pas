unit TokenData;

  interface

  type
    TokenType = (
      //Grouping
      TSemicolon,
      TAnd,
      TOr,
      TLeftParen,
      TRightParen,
      TLeftCurlyBracket,
      TRightCurlyBracket,
      TEOL,

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
      TDollar,

      //Commands/Vars/Numbers/Data
      TString,
      TWeakString,
      TWord
    );

    Token = record
      Lexeme: string;
      Line: Integer;
      LexemeType: TokenType;
    end;

    TTokenArray = array of Token;

  implementation

end.