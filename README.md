# UniConv

UniConv - быстрая универсальная и компактная библиотека, предназначенная для конвертации, сравнения и изменения регистра текста в соответствии с последними стандартами консорциума Unicode. Функционал библиотеки во многом похож на ICU, libiconv и Windows.kernel, де-факто являющихся стандартными для популярных операционных систем. Причин для разработки и использования UniConv несколько:
* Ни одна из библиотек не поддерживает [полный список](http://www.w3.org/TR/2008/REC-xml-20081126/#sec-guessing-no-ext-info) byte order mark ([BOM](http://en.wikipedia.org/wiki/Byte_order_mark)) 
* Ни одна из библиотек не поддерживает [полный список кодировок](http://www.w3.org/TR/2014/WD-encoding-20140128/#encodings), предусмотренных стандартами XML и HTML
* Не существует универсального "best-fit" behavior for single-byte character sets. Результаты преобразований различаются не только для разных библиотек, но и для разных code pages внутри одной библиотеки
* Отсутствуют функции сравнения между строками в разных кодировках "on-the-fly". Например между UTF-16 и UTF-8. Или Windows-1251 и Windows-1252.
* Интерфейс библиотек плохо приспособлен для sequential обработки больших текстовых файлов
* Библиотеки сконструированы из соображения универсальности, но не максимальной performance
* Идентичность преобразований не гарантируется. Например CFStringUppercase, u_strToUpper и CharUpperBuffW по-разному обрабатывают некоторые characters. Даже CharUpperBuffW на Windows XP и Windows 10 может выдать различные результаты

Примеры использования библиотеки вы можете найти в демонстрационных проектах: [Demo.zip]( http://dmozulyov.ucoz.net/UniConv/Demo.zip)
![](http://dmozulyov.ucoz.net/UniConv/ScreenShots.png)

##### Supported encodings
UniConv поддерживает 50 encodings:
* 12 Unicode encodings: UTF-8, UTF-16(LE) ~ UCS2, UTF-16BE, UTF-32(LE) = UCS4, UTF-32BE, UCS4 unusual octet order 2143, UCS4 unusual octet order 3412, UTF-1, UTF-7, UTF-EBCDIC, SCSU, BOCU-1
* 10 ANSI code pages (may be returned by Windows.GetACP): CP874, CP1250, CP1251, CP1252, CP1253, CP1254, CP1255, CP1256, CP1257, CP1258
* 4 another multy-byte encodings, that may be specified as default in POSIX systems: shift_jis, gb2312, ks_c_5601-1987, big5
* 23 single/multy-byte encodings, that also can be defined as "encoding" in XML/HTML: ibm866, iso-8859-2, iso-8859-3, iso-8859-4, iso-8859-5, iso-8859-6, iso-8859-7, iso-8859-8, iso-8859-10, iso-8859-13, iso-8859-14, iso-8859-15, iso-8859-16, koi8-r, koi8-u, macintosh, x-mac-cyrillic, x-user-defined, gb18030, hz-gb-2312, euc-jp, iso-2022-jp, euc-kr
* Raw data

##### Conversion context
Главный тип библиотеки - `TUniConvContext`. Он позволяет осуществить конвертацию текста из одной кодировки в другую, изменяя при необходимости регистр символов "on-the-fly". Для идентификации кодировки используется номер кодовой страницы. И так как для некоторых кодировок не предусмотрен номер кодовой страницы, в библиотеке объявлены несколько "фейковых" кодовых страниц, для кодировок `UTF-1` и `UCS-2143` например. Тип `TUniConvContext` это `object`, а значит для него не нужно вызывать конструкторов и деструктуров, достаточно объявить как обычную переменную и вызывать необходимые методы.

Для инициализации `TUniConvContext` используется метод `Init`, принимая в качестве параметров кодовые страницы и case sensitivity. Альтернативный `Init` принимает byte order mark (`TBOM`), что бывает удобно при чтении и writing текстовых файлов. Кроме того при инициализации `TBOM` анализируется значительно меньше возможных кодировок, поэтому размер выходного бинарного файла будет примерно на 50KB меньше. Если конвертация происходит между UTF-8, UTF-16 или single-byte character set, вы можете производить инициализацию такими методами например как `InitUTF16FromSBCS` или `InitUTF8FromSBCS`.

Чтобы произвести конвертацию, необходимо заполнить fields `Source`, `SourceSize`, `Destination`, `DestinationSize` и вызвать функцию `Convert`. После конвертации будут заполнены fields `SourceRead` and `DestinationWritten`. Для удобства существуют ещё две разновидности функции `Convert`, заполняющие соответствующие fields.

`TUniConvContext` позволяет осуществлять sequential обработку больших файлов, используя при этом малые буферы памяти. Возможны случаи, когда converted characters не умещаются в `Destination` буфер или наоборот `Source` буфер слишком мал, чтобы прочитать символ в конце буфера. В этих случаях `TUniConvContext` будет содержать последнее stable state, а функция `Convert` вернёт integer value, по которому можно определить, как прошёл процесс конвертации. Null - конвертация прошла успешно. Positive - `Destination` буфер слишком мал. Negative - `Source` буфер слишком мал, чтобы прочитать символ в конце буфера. Некоторые кодировки (такие например как UTF-7, BOCU-1, iso-2022-jp) используют "state", которое важно при конвертации текста по частям. Однако вы можете вызывать `ResetState` если есть необходимость начать конвертацию заново. `ModeFinalize` property (default value is `True`) имеет значение для кодировок, использующих "state", поскольку в случае окончания конвертации в `Destination` дописывается несколько байт. Не забывайте set `ModeFinalize` property to `False` value если предполагается, что `Source` данные не закончились. В случае `ModeFinalize = True` и успешной конвертации - `ResetState` вызывается автоматически.

В некоторых случаях (например при генерации XML, HTML или JSON) возникает необходимость определить, возможно ли с помощью destination encoding записать character. В этих случаях вам поможет один из вариантов функции `Convertible`.
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
Одним из ключевых приоритетов библиотеки UniConv является максимальная performance. Поэтому часто используются быстрые primitives - hash and lookup tables. Часть из них вы можете использовать directly в своих алгоритмах. Самый яркий пример - `UNICONV_CHARCASE` lookup, когда простым табличным преобразованием можно изменить регистр `UnicodeChar`. Например `UNICONV_CHARCASE.LOWER['U'] = 'u'`, а `UNICONV_CHARCASE.UPPER['n'] = 'N'`. Ещё один пример lookup таблицы - `UNICONV_UTF8_SIZE`. Кодировка UTF-8 спроектирована таким образом, что по первому байту можно определить длину символа. Допустимы значения от 1 до 6, однако консорциум Unicode ограничил число символов таким образом, что актуальны значения только от 1 до 4. Значения первого байта `128..191`, `254` и `255` не предусмотренны кодировкой UTF-8, их "длина" в `UNICONV_UTF8_SIZE` будет равна нулю.

Особое внимание в библиотеке UniConv уделено single-byte character set (**SBCS**) encodings. В Delphi этим encodings соответствуют типы `AnsiChar` и `AnsiString`. Каждой поддерживаемой SBCS соответствует тип `TUniConvSBCS`, внутри которого содержится несколько lookup tables, предназначенных для быстрой конвертации characters. `LowerCase` и `LowerCase` позволяют изменить character case `AnsiChar --> AnsiChar`. Для преобразования `AnsiChar --> UnicodeChar` используются `UCS2`, `LowerCaseUCS2` и `UpperCaseUCS2`. Для преобразования `AnsiChar --> UTF8Char(Cardinal)` используются `UTF8`, `LowerCaseUTF8` и `UpperCaseUTF8`. Длинна destination символа равна от 1 до 3 и written in high byte (`Cardinal shr 24`). Для преобразования `UnicodeChar --> (best-fit) AnsiChar` используйте lookup table `VALUES`. Для преобразования из одной SBCS в другую (`AnsiChar --> AnsiChar`) используйте функцию `FromSBCS`.

Найти `TUniConvSBCS` по code page можно с помощью функций `UniConvSBCS` и `UniConvSBCSIndex`. В случае если SBCS не найден - возвращается default value (`Raw data = сode page $FFFF`). Для того чтобы определить, является ли code page поддерживаемой SBCS - используйте функцию `UniConvIsSBCS`.
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
В библиотеке UniConv особое внимание уделяется кодировкам UTF-8, UTF-16 и SBCS(Ansi), так как их используют чаще всего. Существует несколько стандартных типов для работы с ними, однако на mobile platforms (`NEXTGEN compilers`) существует только один строковый тип - `UnicodeString`. Для удобства программирования на нескольких платформах в библиотеке дополнительно объявлены такие типы как `AnsiChar`, `AnsiString`, `UTF8String`, `RawByteString`, `WideString` и `ShortString`. Будьте осторожны при их использовании, потому что на mobile platforms они эмулируются через static/dinamic arrays, нумерация символов может начинаться с нуля, а символьная константа может быть ordinal type.

##### String types conversion
Библиотека предоставляет большое количество функций для изменения регистра букв, а так же преобразования строк в кодировках UTF-8, UTF-16 и SBCS(Ansi). Обратите внимание, не смотря на то, что существует как `procedure` интерфейс, так и `function`, использовать **function не рекомендуется** на участках кода, требовательных к производительности. Связано это с тем, что Delphi compiler генериует для `function: StringType` не очень эффективный код.

Кроме того, будьте осторожны при использовании типа `AnsiString`. Если code page отличается от default (например `AnsiString(1253)`), вызывая конвертирующие функции, **используйте явное преобразование** в `AnsiString` (например `utf16_from_sbcs(Result, AnsiString(MyGreekString));`). Это связано с тем, что Delphi compiler автоматически преобразует `AnsiString(1253)` в `AnsiString`, что приведёт и к потере данных, и к потере производительности. По той же причине старайтесь избегать конвертаций, когда `AnsiString` возвращается в качестве function result.
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
Для кодировок UTF-8, UTF-16 и SBCS(Ansi) библиотека UniConv содержит множество функций, позволяющих сравнивать между собой строки, без предварительной конвертации в универсальную кодировку. Все функции сравнения делятся на `equal` и `compare`, обычные и `ignorecase`. Если вам нужно сравнить две строки на равенство, то используйте `equal` вариант функции, он быстрее, чем `compare`. Если сравнения строк необходимо произвести без учёта регистра - используйте `ignorecase`.

Для `AnsiString` типов с не-default code page (например `AnsiString(1253)`), вызывая сравнивающие функции, **используйте явное преобразование** в `AnsiString` (например `utf8_compare_sbcs_ignorecase(MyUTF8String, AnsiString(MyGreekString));`).
```pascal
  // examples
  function utf16_equal_utf8(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf16_equal_utf8_ignorecase(const S1: UnicodeString; const S2: UTF8String): Boolean;
  function utf8_compare_sbcs(const S1: UTF8String; const S2: AnsiString): NativeInt;
  function utf8_compare_sbcs_ignorecase(const S1: UTF8String; const S2: AnsiString): NativeInt;  
```