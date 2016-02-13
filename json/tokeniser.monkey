#rem
'/*
'* Copyright (c) 2011, Damian Sinclair
'*
'* All rights reserved.
'* Redistribution and use in source and binary forms, with or without
'* modification, are permitted provided that the following conditions are met:
'*
'*   - Redistributions of source code must retain the above copyright
'*     notice, this list of conditions and the following disclaimer.
'*   - Redistributions in binary form must reproduce the above copyright
'*     notice, this list of conditions and the following disclaimer in the
'*     documentation and/or other materials provided with the distribution.
'*
'* THIS SOFTWARE IS PROVIDED BY THE MONKEY-JSON PROJECT CONTRIBUTORS "AS IS" AND
'* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
'* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
'* DISCLAIMED. IN NO EVENT SHALL THE MONKEY-JSON PROJECT CONTRIBUTORS BE LIABLE
'* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
'* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
'* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
'* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
'* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
'* DAMAGE.
'*/
#end
Import fantomX.json

Class JSONToken
	Const TOKEN_UNKNOWN:Int = -1
	Const TOKEN_COMMA:Int = 0
	Const TOKEN_OPEN_CURLY:Int = 1
	Const TOKEN_CLOSE_CURLY:Int = 2
	Const TOKEN_OPEN_SQUARE:Int = 3
	Const TOKEN_CLOSE_SQUARE:Int = 4
	Const TOKEN_COLON:Int = 6
	Const TOKEN_TRUE:Int = 7
	Const TOKEN_FALSE:Int = 8
	Const TOKEN_NULL:Int = 9
	Const TOKEN_STRING:Int = 10
	Const TOKEN_FLOAT:Int = 11
	Const TOKEN_UNPARSED_FLOAT:Int = 12
	Const TOKEN_INTEGER:Int = 13

	Field tokenType:Int
	Field value:Object

	Private

	Global reusableToken:JSONToken = New JSONToken(-1, Null)
    
	Method New( tokenType:Int, value:Object )
		Self.tokenType = tokenType
		Self.value = value
	End

    Public
    
    Function CreateToken:JSONToken(tokenType:Int, value:Float)
		reusableToken.tokenType = tokenType
		reusableToken.value = New FloatObject(value)
		Return reusableToken
	End
	
	Function CreateToken:JSONToken( tokenType:Int, value:Int )
		reusableToken.tokenType = tokenType
		reusableToken.value = New IntObject(value)
		Return reusableToken
	End
	
	Function CreateToken:JSONToken( tokenType:Int, value:String )
		reusableToken.tokenType = tokenType
		reusableToken.value = New StringObject(value)
		Return reusableToken
	End
	
	Function CreateToken:JSONToken( tokenType:Int, value:Object )
		reusableToken.tokenType = tokenType
		reusableToken.value = value
		Return reusableToken
	End
    
	Method ToString:String()
		Return "JSONToken - type: " + tokenType + ", value: " + GetValueString() 
	End

	Method GetValueString:String()
		Select tokenType 
			Case TOKEN_FLOAT
				Return "" + FloatObject(value)
			Case TOKEN_INTEGER
				Return "" + IntObject(value)
			Case TOKEN_NULL
				Return "NULL"
			Default
                If value
				    Return StringObject(value)
                Else
                    Return "Null value"
                End 
		End	
	End
	
	
End

Class JSONTokeniser

	Private

	Field jsonString:String = ""
	Field stringIndex:Int = 0
	Field char:Int = 0
	Field silent:Bool = False

	Public

	Method New( jsonString:String, silent:Bool = False )
		Self.silent = silent
		Self.jsonString = jsonString
		NextChar()
	End

	Method GetCurrentSectionString:String(backwards:Int = 20,forwards:Int = 20)
		Return "Section: " + jsonString[Max(stringIndex-backwards,0)..Min(stringIndex+forwards,jsonString.Length)]
	End

	Method NextToken:JSONToken()
		Local retToken:JSONToken = Null
		SkipIgnored()

        Select char

			Case ASCIICodes.CHR_OPEN_CURLY
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_OPEN_CURLY,"{")
			Case ASCIICodes.CHR_CLOSE_CURLY
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_CLOSE_CURLY,"}")
			Case ASCIICodes.CHR_OPEN_SQUARE
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_OPEN_SQUARE,"[")
			Case ASCIICodes.CHR_CLOSE_SQUARE
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_CLOSE_SQUARE,"]")
			Case ASCIICodes.CHR_COMMA
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_COMMA,",")
			Case ASCIICodes.CHR_COLON
				retToken = JSONToken.CreateToken(JSONToken.TOKEN_COLON,":")
			Case ASCIICodes.CHR_LOWER_T
				If jsonString[stringIndex..stringIndex+3].Compare("rue") = 0
					stringIndex += 3
					retToken = JSONToken.CreateToken(JSONToken.TOKEN_TRUE,"true")
				End
			Case ASCIICodes.CHR_LOWER_F
				If jsonString[stringIndex..stringIndex+4].Compare("alse") = 0
					stringIndex += 4
					retToken = JSONToken.CreateToken(JSONToken.TOKEN_FALSE,"false")
				End
			Case ASCIICodes.CHR_LOWER_N
				If jsonString[stringIndex..stringIndex+3].Compare("ull") = 0
					stringIndex += 3
					retToken = JSONToken.CreateToken(JSONToken.TOKEN_NULL,"null")
				End
			Case ASCIICodes.CHR_DOUBLE_QUOTE
				Local startIndex:Int = stringIndex
        		Local endIndex:Int = jsonString.Find("~q",stringIndex)
                While endIndex <> -1 And jsonString[endIndex-1] = ASCIICodes.CHR_BACKSLASH
                    endIndex = jsonString.Find("~q",endIndex+1)
                End
                If endIndex = -1
                    ParseFailure("Unterminated string")
                End
				
                retToken = JSONToken.CreateToken(JSONToken.TOKEN_STRING,jsonString[startIndex..endIndex])
				stringIndex = endIndex+1
						
			Default
				'Is it a Number?
				If char = ASCIICodes.CHR_HYPHEN Or IsDigit(char)
					Return ParseNumberToken(char) 'We return here because ParseNumberToken moves the token pointer forward
				Else If char = ASCIICodes.CHR_NUL
					retToken = Null 'End of string so just leave'
				End
								
		End
		If retToken = Null
			ParseFailure("Unknown token, char: " + String.FromChar(char))
			retToken = JSONToken.CreateToken(JSONToken.TOKEN_UNKNOWN,Null)
		Else
			NextChar()
		End
		Return retToken

	End

	Private
	
	Method NextChar:Int()
		If stringIndex >= jsonString.Length
			char = ASCIICodes.CHR_NUL
            Return char
		End
		char = jsonString[stringIndex]
		stringIndex += 1
		return char
	End

	Method ParseNumberToken:JSONToken(firstChar:Int)
		Local index:Int = stringIndex-1
		'First just get the full string
		While char <> ASCIICodes.CHR_SPACE And char <> ASCIICodes.CHR_COMMA And 
                char <> ASCIICodes.CHR_CLOSE_CURLY And char <> ASCIICodes.CHR_CLOSE_SQUARE And char <> ASCIICodes.CHR_NUL
			NextChar()
		End
		If char = ASCIICodes.CHR_NUL
			ParseFailure("Unterminated Number")
			Return JSONToken.CreateToken(JSONToken.TOKEN_UNKNOWN,Null)
		End

		Local numberString:String = jsonString[index..stringIndex-1]
		
		If numberString.Find(".") <> -1 Or numberString.Find("e") <> -1 Or numberString.Find("E") <> -1
		    Return JSONToken.CreateToken(JSONToken.TOKEN_UNPARSED_FLOAT,numberString)
		Else
			Local value:Int = ParseInteger(numberString)
			Return JSONToken.CreateToken(JSONToken.TOKEN_INTEGER,value)
		End 
	End

	'No error trapping or anything like that
	Method ParseInteger:Int(str:String)
		Return Int(str)
	End

	'No error trapping or anything like that
	Method ParseFloat:Float(str:String)
        Return Float(str)
    End

	Method IsDigit:Bool(char:Int)
		Return( char >= 48 And char <= 58 )
	End

	Method SkipIgnored:Void()
		Local ignoredCount:Int
		Repeat
			ignoredCount = 0
			ignoredCount += SkipWhitespace()
			ignoredCount += SkipComments()
		Until ignoredCount = 0
	End

	Method SkipWhitespace:Int()
		Local index:Int = stringIndex
		While char <= ASCIICodes.CHR_SPACE And char <> ASCIICodes.CHR_NUL
			NextChar()
		End
		Return stringIndex-index
	End

	Method SkipComments:Int()
		Local index:Int = stringIndex
		If char = ASCIICodes.CHR_FORWARD_SLASH
			NextChar()
			If char = ASCIICodes.CHR_FORWARD_SLASH
				While char <> ASCIICodes.CHR_CR And char <> ASCIICodes.CHR_LF And char <> ASCIICodes.CHR_NUL
					NextChar()
				End
			ElseIf char = ASCIICodes.CHR_ASTERISK
				Repeat
					NextChar()
                    If char = ASCIICodes.CHR_ASTERISK
						NextChar()
                        If char = ASCIICodes.CHR_FORWARD_SLASH
							Exit
						End
					End
					If char = ASCIICodes.CHR_NUL
						ParseFailure("Unterminated comment")
						Exit
					End
				Forever
			Else
				ParseFailure("Unrecognised comment opening")
			End
			NextChar()
		End
		Return stringIndex-index
	End

	Method ParseFailure:Void(description:String)
		If silent
			Return
		End
		Print "JSON parse error at index: " + stringIndex
		Print description
		Print GetCurrentSectionString()
		stringIndex = jsonString.Length
	End
End

Class ASCIICodes
    'Liberated from Diddy and then tweaked
    ' control characters
    Const CHR_NUL:Int = 0       ' Null character
    Const CHR_SOH:Int = 1       ' Start of Heading
    Const CHR_STX:Int = 2       ' Start of Text
    Const CHR_ETX:Int = 3       ' End of Text
    Const CHR_EOT:Int = 4       ' End of Transmission
    Const CHR_ENQ:Int = 5       ' Enquiry
    Const CHR_ACK:Int = 6       ' Acknowledgment
    Const CHR_BEL:Int = 7       ' Bell
    Const CHR_BACKSPACE:Int = 8 ' Backspace
    Const CHR_TAB:Int = 9       ' Horizontal tab
    Const CHR_LF:Int = 10       ' Linefeed
    Const CHR_VTAB:Int = 11     ' Vertical tab
    Const CHR_FF:Int = 12       ' Form feed
    Const CHR_CR:Int = 13       ' Carriage return
    Const CHR_SO:Int = 14       ' Shift Out
    Const CHR_SI:Int = 15       ' Shift In
    Const CHR_DLE:Int = 16      ' Data Line Escape
    Const CHR_DC1:Int = 17      ' Device Control 1
    Const CHR_DC2:Int = 18      ' Device Control 2
    Const CHR_DC3:Int = 19      ' Device Control 3
    Const CHR_DC4:Int = 20      ' Device Control 4
    Const CHR_NAK:Int = 21      ' Negative Acknowledgment
    Const CHR_SYN:Int = 22      ' Synchronous Idle
    Const CHR_ETB:Int = 23      ' End of Transmit Block
    Const CHR_CAN:Int = 24      ' Cancel
    Const CHR_EM:Int = 25       ' End of Medium
    Const CHR_SUB:Int = 26      ' Substitute
    Const CHR_ESCAPE:Int = 27   ' Escape
    Const CHR_FS:Int = 28       ' File separator
    Const CHR_GS:Int = 29       ' Group separator
    Const CHR_RS:Int = 30       ' Record separator
    Const CHR_US:Int = 31       ' Unit separator
    
    ' visible characters
    Const CHR_SPACE:Int = 32                ' '
    Const CHR_EXCLAMATION:Int = 33          '!'
    Const CHR_DOUBLE_QUOTE:Int = 34         '"'
    Const CHR_HASH:Int = 35                 '#'
    Const CHR_DOLLAR:Int = 36               '$'
    Const CHR_PERCENT:Int = 37              '%'
    Const CHR_AMPERSAND:Int = 38            '&'
    Const CHR_SINGLE_QUOTE:Int = 39         '''
    Const CHR_OPEN_ROUND:Int = 40     '('
    Const CHR_CLOSE_ROUND:Int = 41    ')'
    Const CHR_ASTERISK:Int = 42             '*'
    Const CHR_PLUS:Int = 43                 '+'
    Const CHR_COMMA:Int = 44                ','
    Const CHR_HYPHEN:Int = 45               '-'
    Const CHR_PERIOD:Int = 46               '.'
    Const CHR_FORWARD_SLASH:Int = 47                '/'
    Const CHR_0:Int = 48
    Const CHR_1:Int = 49
    Const CHR_2:Int = 50
    Const CHR_3:Int = 51
    Const CHR_4:Int = 52
    Const CHR_5:Int = 53
    Const CHR_6:Int = 54
    Const CHR_7:Int = 55
    Const CHR_8:Int = 56
    Const CHR_9:Int = 57
    Const CHR_COLON:Int = 58        ':'
    Const CHR_SEMICOLON:Int = 59    ';'
    Const CHR_LESS_THAN:Int = 60    '<'
    Const CHR_EQUALS:Int = 61       '='
    Const CHR_GREATER_THAN:Int = 62 '>'
    Const CHR_QUESTION:Int = 63     '?'
    Const CHR_AT:Int = 64           '@'
    Const CHR_UPPER_A:Int = 65
    Const CHR_UPPER_B:Int = 66
    Const CHR_UPPER_C:Int = 67
    Const CHR_UPPER_D:Int = 68
    Const CHR_UPPER_E:Int = 69
    Const CHR_UPPER_F:Int = 70
    Const CHR_UPPER_G:Int = 71
    Const CHR_UPPER_H:Int = 72
    Const CHR_UPPER_I:Int = 73
    Const CHR_UPPER_J:Int = 74
    Const CHR_UPPER_K:Int = 75
    Const CHR_UPPER_L:Int = 76
    Const CHR_UPPER_M:Int = 77
    Const CHR_UPPER_N:Int = 78
    Const CHR_UPPER_O:Int = 79
    Const CHR_UPPER_P:Int = 80
    Const CHR_UPPER_Q:Int = 81
    Const CHR_UPPER_R:Int = 82
    Const CHR_UPPER_S:Int = 83
    Const CHR_UPPER_T:Int = 84
    Const CHR_UPPER_U:Int = 85
    Const CHR_UPPER_V:Int = 86
    Const CHR_UPPER_W:Int = 87
    Const CHR_UPPER_X:Int = 88
    Const CHR_UPPER_Y:Int = 89
    Const CHR_UPPER_Z:Int = 90
    Const CHR_OPEN_SQUARE:Int = 91     '['
    Const CHR_BACKSLASH:Int = 92        '\'
    Const CHR_CLOSE_SQUARE:Int = 93    ']'
    Const CHR_CIRCUMFLEX:Int = 94       '^'
    Const CHR_UNDERSCORE:Int = 95       '_'
    Const CHR_BACKTICK:Int = 96         '`'
    Const CHR_LOWER_A:Int = 97
    Const CHR_LOWER_B:Int = 98
    Const CHR_LOWER_C:Int = 99
    Const CHR_LOWER_D:Int = 100
    Const CHR_LOWER_E:Int = 101
    Const CHR_LOWER_F:Int = 102
    Const CHR_LOWER_G:Int = 103
    Const CHR_LOWER_H:Int = 104
    Const CHR_LOWER_I:Int = 105
    Const CHR_LOWER_J:Int = 106
    Const CHR_LOWER_K:Int = 107
    Const CHR_LOWER_L:Int = 108
    Const CHR_LOWER_M:Int = 109
    Const CHR_LOWER_N:Int = 110
    Const CHR_LOWER_O:Int = 111
    Const CHR_LOWER_P:Int = 112
    Const CHR_LOWER_Q:Int = 113
    Const CHR_LOWER_R:Int = 114
    Const CHR_LOWER_S:Int = 115
    Const CHR_LOWER_T:Int = 116
    Const CHR_LOWER_U:Int = 117
    Const CHR_LOWER_V:Int = 118
    Const CHR_LOWER_W:Int = 119
    Const CHR_LOWER_X:Int = 120
    Const CHR_LOWER_Y:Int = 121
    Const CHR_LOWER_Z:Int = 122
    Const CHR_OPEN_CURLY:Int = 123  '{'
    Const CHR_PIPE:Int = 124        '|'
    Const CHR_CLOSE_CURLY:Int = 125 '}'
    Const CHR_TILDE:Int = 126       '~'
    Const CHR_DELETE:Int = 127
End