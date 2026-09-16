unit Compiler;

  interface

  uses
    SysUtils;

  procedure Compile(const FileName: string; const OutputPath: string);

  implementation

  uses
    TokenData,
    Lexer,
    Transpiler;

  procedure Compile(const FileName: string; const OutputPath:string);
  var
    Tokens: TTokenArray;
  begin
    Tokens := ParseFile(FileName);
    Transpile(Tokens, FileName, OutputPath);
  end;
  
end.