program Comparison;

{$APPTYPE CONSOLE}

// compiler options
{$if CompilerVersion >= 24}
  {$LEGACYIFEND ON}
{$ifend}
{$if CompilerVersion >= 23}
  {$define UNITSCOPENAMES}
{$ifend}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$ifndef VER140}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$endif}
{$O+}{$R-}{$I-}{$Q-}{$W-}

{$WARN IMPLICIT_STRING_CAST OFF}
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils,
     {$else}
       Windows, SysUtils,
     {$endif}
     UniConv;

// native ordinal types
{$if (not Defined(FPC)) and (CompilerVersion < 22)}
type
  {$if CompilerVersion < 21}
  NativeInt = Integer;
  NativeUInt = Cardinal;
  {$ifend}
  PNativeInt = ^NativeInt;
  PNativeUInt = ^NativeUInt;
{$ifend}

type
  LatinString = type AnsiString(1250);
  IsoLatinString = type AnsiString(28592);

// NOTE:
// there is an internal AnsiString code page field in the desktop
// Delphi (ver >= 2009) compilers
//
// The UniConv library supports an internal code page field, but you should
// perform simple explicit typecast AnsiString() to avoid the hidden conversion.
// for example:
// var
//   L1: LatinString;
//   L2: {Iso}LatinString;
// begin
//   // Incorrect!!!
//   // L1 and L2 will be implicit converted to the default AnsiString code page
//   if sbcs_equal_sbcs(L1, L2) then ...;
//
//   // Correct
//   // L1 and L2 will be compared among its own encoding code pages (the same or different)
//   if sbcs_equal_sbcs(AnsiString(L1), AnsiString(L2)) then ...;

const
  ITERATIONS_COUNT = 2*1000000;


function ansi_ansi_different_codepages_standard(const S1: LatinString; const S2: IsoLatinString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function ansi_ansi_different_codepages_uniconv(const S1: LatinString; const S2: IsoLatinString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_equal_sbcs(AnsiString(S1), AnsiString(S2))) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_compare_sbcs(AnsiString(S1), AnsiString(S2)) < 0) then Inc(Result);
  end;
end;

function utf16_ansi_standard(const S1: UnicodeString; const S2: AnsiString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function utf16_ansi_uniconv(const S1: UnicodeString; const S2: AnsiString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_equal_sbcs(S1, AnsiString(S2))) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_compare_sbcs(S1, AnsiString(S2)) < 0) then Inc(Result);
  end;
end;

function utf16_utf8_standard(const S1: UnicodeString; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function utf16_utf8_uniconv(const S1: UnicodeString; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_equal_utf8(S1, S2)) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_compare_utf8(S1, S2) < 0) then Inc(Result);
  end;
end;

function ansi_utf8_standard(const S1: AnsiString; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function ansi_utf8_uniconv(const S1: AnsiString; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_equal_utf8(AnsiString(S1), S2)) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_compare_utf8(AnsiString(S1), S2) < 0) then Inc(Result);
  end;
end;

function ansi_ansi_standard(const S1: AnsiString; const S2: AnsiString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function ansi_ansi_uniconv(const S1: AnsiString; const S2: AnsiString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_equal_samesbcs(AnsiString(S1), AnsiString(S2))) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (sbcs_compare_samesbcs(AnsiString(S1), AnsiString(S2)) < 0) then Inc(Result);
  end;
end;

function utf16_utf16_standard(const S1: UnicodeString; const S2: UnicodeString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function utf16_utf16_uniconv(const S1: UnicodeString; const S2: UnicodeString; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_equal_utf16(S1, S2)) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf16_compare_utf16(S1, S2) < 0) then Inc(Result);
  end;
end;

function utf8_utf8_standard(const S1: UTF8String; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 = S2) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (S1 < S2) then Inc(Result);
  end;
end;

function utf8_utf8_uniconv(const S1: UTF8String; const S2: UTF8String; Equal: Boolean): Integer;
var
  i: Integer;
begin
  Result := 0;

  if (Equal) then
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf8_equal_utf8(S1, S2)) then Inc(Result);
  end else
  begin
    for i := 1 to ITERATIONS_COUNT do
    if (utf8_compare_utf8(S1, S2) < 0) then Inc(Result);
  end;
end;



procedure RunTest(const T1, T2: string; IsSame: Boolean;
  const S1, S2; const ProcStandard, ProcUniConv: Pointer);
type
  TTestProc = function(const S1, S2: Pointer{some string types}; const Equal: Boolean): Integer;
const
  SINGS: array[Boolean] of string = (' < ', ' = ');
  COMMENTS: array[Boolean] of string = ('diff', 'same');
var
  Types: string;
  Equal: Boolean;
  Time: Cardinal;
begin
  for Equal := High(Boolean) downto Low(Boolean) do
  begin
    Types := T1 + SINGS[Equal] + T2;
    while (Length(Types) < 29) do Types := Types + ' ';

    Write(Types, ' (', COMMENTS[IsSame], ') Standard - ');
    Time := GetTickCount;
    TTestProc(ProcStandard)(Pointer(S1), Pointer(S2), Equal);
    Time := GetTickCount - Time;
    Write(Time, 'ms, UniConv - ');

    Time := GetTickCount;
    TTestProc(ProcUniConv)(Pointer(S1), Pointer(S2), Equal);
    Time := GetTickCount - Time;
    Writeln(Time, 'ms');
  end;
end;


function TEST_STRING: UnicodeString;
begin
  Result := 'If you keep your eye on the profit, you’re going to ' +
            'skimp on the product. But if you focus on making really ' +
            'great products, then the profits will follow. Steve Jobs.';
  UniqueString(Result);
end;

function LOWER_TEST_STRING: UnicodeString;
begin
  Result := AnsiLowerCase(TEST_STRING);
end;


procedure RunAnsiAnsi_DifferentCodePages;
const
  T1 = 'ansi(1250)';
  T2 = 'ansi(iso-2859-2)';
var
  S1: LatinString;
  S2: IsoLatinString;
  P1, P2: Pointer;
begin
  P1 := @ansi_ansi_different_codepages_standard;
  P2 := @ansi_ansi_different_codepages_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunUtf16Ansi;
const
  T1 = 'utf16';
  T2 = 'ansi';
var
  S1: UnicodeString;
  S2: AnsiString;
  P1, P2: Pointer;
begin
  P1 := @utf16_ansi_standard;
  P2 := @utf16_ansi_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunUtf16Utf8;
const
  T1 = 'utf16';
  T2 = 'utf8';
var
  S1: UnicodeString;
  S2: UTF8String;
  P1, P2: Pointer;
begin
  P1 := @utf16_utf8_standard;
  P2 := @utf16_utf8_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunAnsiUtf8;
const
  T1 = 'ansi';
  T2 = 'utf8';
var
  S1: AnsiString;
  S2: UTF8String;
  P1, P2: Pointer;
begin
  P1 := @ansi_utf8_standard;
  P2 := @ansi_utf8_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunAnsiAnsi;
const
  T1 = 'ansi';
  T2 = 'ansi';
var
  S1, S2: AnsiString;
  P1, P2: Pointer;
begin
  P1 := @ansi_ansi_standard;
  P2 := @ansi_ansi_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunUtf16Utf16;
const
  T1 = 'utf16';
  T2 = 'utf16';
var
  S1, S2: UnicodeString;
  P1, P2: Pointer;
begin
  P1 := @utf16_utf16_standard;
  P2 := @utf16_utf16_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;

procedure RunUtf8Utf8;
const
  T1 = 'utf8';
  T2 = 'utf8';
var
  S1, S2: UTF8String;
  P1, P2: Pointer;
begin
  P1 := @utf8_utf8_standard;
  P2 := @utf8_utf8_uniconv;

  S1 := TEST_STRING;
  S2 := TEST_STRING;
  RunTest(T1, T2, True, S1, S2, P1, P2);

  S1 := TEST_STRING;
  S2 := LOWER_TEST_STRING;
  RunTest(T1, T2, False, S1, S2, P1, P2);
end;


begin
  try
    Writeln('The benchmark shows how you can use compare functions of UniConv library');
    Writeln('among the most used encodings: UTF16, UTF8 and Single byte encodings (ANSI).');
    Writeln;
    Writeln('The library contains 120 functions to perform an optional case sensitive');
    Writeln('comparison among many string types (such as PAnsiChar, ShortString,');
    Writeln('WideString, AnsiString, etc), so you''ll find a suitable function easyly.');
    Writeln('To perform case insensitive comparison use "ignorecase" functions.');
    Writeln;
    Writeln;

    // run comparison tests
    RunAnsiAnsi_DifferentCodePages;
    RunUtf16Ansi;
    RunUtf16Utf8;
    RunAnsiUtf8;
    RunAnsiAnsi;
    RunUtf16Utf16;
    RunUtf8Utf8;
  except
    on EAbort do ;

    on E: Exception do
    Writeln(E.ClassName, ': ', E.Message);
  end;

  if (ParamStr(1) <> '-nowait') then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
