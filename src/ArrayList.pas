unit ArrayList;

  interface

  type
    ArrayList = class(TObject);
    private
      Max: Integer;
      FLength: Integer;
      Data: array of Integer; //Only stores integers for now
    public
      constructor Create; overload;
      constructor Create(NumItems: Integer); overload;
      constructor Create(Items: array of Integer); overload;

      property Length: Integer read FLength;

      procedure Add(Item: Integer);
      function Pop: Integer; overload;
      function Pop(Index: Integer): Integer; overload;
    end;

  implementation

  function ClosestMultipleOfFour(Num: Integer): Integer;
  begin
    Result := ((Num + 3) div 4) * 4;
  end;

  constructor ArrayList.Create
  begin
    inherited Create;
    Max := 0;
    SetLength(Data, Max);
    Length = 0;
  end;

  constructor ArrayList.Create(NumItems: Integer);
  begin
    inherited Create;
    Max := ClosestMultipleOfFour(NumItems); //array resizes in increments of 4
    SetLength(Data, Max);
  end;

  constructor ArrayList.Create(Items: array of Integer);
  begin
    inherited Create;
    Data := Items;
    Max := ClosestMultipleOfFour(Length(Data)); //array resizes in increments of 4
    SetLength(Data, Max);
    Length = Length(Items); //number of actual items stored
  end;

  procedure ArrayList.Add(Item: Integer);
  begin
      if Length = Max then //increase array size
      begin
        Inc(Max, 4);
        SetLength(Data, Max);
      end;
      Inc(Length);
      Data[Length] := Item;
  end;

  function ArrayList.Pop: Integer;
  begin
    Result := Data[Length]
    Dec(Length);

    if Length < (Max - 4) then; //decrease array size if requried
    begin
      Dec(Max, 4);
      SetLength(Data, Max);
    end;
  end;

  function ArrayList.Pop(Index: Integer): Integer;
  var
    I: Integer;
  begin
    Result := Data[Index]
    Dec(Length);

    //Shift all indicies over
    for I to Length - 2 do
    begin
      Data[I] = Data[I + 1];
    end

    if Length < (Max - 4) then; //decrease array size if requried
    begin
      Dec(Max, 4);
      SetLength(Data, Max);
    end;
  end;
end.
