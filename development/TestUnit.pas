unit TestUnit;

{$i crystal_options.inc}

interface
  uses {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
       {$ifdef MSWINDOWS}{$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif}{$endif},
       UniConv;



procedure RUN;
procedure ShowMessage(const S: string); overload;
procedure ShowMessage(const StrFmt: string; const Args: array of const); overload;

implementation


(*
var
  i: NativeUInt;
  Lookup: PUniConvSBCS;
  CP: Word;

  if (CODEPAGE_DEFAULT <> 1251) then
    ShowMessage('CODEPAGE_DEFAULT');

  if (DEFAULT_UNICONV_SBCS.CodePage <> 1251) then
    ShowMessage('DEFAULT_UNICONV_SBCS');

  if (UNICONV_SUPPORTED_SBCS[DEFAULT_UNICONV_SBCS_INDEX].CodePage <> 1251) then
    ShowMessage('DEFAULT_UNICONV_SBCS_INDEX');

  if (UniConvSBCSIndex(0) <> 3) then
    ShowMessage('UniConvSBCSIndex(0)');

  if (UniConvSBCS(0).CodePage <> 1251) then
    ShowMessage('UniConvSBCS(0)');

  for i := Low(UNICONV_SUPPORTED_SBCS) to High(UNICONV_SUPPORTED_SBCS) do
  begin
    CP := UNICONV_SUPPORTED_SBCS[i].CodePage;

    if (UniConvSBCSIndex(CP) <> i) then
      ShowMessage('UniConvSBCSIndex(%d)', [i]);

    if (UniConvSBCS(CP) <> @UNICONV_SUPPORTED_SBCS[i]) then
      ShowMessage('UniConvSBCS(%d)', [i]);
  end;

  for i := 1 to High(Word) do
  begin
    CP := i;
    Lookup := UniConvSBCS(CP);

    if (Lookup.CodePage <> CP) and (Lookup.CodePage <> $ffff) then
      ShowMessage('CP = %d', [CP]);
  end;

*)


procedure RUN;
begin


  ShowMessage('Test');
end;

procedure ShowMessage(const S: string);
var
  BreakPoint: string;
begin
  BreakPoint := S;

  {$ifdef MSWINDOWS}
    {$ifdef UNITSCOPENAMES}Winapi.{$endif}Windows.MessageBox(0, PChar(BreakPoint), 'Сообщение:', 0);
  {$endif}

  Halt;
end;

procedure ShowMessage(const StrFmt: string; const Args: array of const);
begin
  ShowMessage(Format(StrFmt, Args));
end;

initialization


end.
