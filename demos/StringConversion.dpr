program StringConversion;

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

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils, System.Classes,
     {$else}
       Windows, SysUtils, Classes,
     {$endif}
     UniConv;

// native ordinal types
{$if (not Defined(FPC)) and (CompilerVersion < 22)}
type
  {$if CompilerVersion < 19}
  NativeInt = Integer;
  NativeUInt = Cardinal;
  {$ifend}
  PNativeInt = ^NativeInt;
  PNativeUInt = ^NativeUInt;
{$ifend}




// generate output file and measure the time
(*var
  GeneratingMethodNumber: Cardinal = 0;

procedure RunGeneratingMethod(const Description: string; const GeneratingMethod: TGeneratingMethod);
var
  Time: Cardinal;
begin
  Inc(GeneratingMethodNumber);
  Write(GeneratingMethodNumber, ') ', Description, '...');

  Time := GetTickCount;
    GeneratingMethod(OUTPUT_FILE_NAME);
  Time := GetTickCount - Time;
  Write(' ', Time, 'ms ');

  CompareOutputAndCorrectFiles;
end;  *)


begin
  try
    // benchmark text
 (*   Writeln('The benchmark helps to compare the time of binary/text files generating methods');
    Writeln('Output file must be equal to "Correct.txt" (about 100Mb)');
    GenerateTestStrings;
    if (not FileExists(CORRECT_FILE_NAME)) then
    begin
      Write('Correct file generating... ');
      BufferedTextFileGenerating(CORRECT_FILE_NAME);
      Writeln('done.');
    end;

    // run writers, measure time, compare with correct file
    Writeln;
    Writeln('Let''s test generating methods (it may take up to ten minutes):');
    RunGeneratingMethod('StringList + SaveToFile', StringListGenerating);
    RunGeneratingMethod('FileStream', FileStreamGenerating);
    RunGeneratingMethod('MemoryStream + SaveToFile', MemoryStreamGenerating);
    RunGeneratingMethod('TextFile', TextFileGenerating);
    RunGeneratingMethod('TextFile + buffer', BufferedTextFileGenerating);
    RunGeneratingMethod('CachedFileWriter', CachedFileWriterGenerating);
    RunGeneratingMethod('CachedFileWriter directly', CachedFileWriterDirectlyGenerating);
    RunGeneratingMethod('CachedWriter + FileStream', CachedStreamWriterGenerating);
    RunGeneratingMethod('Stream + CachedFileWriter', CachedBufferStreamGenerating);
  *)
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
