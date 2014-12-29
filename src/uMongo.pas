unit uMongo;

interface

uses
  SysUtils,
  LibBsonAPI,
  uDelphi5,
  MongoBson, uMongoWriteConcern, uMongoReadPrefs;

type
  EMongo = class(Exception)
    constructor Create(const bson_err: bson_error_p); overload;
  end;

  {  This class is base for other mongo classes: TMongoClient, TMongoDatabase, TMongoCollection
     It contains similar functionality to avoid copypast and caching objects
  }
  TMongoObject = class
  protected
    FCachedReadPrefs: IMongoReadPrefs;
    FCachedMongoWriteConcern: IMongoWriteConcern;
    FError: bson_error_t;
    function GetReadPrefs: IMongoReadPrefs; virtual; abstract;
    procedure SetReadPrefs(const APrefs: IMongoReadPrefs); virtual; abstract;
    function GetWriteConcern: IMongoWriteConcern; virtual; abstract;
    procedure SetWriteConcern(const AWriteConcern: IMongoWriteConcern); virtual; abstract;
    function NativeReadPrefsOrNil(const APrefs: IMongoReadPrefs): Pointer;
    function NativeWriteConcernOrNil(const AWriteConcern: IMongoWriteConcern): Pointer;
    function NativeBsonOrNil(const ABson: IBson): bson_p;
  public
    property ReadPrefs: IMongoReadPrefs read GetReadPrefs write SetReadPrefs;
    property WriteConcern: IMongoWriteConcern read GetWriteConcern write SetWriteConcern;
  end;

  function PPAnsiCharToUTF8StringStringArray(const arr: PPAnsiChar): TStringArray;

implementation

{ EMongo }

constructor EMongo.Create(const bson_err: bson_error_p);
begin
  inherited Create(string(bson_err^.message));
end;

{ functions }

function PPAnsiCharToUTF8StringStringArray(const arr: PPAnsiChar): TStringArray;
var
  item: PAnsiChar;
  i: Integer;
begin
  i := 0;
  item := arr^;
  while item <> nil do
  begin
    SetLength(Result, i + 1);
    Result[i] := UTF8String(item);
    Inc(i);
    item := PPAnsiChar(NativeInt(arr) + i * SizeOf(PAnsiChar))^;
  end;
end;

{ TMongoObject }

function TMongoObject.NativeBsonOrNil(const ABson: IBson): bson_p;
begin
  if ABson <> nil then
    Result := ABson.NativeBson
  else
    Result := nil;
end;

function TMongoObject.NativeReadPrefsOrNil(
  const APrefs: IMongoReadPrefs): Pointer;
begin
  if APrefs <> nil then
    Result := APrefs.NativeReadPrefs
  else
    Result := nil;
end;

function TMongoObject.NativeWriteConcernOrNil(
  const AWriteConcern: IMongoWriteConcern): Pointer;
begin
  if WriteConcern <> nil then
    Result := WriteConcern.NativeWriteConcern
  else
    Result := nil;
end;

end.
