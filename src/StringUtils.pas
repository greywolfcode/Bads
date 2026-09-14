unit StringUtils;

  interface

  procedure ConvertEscapeCodes(Input: string): string;

  implementation

  procedure ConvertEscapeCodes(Input: string): string;
  var
    EscapeLocations: array of Integer;
    I: Integer;
  begin
    SetLength(EscapeLocations, Length(Input) / 2); //max number of escape codes
    for I := 1 to Length(Input) do
    begin
      if Input[I] = '\' then
      begin
      end;
    end;
  end;

end.