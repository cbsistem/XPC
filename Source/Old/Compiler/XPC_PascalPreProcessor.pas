{
	XPC_PascalPreProcessor.pas
  Copyright (c) 2015 by Sergio Flores <relfos@gmail.com>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}
Unit XPC_PascalPreProcessor;

{$I terra.inc}

Interface
Uses XPC_Lexer, TERRA_Utils, TERRA_OS, TERRA_IO, TERRA_Error, TERRA_FileIO, TERRA_Collections;

Const
  MaxStates = 128;
  


const INITIAL = 2;
const XCOMMENT1 = 4;
const XCOMMENT2 = 6;
const XNOTDEF = 8;


  
Type
  PascalPreProcessor = Class(CustomLexer)
    Protected            
        _Output:Stream;
        
        Procedure yyaction ( yyruleno : Integer ); Override;
      
        Function yywrap:Boolean; Override;

        Procedure CheckSourceNewline();
        
    Public
        Constructor Create(Source:Stream);
        Destructor Destroy; Override;

        Property CurrentLine:Integer Read yylineno;
        Property CurrentRow:Integer Read yycolno;
      
        Function Parse:Integer; Override;
        
        Property Output:Stream Read _Output;
  End;

Implementation

{ PascalPreProcessor }
Constructor PascalPreProcessor.Create(Source:Stream);
Begin
    _Output := MemoryStream.Create();
End;

Function PascalPreProcessor.yywrap:Boolean; 
Begin
    Case _CurrentState Of
    XCOMMENT1,
    XCOMMENT2:
        Begin 
            RaiseError('Unterminated comment');         
        End;
        
    XNOTDEF:        
        Begin 
            RaiseError('Unterminated ifdef');         
        End;
        
    End;
End;

// Emit newline if the current stream is the original src file
Procedure PascalPreProcessor.CheckSourceNewline();
Begin
    If (Not yymoreStreams()) Then
        _Output.WriteChars(NL);
End;

Procedure PascalPreProcessor.yyaction(yyruleno : Integer );
  (* local definitions: *)


begin
  (* actions: *)
  case yyruleno of
  1:				Begin End;
  2:					Begin yypushstate(XCOMMENT1); End;
  3:				Begin yypushstate(XCOMMENT2); End;

  4:		Begin yypopstate(); End;
  5:		Begin yypopstate(); End;

  6:		Begin End;
  7:			Begin End;
  8:				Begin CheckSourceNewline(); End;
  9:				Begin End;


  10:		Begin End;
  11:			Begin End;
  12:				Begin CheckSourceNewline(); End;
  13:				Begin End;

  14:		Begin
						string ifile = GetDirectiveArg("i");
						string inctext = FetchInclude(ifile);
						
						if (inctext == null)
						Begin
                            pperror("Include file " + ifile + " not found");
							break;
						End;

						StringReader sr = new StringReader(inctext);
						yypushStream(sr);
						yydebug("Pushed stream from " + ifile + "");
					End;

	{ defines }
  15:	Begin	AddDefine(GetDirectiveArg("define"));	End;

  16:	Begin	RemoveDefine(GetDirectiveArg("undef"));	End;

  17:	Begin	
                        if (!IsDefinedDir("ifdef")) Then
                            yypushstate(XNOTDEF);
					End;

  18:	Begin
                        if (!IsDefinedDir("ifopt"))
							yypushstate(XNOTDEF);
					End;

  19:	Begin
                        Boolean defined = IsDefined(GetDirectiveArg("ifndef"));
						defines.Push(!defined);
						if (defined)
							yypushstate(XNOTDEF);
					End;

  20:		Begin
                        // currently in a defined section, switch to non-defined
						defines.Pop();
						defines.Push(false);
						yypushstate(XNOTDEF);
					End;

  21:	Begin defines.Pop(); End;


  22:			Begin End;

  23:				Begin End;
  24:					Begin yypushstate(XCOMMENT1); End;
  25:				Begin yypushstate(XCOMMENT2); End;
 
  26:	Begin defines.Push(true); End;

  27:	Begin defines.Push(true); End;

  28:	Begin defines.Push(true); End;

  29:	Begin	if (defines.Peek() == false)	// at the non-def section start, must leave
                                Begin	yypopstate();
							defines.Pop();
							defines.Push(true);
                                End; // else, leave the top def as true
					End;

  30:	Begin	Boolean def = defines.Pop(); 
						if (def == false)
							yypopstate();
					End;
 
  31:			Begin { chomp up as much as possible in one match} End;
  32:				Begin CheckSourceNewline(); End;
  33:					Begin  { ignore everything in a non-def section } End;


  34:			Begin outBuilder.Append(zzBuffer, zzStartRead, zzMarkedPos-zzStartRead); End;

  35:	Begin
                        if (zzBuffer[zzMarkedPos-1] != '\'')	// if last char not quote
							pperror("Unterminated string");
						else
							outBuilder.Append(zzBuffer, zzStartRead, zzMarkedPos-zzStartRead);
					End;

  36:			Begin outBuilder.Append(yycharat(0)); End;
  37:				Begin CheckSourceNewline(); End;

  38:					Begin pperror("Unknown char: " + text + " (ASCII " + ((int) text[0]) +")"); End

  end;
end(*yyaction*);

(* DFA table: *)

type YYTRec = record
                cc : set of Char;
                s  : Integer;
              end;

const

yynmarks   = 142;
yynmatches = 142;
yyntrans   = 246;
yynstates  = 145;

yyk : array [1..yynmarks] of Integer = (
  { 0: }
  { 1: }
  { 2: }
  { 3: }
  { 4: }
  { 5: }
  { 6: }
  { 7: }
  { 8: }
  { 9: }
  { 10: }
  36,
  38,
  { 11: }
  2,
  38,
  { 12: }
  36,
  38,
  { 13: }
  34,
  38,
  { 14: }
  38,
  { 15: }
  36,
  38,
  { 16: }
  37,
  38,
  { 17: }
  37,
  { 18: }
  38,
  { 19: }
  9,
  36,
  38,
  { 20: }
  2,
  9,
  38,
  { 21: }
  9,
  36,
  38,
  { 22: }
  4,
  9,
  38,
  { 23: }
  6,
  9,
  34,
  38,
  { 24: }
  6,
  7,
  9,
  34,
  38,
  { 25: }
  7,
  9,
  36,
  38,
  { 26: }
  8,
  9,
  37,
  38,
  { 27: }
  8,
  37,
  { 28: }
  9,
  38,
  { 29: }
  7,
  9,
  38,
  { 30: }
  13,
  36,
  38,
  { 31: }
  2,
  13,
  38,
  { 32: }
  13,
  36,
  38,
  { 33: }
  10,
  11,
  13,
  34,
  38,
  { 34: }
  10,
  13,
  34,
  38,
  { 35: }
  11,
  13,
  36,
  38,
  { 36: }
  12,
  13,
  37,
  38,
  { 37: }
  12,
  37,
  { 38: }
  13,
  38,
  { 39: }
  11,
  13,
  38,
  { 40: }
  33,
  36,
  38,
  { 41: }
  2,
  24,
  33,
  38,
  { 42: }
  33,
  36,
  38,
  { 43: }
  31,
  33,
  34,
  38,
  { 44: }
  32,
  33,
  37,
  38,
  { 45: }
  32,
  37,
  { 46: }
  33,
  38,
  { 47: }
  33,
  38,
  { 48: }
  33,
  36,
  38,
  { 49: }
  1,
  { 50: }
  { 51: }
  3,
  { 52: }
  34,
  { 53: }
  { 54: }
  35,
  { 55: }
  35,
  { 56: }
  5,
  { 57: }
  1,
  23,
  { 58: }
  { 59: }
  3,
  25,
  { 60: }
  31,
  34,
  { 61: }
  { 62: }
  { 63: }
  { 64: }
  { 65: }
  { 66: }
  { 67: }
  { 68: }
  { 69: }
  { 70: }
  22,
  { 71: }
  { 72: }
  { 73: }
  { 74: }
  { 75: }
  { 76: }
  { 77: }
  { 78: }
  { 79: }
  { 80: }
  { 81: }
  { 82: }
  { 83: }
  { 84: }
  { 85: }
  { 86: }
  { 87: }
  { 88: }
  { 89: }
  { 90: }
  { 91: }
  14,
  { 92: }
  { 93: }
  { 94: }
  { 95: }
  { 96: }
  { 97: }
  { 98: }
  { 99: }
  { 100: }
  { 101: }
  { 102: }
  { 103: }
  { 104: }
  { 105: }
  { 106: }
  { 107: }
  { 108: }
  { 109: }
  20,
  { 110: }
  { 111: }
  { 112: }
  { 113: }
  { 114: }
  20,
  29,
  { 115: }
  { 116: }
  { 117: }
  { 118: }
  { 119: }
  { 120: }
  { 121: }
  21,
  { 122: }
  { 123: }
  { 124: }
  { 125: }
  21,
  30,
  { 126: }
  { 127: }
  { 128: }
  { 129: }
  { 130: }
  { 131: }
  { 132: }
  { 133: }
  { 134: }
  17,
  { 135: }
  18,
  { 136: }
  { 137: }
  { 138: }
  16,
  { 139: }
  17,
  26,
  { 140: }
  18,
  27,
  { 141: }
  { 142: }
  19,
  { 143: }
  15,
  { 144: }
  19,
  28
);

yym : array [1..yynmatches] of Integer = (
{ 0: }
{ 1: }
{ 2: }
{ 3: }
{ 4: }
{ 5: }
{ 6: }
{ 7: }
{ 8: }
{ 9: }
{ 10: }
  36,
  38,
{ 11: }
  2,
  38,
{ 12: }
  36,
  38,
{ 13: }
  34,
  38,
{ 14: }
  38,
{ 15: }
  36,
  38,
{ 16: }
  37,
  38,
{ 17: }
  37,
{ 18: }
  38,
{ 19: }
  9,
  36,
  38,
{ 20: }
  2,
  9,
  38,
{ 21: }
  9,
  36,
  38,
{ 22: }
  4,
  9,
  38,
{ 23: }
  6,
  9,
  34,
  38,
{ 24: }
  6,
  7,
  9,
  34,
  38,
{ 25: }
  7,
  9,
  36,
  38,
{ 26: }
  8,
  9,
  37,
  38,
{ 27: }
  8,
  37,
{ 28: }
  9,
  38,
{ 29: }
  7,
  9,
  38,
{ 30: }
  13,
  36,
  38,
{ 31: }
  2,
  13,
  38,
{ 32: }
  13,
  36,
  38,
{ 33: }
  10,
  11,
  13,
  34,
  38,
{ 34: }
  10,
  13,
  34,
  38,
{ 35: }
  11,
  13,
  36,
  38,
{ 36: }
  12,
  13,
  37,
  38,
{ 37: }
  12,
  37,
{ 38: }
  13,
  38,
{ 39: }
  11,
  13,
  38,
{ 40: }
  33,
  36,
  38,
{ 41: }
  2,
  24,
  33,
  38,
{ 42: }
  33,
  36,
  38,
{ 43: }
  31,
  33,
  34,
  38,
{ 44: }
  32,
  33,
  37,
  38,
{ 45: }
  32,
  37,
{ 46: }
  33,
  38,
{ 47: }
  33,
  38,
{ 48: }
  33,
  36,
  38,
{ 49: }
  1,
{ 50: }
{ 51: }
  3,
{ 52: }
  34,
{ 53: }
{ 54: }
  35,
{ 55: }
  35,
{ 56: }
  5,
{ 57: }
  1,
  23,
{ 58: }
{ 59: }
  3,
  25,
{ 60: }
  31,
  34,
{ 61: }
{ 62: }
{ 63: }
{ 64: }
{ 65: }
{ 66: }
{ 67: }
{ 68: }
{ 69: }
{ 70: }
  22,
{ 71: }
{ 72: }
{ 73: }
{ 74: }
{ 75: }
{ 76: }
{ 77: }
{ 78: }
{ 79: }
{ 80: }
{ 81: }
{ 82: }
{ 83: }
{ 84: }
{ 85: }
{ 86: }
{ 87: }
{ 88: }
{ 89: }
{ 90: }
{ 91: }
  14,
{ 92: }
{ 93: }
{ 94: }
{ 95: }
{ 96: }
{ 97: }
{ 98: }
{ 99: }
{ 100: }
{ 101: }
{ 102: }
{ 103: }
{ 104: }
{ 105: }
{ 106: }
{ 107: }
{ 108: }
{ 109: }
  20,
{ 110: }
{ 111: }
{ 112: }
{ 113: }
{ 114: }
  20,
  29,
{ 115: }
{ 116: }
{ 117: }
{ 118: }
{ 119: }
{ 120: }
{ 121: }
  21,
{ 122: }
{ 123: }
{ 124: }
{ 125: }
  21,
  30,
{ 126: }
{ 127: }
{ 128: }
{ 129: }
{ 130: }
{ 131: }
{ 132: }
{ 133: }
{ 134: }
  17,
{ 135: }
  18,
{ 136: }
{ 137: }
{ 138: }
  16,
{ 139: }
  17,
  26,
{ 140: }
  18,
  27,
{ 141: }
{ 142: }
  19,
{ 143: }
  15,
{ 144: }
  19,
  28
);

yyt : array [1..yyntrans] of YYTrec = (
{ 0: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 18),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 13),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ #13 ]; s: 16),
  ( cc: [ '''' ]; s: 14),
  ( cc: [ '(' ]; s: 12),
  ( cc: [ ')' ]; s: 15),
  ( cc: [ '/' ]; s: 10),
  ( cc: [ '{' ]; s: 11),
{ 1: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 18),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 13),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ #13 ]; s: 16),
  ( cc: [ '''' ]; s: 14),
  ( cc: [ '(' ]; s: 12),
  ( cc: [ ')' ]; s: 15),
  ( cc: [ '/' ]; s: 10),
  ( cc: [ '{' ]; s: 11),
{ 2: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 18),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 13),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ #13 ]; s: 16),
  ( cc: [ '''' ]; s: 14),
  ( cc: [ '(' ]; s: 12),
  ( cc: [ ')' ]; s: 15),
  ( cc: [ '/' ]; s: 10),
  ( cc: [ '{' ]; s: 11),
{ 3: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 18),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 13),
  ( cc: [ #10 ]; s: 17),
  ( cc: [ #13 ]; s: 16),
  ( cc: [ '''' ]; s: 14),
  ( cc: [ '(' ]; s: 12),
  ( cc: [ ')' ]; s: 15),
  ( cc: [ '/' ]; s: 10),
  ( cc: [ '{' ]; s: 11),
{ 4: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|',
            '~'..#255 ]; s: 28),
  ( cc: [ #9,' ','!','#','$','&','+'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 23),
  ( cc: [ #10 ]; s: 27),
  ( cc: [ #13 ]; s: 26),
  ( cc: [ '''' ]; s: 29),
  ( cc: [ '(' ]; s: 21),
  ( cc: [ ')' ]; s: 25),
  ( cc: [ '*' ]; s: 24),
  ( cc: [ '/' ]; s: 19),
  ( cc: [ '{' ]; s: 20),
  ( cc: [ '}' ]; s: 22),
{ 5: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|',
            '~'..#255 ]; s: 28),
  ( cc: [ #9,' ','!','#','$','&','+'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 23),
  ( cc: [ #10 ]; s: 27),
  ( cc: [ #13 ]; s: 26),
  ( cc: [ '''' ]; s: 29),
  ( cc: [ '(' ]; s: 21),
  ( cc: [ ')' ]; s: 25),
  ( cc: [ '*' ]; s: 24),
  ( cc: [ '/' ]; s: 19),
  ( cc: [ '{' ]; s: 20),
  ( cc: [ '}' ]; s: 22),
{ 6: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 38),
  ( cc: [ #9,' ','!','#','$','&','+'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 34),
  ( cc: [ #10 ]; s: 37),
  ( cc: [ #13 ]; s: 36),
  ( cc: [ '''' ]; s: 39),
  ( cc: [ '(' ]; s: 32),
  ( cc: [ ')' ]; s: 35),
  ( cc: [ '*' ]; s: 33),
  ( cc: [ '/' ]; s: 30),
  ( cc: [ '{' ]; s: 31),
{ 7: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 38),
  ( cc: [ #9,' ','!','#','$','&','+'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 34),
  ( cc: [ #10 ]; s: 37),
  ( cc: [ #13 ]; s: 36),
  ( cc: [ '''' ]; s: 39),
  ( cc: [ '(' ]; s: 32),
  ( cc: [ ')' ]; s: 35),
  ( cc: [ '*' ]; s: 33),
  ( cc: [ '/' ]; s: 30),
  ( cc: [ '{' ]; s: 31),
{ 8: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 46),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 43),
  ( cc: [ #10 ]; s: 45),
  ( cc: [ #13 ]; s: 44),
  ( cc: [ '''' ]; s: 47),
  ( cc: [ '(' ]; s: 42),
  ( cc: [ ')' ]; s: 48),
  ( cc: [ '/' ]; s: 40),
  ( cc: [ '{' ]; s: 41),
{ 9: }
  ( cc: [ #1..#8,#11,#12,#14..#31,'"','%','?','`','|'..#255 ]; s: 46),
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 43),
  ( cc: [ #10 ]; s: 45),
  ( cc: [ #13 ]; s: 44),
  ( cc: [ '''' ]; s: 47),
  ( cc: [ '(' ]; s: 42),
  ( cc: [ ')' ]; s: 48),
  ( cc: [ '/' ]; s: 40),
  ( cc: [ '{' ]; s: 41),
{ 10: }
  ( cc: [ '/' ]; s: 49),
{ 11: }
  ( cc: [ '$' ]; s: 50),
{ 12: }
  ( cc: [ '*' ]; s: 51),
{ 13: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
{ 14: }
  ( cc: [ #1..#9,#11,#12,#14..'&','('..#255 ]; s: 53),
  ( cc: [ #10,'''' ]; s: 54),
  ( cc: [ #13 ]; s: 55),
{ 15: }
{ 16: }
  ( cc: [ #10 ]; s: 17),
{ 17: }
{ 18: }
{ 19: }
  ( cc: [ '/' ]; s: 49),
{ 20: }
  ( cc: [ '$' ]; s: 50),
{ 21: }
  ( cc: [ '*' ]; s: 51),
{ 22: }
{ 23: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
{ 24: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
{ 25: }
{ 26: }
  ( cc: [ #10 ]; s: 27),
{ 27: }
{ 28: }
{ 29: }
  ( cc: [ #1..#9,#11,#12,#14..'&','('..#255 ]; s: 53),
  ( cc: [ #10,'''' ]; s: 54),
  ( cc: [ #13 ]; s: 55),
{ 30: }
  ( cc: [ '/' ]; s: 49),
{ 31: }
  ( cc: [ '$' ]; s: 50),
{ 32: }
  ( cc: [ '*' ]; s: 51),
{ 33: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
  ( cc: [ ')' ]; s: 56),
{ 34: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
{ 35: }
{ 36: }
  ( cc: [ #10 ]; s: 37),
{ 37: }
{ 38: }
{ 39: }
  ( cc: [ #1..#9,#11,#12,#14..'&','('..#255 ]; s: 53),
  ( cc: [ #10,'''' ]; s: 54),
  ( cc: [ #13 ]; s: 55),
{ 40: }
  ( cc: [ '/' ]; s: 57),
{ 41: }
  ( cc: [ '$' ]; s: 58),
{ 42: }
  ( cc: [ '*' ]; s: 59),
{ 43: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 60),
{ 44: }
  ( cc: [ #10 ]; s: 45),
{ 45: }
{ 46: }
{ 47: }
  ( cc: [ #1..#9,#11,#12,#14..'&','('..#255 ]; s: 53),
  ( cc: [ #10,'''' ]; s: 54),
  ( cc: [ #13 ]; s: 55),
{ 48: }
{ 49: }
  ( cc: [ #1..#9,#11..#255 ]; s: 49),
{ 50: }
  ( cc: [ #1..'c','f'..'h','j'..'t','v'..'|','~'..#255 ]; s: 65),
  ( cc: [ 'd' ]; s: 62),
  ( cc: [ 'e' ]; s: 64),
  ( cc: [ 'i' ]; s: 61),
  ( cc: [ 'u' ]; s: 63),
{ 51: }
{ 52: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 52),
{ 53: }
  ( cc: [ #1..#9,#11,#12,#14..'&','('..#255 ]; s: 53),
  ( cc: [ #10,'''' ]; s: 54),
  ( cc: [ #13 ]; s: 55),
{ 54: }
{ 55: }
  ( cc: [ #10 ]; s: 54),
{ 56: }
{ 57: }
  ( cc: [ #1..#9,#11..#255 ]; s: 57),
{ 58: }
  ( cc: [ #1..'c','f'..'h','j'..'t','v'..'|','~'..#255 ]; s: 65),
  ( cc: [ 'd' ]; s: 62),
  ( cc: [ 'e' ]; s: 67),
  ( cc: [ 'i' ]; s: 66),
  ( cc: [ 'u' ]; s: 63),
{ 59: }
{ 60: }
  ( cc: [ #9,' ','!','#','$','&','*'..'.','0'..'>',
            '@'..'_','a'..'z' ]; s: 60),
{ 61: }
  ( cc: [ ' ' ]; s: 68),
  ( cc: [ 'f' ]; s: 69),
  ( cc: [ '}' ]; s: 70),
{ 62: }
  ( cc: [ 'e' ]; s: 71),
  ( cc: [ '}' ]; s: 70),
{ 63: }
  ( cc: [ 'n' ]; s: 72),
  ( cc: [ '}' ]; s: 70),
{ 64: }
  ( cc: [ 'l' ]; s: 73),
  ( cc: [ 'n' ]; s: 74),
  ( cc: [ '}' ]; s: 70),
{ 65: }
  ( cc: [ '}' ]; s: 70),
{ 66: }
  ( cc: [ ' ' ]; s: 68),
  ( cc: [ 'f' ]; s: 75),
  ( cc: [ '}' ]; s: 70),
{ 67: }
  ( cc: [ 'l' ]; s: 76),
  ( cc: [ 'n' ]; s: 77),
  ( cc: [ '}' ]; s: 70),
{ 68: }
  ( cc: [ #1..'|','~'..#255 ]; s: 78),
{ 69: }
  ( cc: [ 'd' ]; s: 79),
  ( cc: [ 'n' ]; s: 81),
  ( cc: [ 'o' ]; s: 80),
{ 70: }
{ 71: }
  ( cc: [ 'f' ]; s: 82),
{ 72: }
  ( cc: [ 'd' ]; s: 83),
{ 73: }
  ( cc: [ 's' ]; s: 84),
{ 74: }
  ( cc: [ 'd' ]; s: 85),
{ 75: }
  ( cc: [ 'd' ]; s: 86),
  ( cc: [ 'n' ]; s: 88),
  ( cc: [ 'o' ]; s: 87),
{ 76: }
  ( cc: [ 's' ]; s: 89),
{ 77: }
  ( cc: [ 'd' ]; s: 90),
{ 78: }
  ( cc: [ #1..'|','~'..#255 ]; s: 78),
  ( cc: [ '}' ]; s: 91),
{ 79: }
  ( cc: [ 'e' ]; s: 92),
{ 80: }
  ( cc: [ 'p' ]; s: 93),
{ 81: }
  ( cc: [ 'd' ]; s: 94),
{ 82: }
  ( cc: [ 'i' ]; s: 95),
{ 83: }
  ( cc: [ 'e' ]; s: 96),
{ 84: }
  ( cc: [ 'e' ]; s: 97),
{ 85: }
  ( cc: [ 'i' ]; s: 98),
{ 86: }
  ( cc: [ 'e' ]; s: 99),
{ 87: }
  ( cc: [ 'p' ]; s: 100),
{ 88: }
  ( cc: [ 'd' ]; s: 101),
{ 89: }
  ( cc: [ 'e' ]; s: 102),
{ 90: }
  ( cc: [ 'i' ]; s: 103),
{ 91: }
{ 92: }
  ( cc: [ 'f' ]; s: 104),
{ 93: }
  ( cc: [ 't' ]; s: 105),
{ 94: }
  ( cc: [ 'e' ]; s: 106),
{ 95: }
  ( cc: [ 'n' ]; s: 107),
{ 96: }
  ( cc: [ 'f' ]; s: 108),
{ 97: }
  ( cc: [ #1..'|','~'..#255 ]; s: 97),
  ( cc: [ '}' ]; s: 109),
{ 98: }
  ( cc: [ 'f' ]; s: 110),
{ 99: }
  ( cc: [ 'f' ]; s: 111),
{ 100: }
  ( cc: [ 't' ]; s: 112),
{ 101: }
  ( cc: [ 'e' ]; s: 113),
{ 102: }
  ( cc: [ #1..'|','~'..#255 ]; s: 102),
  ( cc: [ '}' ]; s: 114),
{ 103: }
  ( cc: [ 'f' ]; s: 115),
{ 104: }
  ( cc: [ ' ' ]; s: 116),
{ 105: }
  ( cc: [ ' ' ]; s: 117),
{ 106: }
  ( cc: [ 'f' ]; s: 118),
{ 107: }
  ( cc: [ 'e' ]; s: 119),
{ 108: }
  ( cc: [ ' ' ]; s: 120),
{ 109: }
{ 110: }
  ( cc: [ #1..'|','~'..#255 ]; s: 110),
  ( cc: [ '}' ]; s: 121),
{ 111: }
  ( cc: [ ' ' ]; s: 122),
{ 112: }
  ( cc: [ ' ' ]; s: 123),
{ 113: }
  ( cc: [ 'f' ]; s: 124),
{ 114: }
{ 115: }
  ( cc: [ #1..'|','~'..#255 ]; s: 115),
  ( cc: [ '}' ]; s: 125),
{ 116: }
  ( cc: [ #1..'|','~'..#255 ]; s: 126),
{ 117: }
  ( cc: [ #1..'|','~'..#255 ]; s: 127),
{ 118: }
  ( cc: [ ' ' ]; s: 128),
{ 119: }
  ( cc: [ ' ' ]; s: 129),
{ 120: }
  ( cc: [ #1..'|','~'..#255 ]; s: 130),
{ 121: }
{ 122: }
  ( cc: [ #1..'|','~'..#255 ]; s: 131),
{ 123: }
  ( cc: [ #1..'|','~'..#255 ]; s: 132),
{ 124: }
  ( cc: [ ' ' ]; s: 133),
{ 125: }
{ 126: }
  ( cc: [ #1..'|','~'..#255 ]; s: 126),
  ( cc: [ '}' ]; s: 134),
{ 127: }
  ( cc: [ #1..'|','~'..#255 ]; s: 127),
  ( cc: [ '}' ]; s: 135),
{ 128: }
  ( cc: [ #1..'|','~'..#255 ]; s: 136),
{ 129: }
  ( cc: [ #1..'|','~'..#255 ]; s: 137),
{ 130: }
  ( cc: [ #1..'|','~'..#255 ]; s: 130),
  ( cc: [ '}' ]; s: 138),
{ 131: }
  ( cc: [ #1..'|','~'..#255 ]; s: 131),
  ( cc: [ '}' ]; s: 139),
{ 132: }
  ( cc: [ #1..'|','~'..#255 ]; s: 132),
  ( cc: [ '}' ]; s: 140),
{ 133: }
  ( cc: [ #1..'|','~'..#255 ]; s: 141),
{ 134: }
{ 135: }
{ 136: }
  ( cc: [ #1..'|','~'..#255 ]; s: 136),
  ( cc: [ '}' ]; s: 142),
{ 137: }
  ( cc: [ #1..'|','~'..#255 ]; s: 137),
  ( cc: [ '}' ]; s: 143),
{ 138: }
{ 139: }
{ 140: }
{ 141: }
  ( cc: [ #1..'|','~'..#255 ]; s: 141),
  ( cc: [ '}' ]; s: 144)
{ 142: }
{ 143: }
{ 144: }
);

yykl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 1,
{ 4: } 1,
{ 5: } 1,
{ 6: } 1,
{ 7: } 1,
{ 8: } 1,
{ 9: } 1,
{ 10: } 1,
{ 11: } 3,
{ 12: } 5,
{ 13: } 7,
{ 14: } 9,
{ 15: } 10,
{ 16: } 12,
{ 17: } 14,
{ 18: } 15,
{ 19: } 16,
{ 20: } 19,
{ 21: } 22,
{ 22: } 25,
{ 23: } 28,
{ 24: } 32,
{ 25: } 37,
{ 26: } 41,
{ 27: } 45,
{ 28: } 47,
{ 29: } 49,
{ 30: } 52,
{ 31: } 55,
{ 32: } 58,
{ 33: } 61,
{ 34: } 66,
{ 35: } 70,
{ 36: } 74,
{ 37: } 78,
{ 38: } 80,
{ 39: } 82,
{ 40: } 85,
{ 41: } 88,
{ 42: } 92,
{ 43: } 95,
{ 44: } 99,
{ 45: } 103,
{ 46: } 105,
{ 47: } 107,
{ 48: } 109,
{ 49: } 112,
{ 50: } 113,
{ 51: } 113,
{ 52: } 114,
{ 53: } 115,
{ 54: } 115,
{ 55: } 116,
{ 56: } 117,
{ 57: } 118,
{ 58: } 120,
{ 59: } 120,
{ 60: } 122,
{ 61: } 124,
{ 62: } 124,
{ 63: } 124,
{ 64: } 124,
{ 65: } 124,
{ 66: } 124,
{ 67: } 124,
{ 68: } 124,
{ 69: } 124,
{ 70: } 124,
{ 71: } 125,
{ 72: } 125,
{ 73: } 125,
{ 74: } 125,
{ 75: } 125,
{ 76: } 125,
{ 77: } 125,
{ 78: } 125,
{ 79: } 125,
{ 80: } 125,
{ 81: } 125,
{ 82: } 125,
{ 83: } 125,
{ 84: } 125,
{ 85: } 125,
{ 86: } 125,
{ 87: } 125,
{ 88: } 125,
{ 89: } 125,
{ 90: } 125,
{ 91: } 125,
{ 92: } 126,
{ 93: } 126,
{ 94: } 126,
{ 95: } 126,
{ 96: } 126,
{ 97: } 126,
{ 98: } 126,
{ 99: } 126,
{ 100: } 126,
{ 101: } 126,
{ 102: } 126,
{ 103: } 126,
{ 104: } 126,
{ 105: } 126,
{ 106: } 126,
{ 107: } 126,
{ 108: } 126,
{ 109: } 126,
{ 110: } 127,
{ 111: } 127,
{ 112: } 127,
{ 113: } 127,
{ 114: } 127,
{ 115: } 129,
{ 116: } 129,
{ 117: } 129,
{ 118: } 129,
{ 119: } 129,
{ 120: } 129,
{ 121: } 129,
{ 122: } 130,
{ 123: } 130,
{ 124: } 130,
{ 125: } 130,
{ 126: } 132,
{ 127: } 132,
{ 128: } 132,
{ 129: } 132,
{ 130: } 132,
{ 131: } 132,
{ 132: } 132,
{ 133: } 132,
{ 134: } 132,
{ 135: } 133,
{ 136: } 134,
{ 137: } 134,
{ 138: } 134,
{ 139: } 135,
{ 140: } 137,
{ 141: } 139,
{ 142: } 139,
{ 143: } 140,
{ 144: } 141
);

yykh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 0,
{ 3: } 0,
{ 4: } 0,
{ 5: } 0,
{ 6: } 0,
{ 7: } 0,
{ 8: } 0,
{ 9: } 0,
{ 10: } 2,
{ 11: } 4,
{ 12: } 6,
{ 13: } 8,
{ 14: } 9,
{ 15: } 11,
{ 16: } 13,
{ 17: } 14,
{ 18: } 15,
{ 19: } 18,
{ 20: } 21,
{ 21: } 24,
{ 22: } 27,
{ 23: } 31,
{ 24: } 36,
{ 25: } 40,
{ 26: } 44,
{ 27: } 46,
{ 28: } 48,
{ 29: } 51,
{ 30: } 54,
{ 31: } 57,
{ 32: } 60,
{ 33: } 65,
{ 34: } 69,
{ 35: } 73,
{ 36: } 77,
{ 37: } 79,
{ 38: } 81,
{ 39: } 84,
{ 40: } 87,
{ 41: } 91,
{ 42: } 94,
{ 43: } 98,
{ 44: } 102,
{ 45: } 104,
{ 46: } 106,
{ 47: } 108,
{ 48: } 111,
{ 49: } 112,
{ 50: } 112,
{ 51: } 113,
{ 52: } 114,
{ 53: } 114,
{ 54: } 115,
{ 55: } 116,
{ 56: } 117,
{ 57: } 119,
{ 58: } 119,
{ 59: } 121,
{ 60: } 123,
{ 61: } 123,
{ 62: } 123,
{ 63: } 123,
{ 64: } 123,
{ 65: } 123,
{ 66: } 123,
{ 67: } 123,
{ 68: } 123,
{ 69: } 123,
{ 70: } 124,
{ 71: } 124,
{ 72: } 124,
{ 73: } 124,
{ 74: } 124,
{ 75: } 124,
{ 76: } 124,
{ 77: } 124,
{ 78: } 124,
{ 79: } 124,
{ 80: } 124,
{ 81: } 124,
{ 82: } 124,
{ 83: } 124,
{ 84: } 124,
{ 85: } 124,
{ 86: } 124,
{ 87: } 124,
{ 88: } 124,
{ 89: } 124,
{ 90: } 124,
{ 91: } 125,
{ 92: } 125,
{ 93: } 125,
{ 94: } 125,
{ 95: } 125,
{ 96: } 125,
{ 97: } 125,
{ 98: } 125,
{ 99: } 125,
{ 100: } 125,
{ 101: } 125,
{ 102: } 125,
{ 103: } 125,
{ 104: } 125,
{ 105: } 125,
{ 106: } 125,
{ 107: } 125,
{ 108: } 125,
{ 109: } 126,
{ 110: } 126,
{ 111: } 126,
{ 112: } 126,
{ 113: } 126,
{ 114: } 128,
{ 115: } 128,
{ 116: } 128,
{ 117: } 128,
{ 118: } 128,
{ 119: } 128,
{ 120: } 128,
{ 121: } 129,
{ 122: } 129,
{ 123: } 129,
{ 124: } 129,
{ 125: } 131,
{ 126: } 131,
{ 127: } 131,
{ 128: } 131,
{ 129: } 131,
{ 130: } 131,
{ 131: } 131,
{ 132: } 131,
{ 133: } 131,
{ 134: } 132,
{ 135: } 133,
{ 136: } 133,
{ 137: } 133,
{ 138: } 134,
{ 139: } 136,
{ 140: } 138,
{ 141: } 138,
{ 142: } 139,
{ 143: } 140,
{ 144: } 142
);

yyml : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 1,
{ 2: } 1,
{ 3: } 1,
{ 4: } 1,
{ 5: } 1,
{ 6: } 1,
{ 7: } 1,
{ 8: } 1,
{ 9: } 1,
{ 10: } 1,
{ 11: } 3,
{ 12: } 5,
{ 13: } 7,
{ 14: } 9,
{ 15: } 10,
{ 16: } 12,
{ 17: } 14,
{ 18: } 15,
{ 19: } 16,
{ 20: } 19,
{ 21: } 22,
{ 22: } 25,
{ 23: } 28,
{ 24: } 32,
{ 25: } 37,
{ 26: } 41,
{ 27: } 45,
{ 28: } 47,
{ 29: } 49,
{ 30: } 52,
{ 31: } 55,
{ 32: } 58,
{ 33: } 61,
{ 34: } 66,
{ 35: } 70,
{ 36: } 74,
{ 37: } 78,
{ 38: } 80,
{ 39: } 82,
{ 40: } 85,
{ 41: } 88,
{ 42: } 92,
{ 43: } 95,
{ 44: } 99,
{ 45: } 103,
{ 46: } 105,
{ 47: } 107,
{ 48: } 109,
{ 49: } 112,
{ 50: } 113,
{ 51: } 113,
{ 52: } 114,
{ 53: } 115,
{ 54: } 115,
{ 55: } 116,
{ 56: } 117,
{ 57: } 118,
{ 58: } 120,
{ 59: } 120,
{ 60: } 122,
{ 61: } 124,
{ 62: } 124,
{ 63: } 124,
{ 64: } 124,
{ 65: } 124,
{ 66: } 124,
{ 67: } 124,
{ 68: } 124,
{ 69: } 124,
{ 70: } 124,
{ 71: } 125,
{ 72: } 125,
{ 73: } 125,
{ 74: } 125,
{ 75: } 125,
{ 76: } 125,
{ 77: } 125,
{ 78: } 125,
{ 79: } 125,
{ 80: } 125,
{ 81: } 125,
{ 82: } 125,
{ 83: } 125,
{ 84: } 125,
{ 85: } 125,
{ 86: } 125,
{ 87: } 125,
{ 88: } 125,
{ 89: } 125,
{ 90: } 125,
{ 91: } 125,
{ 92: } 126,
{ 93: } 126,
{ 94: } 126,
{ 95: } 126,
{ 96: } 126,
{ 97: } 126,
{ 98: } 126,
{ 99: } 126,
{ 100: } 126,
{ 101: } 126,
{ 102: } 126,
{ 103: } 126,
{ 104: } 126,
{ 105: } 126,
{ 106: } 126,
{ 107: } 126,
{ 108: } 126,
{ 109: } 126,
{ 110: } 127,
{ 111: } 127,
{ 112: } 127,
{ 113: } 127,
{ 114: } 127,
{ 115: } 129,
{ 116: } 129,
{ 117: } 129,
{ 118: } 129,
{ 119: } 129,
{ 120: } 129,
{ 121: } 129,
{ 122: } 130,
{ 123: } 130,
{ 124: } 130,
{ 125: } 130,
{ 126: } 132,
{ 127: } 132,
{ 128: } 132,
{ 129: } 132,
{ 130: } 132,
{ 131: } 132,
{ 132: } 132,
{ 133: } 132,
{ 134: } 132,
{ 135: } 133,
{ 136: } 134,
{ 137: } 134,
{ 138: } 134,
{ 139: } 135,
{ 140: } 137,
{ 141: } 139,
{ 142: } 139,
{ 143: } 140,
{ 144: } 141
);

yymh : array [0..yynstates-1] of Integer = (
{ 0: } 0,
{ 1: } 0,
{ 2: } 0,
{ 3: } 0,
{ 4: } 0,
{ 5: } 0,
{ 6: } 0,
{ 7: } 0,
{ 8: } 0,
{ 9: } 0,
{ 10: } 2,
{ 11: } 4,
{ 12: } 6,
{ 13: } 8,
{ 14: } 9,
{ 15: } 11,
{ 16: } 13,
{ 17: } 14,
{ 18: } 15,
{ 19: } 18,
{ 20: } 21,
{ 21: } 24,
{ 22: } 27,
{ 23: } 31,
{ 24: } 36,
{ 25: } 40,
{ 26: } 44,
{ 27: } 46,
{ 28: } 48,
{ 29: } 51,
{ 30: } 54,
{ 31: } 57,
{ 32: } 60,
{ 33: } 65,
{ 34: } 69,
{ 35: } 73,
{ 36: } 77,
{ 37: } 79,
{ 38: } 81,
{ 39: } 84,
{ 40: } 87,
{ 41: } 91,
{ 42: } 94,
{ 43: } 98,
{ 44: } 102,
{ 45: } 104,
{ 46: } 106,
{ 47: } 108,
{ 48: } 111,
{ 49: } 112,
{ 50: } 112,
{ 51: } 113,
{ 52: } 114,
{ 53: } 114,
{ 54: } 115,
{ 55: } 116,
{ 56: } 117,
{ 57: } 119,
{ 58: } 119,
{ 59: } 121,
{ 60: } 123,
{ 61: } 123,
{ 62: } 123,
{ 63: } 123,
{ 64: } 123,
{ 65: } 123,
{ 66: } 123,
{ 67: } 123,
{ 68: } 123,
{ 69: } 123,
{ 70: } 124,
{ 71: } 124,
{ 72: } 124,
{ 73: } 124,
{ 74: } 124,
{ 75: } 124,
{ 76: } 124,
{ 77: } 124,
{ 78: } 124,
{ 79: } 124,
{ 80: } 124,
{ 81: } 124,
{ 82: } 124,
{ 83: } 124,
{ 84: } 124,
{ 85: } 124,
{ 86: } 124,
{ 87: } 124,
{ 88: } 124,
{ 89: } 124,
{ 90: } 124,
{ 91: } 125,
{ 92: } 125,
{ 93: } 125,
{ 94: } 125,
{ 95: } 125,
{ 96: } 125,
{ 97: } 125,
{ 98: } 125,
{ 99: } 125,
{ 100: } 125,
{ 101: } 125,
{ 102: } 125,
{ 103: } 125,
{ 104: } 125,
{ 105: } 125,
{ 106: } 125,
{ 107: } 125,
{ 108: } 125,
{ 109: } 126,
{ 110: } 126,
{ 111: } 126,
{ 112: } 126,
{ 113: } 126,
{ 114: } 128,
{ 115: } 128,
{ 116: } 128,
{ 117: } 128,
{ 118: } 128,
{ 119: } 128,
{ 120: } 128,
{ 121: } 129,
{ 122: } 129,
{ 123: } 129,
{ 124: } 129,
{ 125: } 131,
{ 126: } 131,
{ 127: } 131,
{ 128: } 131,
{ 129: } 131,
{ 130: } 131,
{ 131: } 131,
{ 132: } 131,
{ 133: } 131,
{ 134: } 132,
{ 135: } 133,
{ 136: } 133,
{ 137: } 133,
{ 138: } 134,
{ 139: } 136,
{ 140: } 138,
{ 141: } 138,
{ 142: } 139,
{ 143: } 140,
{ 144: } 142
);

yytl : array [0..yynstates-1] of Integer = (
{ 0: } 1,
{ 1: } 10,
{ 2: } 19,
{ 3: } 28,
{ 4: } 37,
{ 5: } 48,
{ 6: } 59,
{ 7: } 69,
{ 8: } 79,
{ 9: } 88,
{ 10: } 97,
{ 11: } 98,
{ 12: } 99,
{ 13: } 100,
{ 14: } 101,
{ 15: } 104,
{ 16: } 104,
{ 17: } 105,
{ 18: } 105,
{ 19: } 105,
{ 20: } 106,
{ 21: } 107,
{ 22: } 108,
{ 23: } 108,
{ 24: } 109,
{ 25: } 110,
{ 26: } 110,
{ 27: } 111,
{ 28: } 111,
{ 29: } 111,
{ 30: } 114,
{ 31: } 115,
{ 32: } 116,
{ 33: } 117,
{ 34: } 119,
{ 35: } 120,
{ 36: } 120,
{ 37: } 121,
{ 38: } 121,
{ 39: } 121,
{ 40: } 124,
{ 41: } 125,
{ 42: } 126,
{ 43: } 127,
{ 44: } 128,
{ 45: } 129,
{ 46: } 129,
{ 47: } 129,
{ 48: } 132,
{ 49: } 132,
{ 50: } 133,
{ 51: } 138,
{ 52: } 138,
{ 53: } 139,
{ 54: } 142,
{ 55: } 142,
{ 56: } 143,
{ 57: } 143,
{ 58: } 144,
{ 59: } 149,
{ 60: } 149,
{ 61: } 150,
{ 62: } 153,
{ 63: } 155,
{ 64: } 157,
{ 65: } 160,
{ 66: } 161,
{ 67: } 164,
{ 68: } 167,
{ 69: } 168,
{ 70: } 171,
{ 71: } 171,
{ 72: } 172,
{ 73: } 173,
{ 74: } 174,
{ 75: } 175,
{ 76: } 178,
{ 77: } 179,
{ 78: } 180,
{ 79: } 182,
{ 80: } 183,
{ 81: } 184,
{ 82: } 185,
{ 83: } 186,
{ 84: } 187,
{ 85: } 188,
{ 86: } 189,
{ 87: } 190,
{ 88: } 191,
{ 89: } 192,
{ 90: } 193,
{ 91: } 194,
{ 92: } 194,
{ 93: } 195,
{ 94: } 196,
{ 95: } 197,
{ 96: } 198,
{ 97: } 199,
{ 98: } 201,
{ 99: } 202,
{ 100: } 203,
{ 101: } 204,
{ 102: } 205,
{ 103: } 207,
{ 104: } 208,
{ 105: } 209,
{ 106: } 210,
{ 107: } 211,
{ 108: } 212,
{ 109: } 213,
{ 110: } 213,
{ 111: } 215,
{ 112: } 216,
{ 113: } 217,
{ 114: } 218,
{ 115: } 218,
{ 116: } 220,
{ 117: } 221,
{ 118: } 222,
{ 119: } 223,
{ 120: } 224,
{ 121: } 225,
{ 122: } 225,
{ 123: } 226,
{ 124: } 227,
{ 125: } 228,
{ 126: } 228,
{ 127: } 230,
{ 128: } 232,
{ 129: } 233,
{ 130: } 234,
{ 131: } 236,
{ 132: } 238,
{ 133: } 240,
{ 134: } 241,
{ 135: } 241,
{ 136: } 241,
{ 137: } 243,
{ 138: } 245,
{ 139: } 245,
{ 140: } 245,
{ 141: } 245,
{ 142: } 247,
{ 143: } 247,
{ 144: } 247
);

yyth : array [0..yynstates-1] of Integer = (
{ 0: } 9,
{ 1: } 18,
{ 2: } 27,
{ 3: } 36,
{ 4: } 47,
{ 5: } 58,
{ 6: } 68,
{ 7: } 78,
{ 8: } 87,
{ 9: } 96,
{ 10: } 97,
{ 11: } 98,
{ 12: } 99,
{ 13: } 100,
{ 14: } 103,
{ 15: } 103,
{ 16: } 104,
{ 17: } 104,
{ 18: } 104,
{ 19: } 105,
{ 20: } 106,
{ 21: } 107,
{ 22: } 107,
{ 23: } 108,
{ 24: } 109,
{ 25: } 109,
{ 26: } 110,
{ 27: } 110,
{ 28: } 110,
{ 29: } 113,
{ 30: } 114,
{ 31: } 115,
{ 32: } 116,
{ 33: } 118,
{ 34: } 119,
{ 35: } 119,
{ 36: } 120,
{ 37: } 120,
{ 38: } 120,
{ 39: } 123,
{ 40: } 124,
{ 41: } 125,
{ 42: } 126,
{ 43: } 127,
{ 44: } 128,
{ 45: } 128,
{ 46: } 128,
{ 47: } 131,
{ 48: } 131,
{ 49: } 132,
{ 50: } 137,
{ 51: } 137,
{ 52: } 138,
{ 53: } 141,
{ 54: } 141,
{ 55: } 142,
{ 56: } 142,
{ 57: } 143,
{ 58: } 148,
{ 59: } 148,
{ 60: } 149,
{ 61: } 152,
{ 62: } 154,
{ 63: } 156,
{ 64: } 159,
{ 65: } 160,
{ 66: } 163,
{ 67: } 166,
{ 68: } 167,
{ 69: } 170,
{ 70: } 170,
{ 71: } 171,
{ 72: } 172,
{ 73: } 173,
{ 74: } 174,
{ 75: } 177,
{ 76: } 178,
{ 77: } 179,
{ 78: } 181,
{ 79: } 182,
{ 80: } 183,
{ 81: } 184,
{ 82: } 185,
{ 83: } 186,
{ 84: } 187,
{ 85: } 188,
{ 86: } 189,
{ 87: } 190,
{ 88: } 191,
{ 89: } 192,
{ 90: } 193,
{ 91: } 193,
{ 92: } 194,
{ 93: } 195,
{ 94: } 196,
{ 95: } 197,
{ 96: } 198,
{ 97: } 200,
{ 98: } 201,
{ 99: } 202,
{ 100: } 203,
{ 101: } 204,
{ 102: } 206,
{ 103: } 207,
{ 104: } 208,
{ 105: } 209,
{ 106: } 210,
{ 107: } 211,
{ 108: } 212,
{ 109: } 212,
{ 110: } 214,
{ 111: } 215,
{ 112: } 216,
{ 113: } 217,
{ 114: } 217,
{ 115: } 219,
{ 116: } 220,
{ 117: } 221,
{ 118: } 222,
{ 119: } 223,
{ 120: } 224,
{ 121: } 224,
{ 122: } 225,
{ 123: } 226,
{ 124: } 227,
{ 125: } 227,
{ 126: } 229,
{ 127: } 231,
{ 128: } 232,
{ 129: } 233,
{ 130: } 235,
{ 131: } 237,
{ 132: } 239,
{ 133: } 240,
{ 134: } 240,
{ 135: } 240,
{ 136: } 242,
{ 137: } 244,
{ 138: } 244,
{ 139: } 244,
{ 140: } 244,
{ 141: } 246,
{ 142: } 246,
{ 143: } 246,
{ 144: } 246
);


Function PascalPreProcessor.Parse():Integer;
var yyn : Integer;

label start, scan, action;

begin

start:

  (* initialize: *)

  yynew;

scan:

  (* mark positions and matches: *)

  for yyn := yykl[yystate] to     yykh[yystate] do yymark(yyk[yyn]);
  for yyn := yymh[yystate] downto yyml[yystate] do yymatch(yym[yyn]);

  if yytl[yystate]>yyth[yystate] then goto action; (* dead state *)

  (* get next character: *)

  yyscan;

  (* determine action: *)

  yyn := yytl[yystate];
  while (yyn<=yyth[yystate]) and not (yyactchar in yyt[yyn].cc) do inc(yyn);
  if yyn>yyth[yystate] then goto action;
    (* no transition on yyactchar in this state *)

  (* switch to new state: *)

  yystate := yyt[yyn].s;

  goto scan;

action:

  (* execute action: *)

  if yyfind(yyrule) then
    begin
      yyaction(yyrule);
      if yyreject then goto action;
    end
  else if not yydefault and yywrap then
    begin
      yyclear;
      return(0);
    end;

  if not yydone then goto start;

  Result := yyretval;

end(*yylex*);

End.
