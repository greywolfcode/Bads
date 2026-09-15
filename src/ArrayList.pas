unit ArrayList;

  interface

  type
    DynamicIntArr = array of Integer;

    ArrayListInt = class(TObject)
    private
      FMax: Integer;
      FLength: Integer;
      Data: DynamicIntArr; //Only stores integers for now
    public
      constructor Create; overload;
      constructor Create(NumItems: Integer); overload;
      constructor Create(Items: DynamicIntArr); overload;

      property Length: Integer read FLength;

      procedure Add(Item: Integer);
      function Get(Index: Integer): Integer;
      function Pop: Integer; overload;
      function Pop(Index: Integer): Integer; overload;
    end;

  implementation

  function ClosestMultipleOfFour(Num: Integer): Integer;
  begin
    Result := ((Num + 3) div 4) * 4;
  end;

  constructor ArrayListInt.Create;
  begin
    inherited Create;
    FMax := 0;
    SetLength(Data, FMax);
    FLength := 0;
  end;

  constructor ArrayListInt.Create(NumItems: Integer);
  begin
    inherited Create;
    FMax := Arraylist.ClosestMultipleOfFour(NumItems); //array resizes in increments of 4
    SetLength(Data, FMax);
  end;

  constructor ArrayListInt.Create(Items: DynamicIntArr);
  begin
    inherited Create;
    Data := Items;
    FMax := ClosestMultipleOfFour(System.Length(Data)); //array resizes in increments of 4
    SetLength(Data, FMax);
    FLength := System.Length(Items); //number of actual items stored
  end;

  procedure ArrayListInt.Add(Item: Integer);
  begin
      if Length = FMax then //increase array size
      begin
        Inc(FMax, 4);
        SetLength(Data, FMax);
      end;
      Inc(FLength);
      Data[Length] := Item;
  end;

  function ArraylistInt.Get(Index: Integer): Integer;
  begin
    Result := Data[Index];
  end;

  function ArrayListInt.Pop: Integer;
  begin
    Result := Data[Length];
    Dec(FLength);

    if Length < (FMax - 4) then; //decrease array size if requried
    begin
      Dec(FMax, 4);
      SetLength(Data, FMax);
    end;
  end;

  function ArrayListInt.Pop(Index: Integer): Integer;
  var
    I: Integer;
  begin
    Result := Data[Index];
    Dec(FLength);

    //Shift all indicies over
    for I := 1 to FLength - 2 do
    begin
      Data[I] := Data[I + 1];
    end;

    if FLength < (FMax - 4) then; //decrease array size if requried
    begin
      Dec(FMax, 4);
      SetLength(Data, FMax);
    end;
  end;
end.
