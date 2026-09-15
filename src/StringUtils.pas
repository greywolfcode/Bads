unit StringUtils;

  interface

  uses
    SysUtils,
    Math;

  function ConvertEscapeCodes(Line: string): string;
  function IsAlphaNumeric(C: Char): Boolean;

  implementation

  uses
    ArrayList;

  function IsAlphaNumeric(C: Char): Boolean;
  begin
    Result := C in ['a'..'z', 'A'..'Z', '0'..'9'];  
  end;

  function GetOctalCode(Nums: string): string;
  var
    I: Integer;
    DecNum: Integer;
  begin
    DecNum := 0;
    for I := 1 to Length(Nums) do
    begin
      DecNum := DecNum + (Ord(Nums[I]) - Ord('0')) * Round(Power(8, 3 - I));
    end;
    Result := Chr(DecNum);
  end;

  function GetHexCode(Nums: string): string;
  var
    DecNum: Integer;
  begin
    DecNum := StrToIntDef('$' + Nums, 0);
    Result := Chr(DecNum);
  end;

  function GetCharCode(Letter: Char): string;
  begin
    case Letter of
      'a': Result := #7;
      'b': Result := #8;
      'e', 'E': Result := #27;
      'f': Result := #12;
      'n': Result := #13#10; //convert to CRLF
      'r': Result := #13;
      't': Result := #9;
      'v': Result := #11;
      '\': Result := '\';
    else
      Result := #0;
    end;
  end;

  function ConvertEscapeCodes(Line: string): string;
  var
    EscapeLocations: ArrayListInt;
    EscapeChar: Char;
    NewChars: string;
    CodeLength: integer; //how many chars the escape code is
    Loc: Integer;
    I: Integer;
  begin
    EscapeLocations := ArrayListInt.Create;
    try
      for I := 1 to Length(Line) do
      begin
        if Line[I] = '\' then
        begin
          EscapeLocations.add(I);
        end;
      end;

      while EscapeLocations.Length <> 0 do
      begin
        CodeLength := 1;
        NewChars := #0;

        Loc := EscapeLocations.Pop();

        if Loc > Length(Line) - 1 then
        begin
          continue;
        end;

        EscapeChar := Line[I + 1]; //I is location of \
        if EscapeChar = '0' then //octal char
        begin
          if I < Length(Line) - 4 then
          begin
            CodeLength := 4;
            NewChars := GetOctalCode(Copy(Line, I+1, I+4));
          end;
        end
        else if EscapeChar = 'x' then //hex char
        begin
          if I < (Length(Line) - 3) then
          begin
            CodeLength := 5;
            NewChars := GetHexCode(Copy(Line, I+1, I+3));
          end;
        end
        else
        begin
          NewChars := GetCharCode(Line[I + 1]);
        end;

        Line := Copy(Line, 1, I - 1) + NewChars + Copy(Line, I + CodeLength, MaxInt); 

      end;
    finally
      EscapeLocations.Free;
    end;

    Result := Line;
  end;

end.