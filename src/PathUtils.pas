unit PathUtils;

  interface

  uses
    Classes;

  function GetFileName(const Path: string): string;

  implementation

  function GetFileName(const Path: string): string;
  var
    FileName: string;
    FileNameExt: string;
    FileNameParts: TStringList;
    PathParts: TStringList;
  begin
    PathParts := TStringList.Create;
    try
      ExtractStrings(['\', ';'], [' '], PChar(Path), PathParts);
      FileNameExt := PathParts[PathParts.Count - 1];
    finally
      PathParts.Free;
    end;
    
    FileNameParts := TStringList.Create;
    try
      ExtractStrings(['.'], [' '], PChar(Path), FileNameParts);
      FileName := FileNameParts[0];
    finally
      FileNameParts.Free;
    end;

    Result := FileName;
  end;
end.
