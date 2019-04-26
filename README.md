# UniConv

UniConv is a universal quick and compact library intended for conversion, comparison and change of the register of text in concordance with the latest standards of the Unicode Consortium. The library’s function greatly resembles ICU, libiconv and Windows.kernel which are de facto standard for popular operating systems. There are several reasons for design and use of UniConv:
* None of the libraries supports [the full list](http://www.w3.org/TR/2008/REC-xml-20081126/#sec-guessing-no-ext-info) of byte order mark ([BOM](http://en.wikipedia.org/wiki/Byte_order_mark)) 
* None of the libraries supports [the full list of encodings](http://www.w3.org/TR/2014/WD-encoding-20140128/#encodings), provided by XML and HTML standards
* There is no universal "best-fit" behavior for single-byte character sets. The results of conversion differ not only for different libraries but also for different code pages within the same library
* There are no comparison functions between strings in different codings "on-the-fly" (e.g. between UTF-16 and UTF-8, or Windows-1251 and Windows-1252).
* Library interface is poorly adapted for the sequential processing of large text files
* Libraries are constructed from considerations of universality but not the maximum performance
* The identity of the transformations is not guaranteed (e.g. `CFStringUppercase`, `u_strToUpper` and `CharUpperBuffW`) process differently some characters. Even `CharUpperBuffW` on Windows XP and Windows 10 may produce different results

The examples of the library use you can find on demonstration projects: [Demo.zip](https://github.com/d-mozulyov/UniConv/raw/master/data/Demo.zip)
![](https://github.com/d-mozulyov/UniConv/raw/master/data/ScreenShots.png)

##### Supported encodings
UniConv supports 50 encodings:
* 12 Unicode encodings: UTF-8, UTF-16(LE) ~ UCS2, UTF-16BE, UTF-32(LE) = UCS4, UTF-32BE, UCS4 unusual octet order 2143, UCS4 unusual octet order 3412, UTF-1, UTF-7, UTF-EBCDIC, SCSU, BOCU-1
* 10 ANSI code pages (may be returned by Windows.GetACP): CP874, CP1250, CP1251, CP1252, CP1253, CP1254, CP1255, CP1256, CP1257, CP1258
* 4 another multy-byte encodings, that may be specified as default in POSIX systems: shift_jis, gb2312, ks_c_5601-1987, big5
* 23 single/multy-byte encodings, that also can be defined as "encoding" in XML/HTML: ibm866, iso-8859-2, iso-8859-3, iso-8859-4, iso-8859-5, iso-8859-6, iso-8859-7, iso-8859-8, iso-8859-10, iso-8859-13, iso-8859-14, iso-8859-15, iso-8859-16, koi8-r, koi8-u, macintosh, x-mac-cyrillic, x-user-defined, gb18030, hz-gb-2312, euc-jp, iso-2022-jp, euc-kr
* Raw data

##### Conversion context
The main library type is `TUniConvContext`. It allows converting of text from one encoding into another changing, if needed, insensitive "on-the-fly". For identification of encoding the number of code page is used. And as for some encodings the code page number is not provided in the library there are defined several ‘fake’ code pages (e.g.  for encoding `UTF-1` and `UCS-2143`). The type `TUniConv Context` is `an object`, which means it does not require constructors and destructors. It is enough to declare as a usual variable and call necessary methods.

For initialization of `TUniConvContext` the `Init` (takes as a parameter code pages and case sensitivity) method is used. Alternative `Init` takes byte order mark (`TBOM`) what is convenient for reading and writing of text files. In addition initializing `TBOM` much less possible encodings are analyzed so that the size of the output binary file will be approximately 50 KB less. If the conversion takes place between the UTF-8, UTF-16 or a single-byte character set, you can initialize by such methods as the `InitUTF16FromSBCS` or `InitUTF8FromSBCS`.

To make the conversion, you need to assign the `Source`, `SourceSize`, `Destination`, `DestinationSize` fields and call the `Convert` function. After the conversion `SourceRead` and `DestinationWritten` fields will be filled. For convenience, there are two more species `Convert` functions, which assign the necessary fields automatically.

`TUniConvContext` allows sequential processing of large files, using small memory buffers. There may be occasions when converted characters do not fit in the `Destination` buffer or vice versa `Source` buffer is too small to read a character at the end of the buffer. In these cases, `TUniConvContext` will contain the latest stable state, and the `Convert` function will return integer value, by which it is possible to determine how the conversion process took place. Null means that the conversion was successful. Positive - `Destination` means that buffer is too small. Negative - `Source` means that buffer is too small to read a character at the end of the buffer. Some encodings (e.g. UTF-7, BOCU-1, iso-2022-jp) use "state", which is important for the conversion of text in parts. However, you can call `ResetState` if there is a need to start the conversion again. `ModeFinalize` property (default value is `True`) is important for the encodings that use "state", as in the case of the end of conversion into `Destination` a few bytes are being written. Do not forget to set `ModeFinalize` property to `False` value if it is assumed that the data of `Source` is not ended. In the case of `ModeFinalize = True` and successful conversion - `ResetState` is called automatically.

In some cases (e.g. when generating XML, HTML or JSON) it is necessary to determine whether it is possible to use the destination encoding to write a character. In these cases one of the kinds of `Convertible` functions can help you.  
```pascal
type
  // case sensitivity
  TCharCase = (ccOriginal, ccLower, ccUpper);

  // byte order mark
  TBOM = (bomNone, bomUTF8, bomUTF16, bomUTF16BE, bomUTF32, bomUTF32BE, bomUCS2143, bomUCS3412, bomUTF1, bomUTF7, bomUTFEBCDIC, bomSCSU, bomBOCU1, bomGB18030);

var
  // automatically defined default code page
  CODEPAGE_DEFAULT: Word;

const
  // non-defined (fake) code page identifiers
  CODEPAGE_UCS2143 = 12002;
  CODEPAGE_UCS3412 = 12003;
  CODEPAGE_UTF1 = 65002;
  CODEPAGE_UTFEBCDIC = 65003;
  CODEPAGE_SCSU = 65004;
  CODEPAGE_BOCU1 = 65005;
  CODEPAGE_USERDEFINED = $fffd;
  CODEPAGE_RAWDATA = $ffff;
  
type  
  TUniConvContext = object
  public
    // "constructors"
    procedure Init(const ADestinationCodePage, ASourceCodePage: Word; const ACharCase: TCharCase); 
    procedure Init(const ADestinationBOM, ASourceBOM: TBOM; const SBCSCodePage: Word; const ACharCase: TCharCase); 

    // context properties
    property DestinationCodePage: Word read
    property SourceCodePage: Word read
    property CharCase: TCharCase read
    property ModeFinalize: Boolean read/write
    procedure ResetState;

    // character convertibility
    function Convertible(const C: UCS4Char): Boolean;
    function Convertible(const C: UnicodeChar): Boolean;
    
    // conversion parameters
    property Destination: Pointer read/write
    property DestinationSize: NativeUInt read/write
    property Source: Pointer read/write
    property SourceSize: NativeUInt read/write
    
    // conversion
    function Convert: NativeInt;     
    function Convert(const ADestination: Pointer;
                     const ADestinationSize: NativeUInt;
                     const ASource: Pointer;
                     const ASourceSize: NativeUInt): NativeInt;
    function Convert(const ADestination: Pointer;
                     const ADestinationSize: NativeUInt;
                     const ASource: Pointer;
                     const ASourceSize: NativeUInt;
                     out ADestinationWritten: NativeUInt;
                     out ASourceRead: NativeUInt): NativeInt; 
                     
    // "out" information
    property DestinationWritten: NativeUInt read
    property SourceRead: NativeUInt read
  end;
```
##### Lookup tables
One of the key priorities of the UniConv library is the maximum performance. That is why these primitives are frequently used - hash and lookup tables. Some of them you can use directly in your algorithms. The most glaring example - `UNICONV_CHARCASE` lookup, when by simple table conversion, you can change the case of `UnicodeChar`. For example `UNICONV_CHARCASE.LOWER['U'] = 'u'`, and `UNICONV_CHARCASE.UPPER['n'] = 'N'`. Another example of lookup table - `UNICONV_UTF8CHAR_SIZE`. UTF-8 is designed so that by the first byte you can determine the character length. The range from 1 to 6 is permitted, but the Unicode consortium has restricted the number of characters in a way that only values from 1 to 4 are relevant. Values of the first byte `128..191`, `254` and `255` are not provide by UTF-8 encoding, their "length" in the `UNICONV_UTF8CHAR_SIZE` will be zero.

In the library UniConv special attention is given to single-byte character set (**SBCS**) encodings. In Delphi, to these encodings correspond `AnsiChar` and `AnsiString` types. For each supported SBCS corresponds `TUniConvSBCS` type, inside which there are several lookup tables, designed for quick conversion of characters. `LowerCase` and `UpperCase` allow you to change character case `AnsiChar -> AnsiChar`. To convert `AnsiChar -> UnicodeChar` `UCS2`, `LowerCaseUCS2` and `UpperCaseUCS2` are used. To convert `AnsiChar -> UTF8Char (Cardinal)` `UTF8`, `LowerCaseUTF8` and `UpperCaseUTF8` are used. The length of the destination of the character is from 1 to 3 and written in high byte (`Cardinal shr 24`). To convert `UnicodeChar -> (best-fit) AnsiChar` use a lookup table `VALUES`. To convert from one SBCS to another (`AnsiChar --> AnsiChar`) use the `FromSBCS`.

To find `TUniConvSBCS` by code page is possible with the help of `UniConvSBCS` and `UniConvSBCSIndex` functions. If SBCS is not found - default value returns (`Raw data = code page $FFFF`). In order to determine whether the code page is supported by SBCS - use the `UniConvIsSBCS`.
```pascal
type
  TUniConvSBCS = object
  public
    // information
    property Index: Word read
    property CodePage: Word read

    // lower/upper single-byte tables
    property LowerCase: PUniConvSS
    property UpperCase: PUniConvSS

    // basic unicode tables
    property UCS2: PUniConvUS read
    property UTF8: PUniConvMS read
    property VALUES: PUniConvSBCSValues read

    // lower/upper unicode tables
    property LowerCaseUCS2: PUniConvUS read
    property UpperCaseUCS2: PUniConvUS read
    property LowerCaseUTF8: PUniConvMS read
    property UpperCaseUTF8: PUniConvMS read

    // single-byte lookup from another encoding
    function FromSBCS(const Source: PUniConvSBCS; const CharCase: TCharCase): PUniConvSS;  
  end;
  
var
  DEFAULT_UNICONV_SBCS: PUniConvSBCS;
  DEFAULT_UNICONV_SBCS_INDEX: NativeUInt;
  UNICONV_SUPPORTED_SBCS: array[0..28] of TUniConvSBCS;
  
  function UniConvIsSBCS(const CodePage: Word): Boolean;
  function UniConvSBCS(const CodePage: Word): PUniConvSBCS;
  function UniConvSBCSIndex(const CodePage: Word): NativeUInt;
```
##### Compiler independent char/string types
The library UniConv gives special attention to the UTF-8, UTF-16 and SBCS (Ansi) encodings, since they are used more often. There are several standard types to work with them, but on the mobile platforms (`NEXTGEN compilers`) there is only one string type - `UnicodeString`. For ease of programming on multiple platforms in the library announced such types as the `AnsiChar`, `AnsiString`, `UTF8String`, `RawByteString`, `WideString` and `ShortString`. Be careful when using them, because on mobile platforms they are emulated through static/dinamic arrays, characters enumeration can start from zero, and the character constant can be ordinal type.

##### String types conversion
The library provides a great number of functions to change the case of letters, as well as converting of strings in UTF-8, UTF-16 and SBCS (Ansi). Note that no matter `procedure` and `function` interface exist both, using **function** on code sections demanding performance is **not recommended**. This is due to the fact that the Delphi compiler generates for `function: StringType` which is not a very efficient code.

Besides, be careful when using the type `AnsiString`. If the code page is different from the default (e.g. `AnsiString(1253)`), calling convert functions **use explicit conversion** to `AnsiString` (e.g. `utf16_from_sbcs(Result, AnsiString(MyGreekString));`). This is due to the fact that Delphi compiler automatically converts `AnsiString(1253)` into `AnsiString`, which will lead to data and productivity loss. For the same reason, try to avoid conversions when `AnsiString` returns as a function result.
```pascal
  // examples
  procedure utf16_from_utf8(var Dest: UnicodeString; const Src: UTF8String);
  function utf16_from_utf8(const Src: UTF8String): UnicodeString;
  procedure sbcs_from_utf16_upper(var Dest: AnsiString; const Src: UnicodeString; const CodePage: Word = 0);
  function sbcs_from_utf16_upper(const Src: UnicodeString; const CodePage: Word = 0): AnsiString;  
  procedure utf8_from_sbcs_lower(var Dest: UTF8String; const Src: AnsiString);
  function utf8_from_sbcs_lower(const Src: AnsiString): UTF8String;
  procedure utf16_from_utf16_upper(var Dest: UnicodeString; const Src: UnicodeString);
  function utf16_from_utf16_upper(const Src: UnicodeString): UnicodeString;
```
##### String types comparison
For the encodings of UTF-8, UTF-16 and SBCS(Ansi) UniConv library contains many functions that allow comparing strings among) themselves without preliminary conversion into a universal encoding. All comparison functions are divided into `equal` and `compare`, common and `ignorecase`. If you need to compare two strings for equality then use `equal` option function as it is faster than `compare`. If string comparison is necessary to make case insensitive - use `ignorecase`. The UniConv library allows comparison between SBCS(Ansi) strings in different encodings. However, if you are sure that the encoding of such strings are the same - it is recommended to use `samesbcs`-functions.

For `AnsiString` types with non-default code page (e.g. `AnsiString(1253)`), calling the comparing function, **use explicit conversion** in `AnsiString` (e.g. `utf8_compare_sbcs_ignorecase(MyUTF8String, AnsiString(MyGreekString));`).
```pascal
  // examples
  function utf16_equal_utf8(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf16_equal_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf8_compare_sbcs(const S1: UTF8String; const S2: AnsiString): NativeInt;
  function utf8_compare_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString): NativeInt;  
  function sbcs_equal_samesbcs(const S1: AnsiString; const S2: AnsiString): Boolean;
  function sbcs_compare_samesbcs_ignorecase(const S1: AnsiString; const S2: AnsiString): NativeInt; 
```