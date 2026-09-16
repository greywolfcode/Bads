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
        Inc(Data.CurrentToken);
      end;
    finally
      CloseFile(OutputFile);
    end;

  end;

end.