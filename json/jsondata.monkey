#Rem monkeydoc Module jsondata

The jsondata module contains various functions that allow you to draw 2D graphics on all supported monkey target platforms.

#End
Strict
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

Private

Class StringBuilder
    Field retStrings:String[]
    Field index:Int = 0
    
    Method New( initialSize:Int = 100 )
        If initialSize < 1
            initialSize = 1
        End
        retStrings = New String[initialSize]
    End
    
    Method AddString:Void( add:String )
        If index = retStrings.Length
            retStrings = retStrings.Resize(retStrings.Length() * 2) 
        End
        retStrings[index] = add
        index += 1
    End
    
    Method ToString:String()
        If index < 2
            Return retStrings[0]
        Else
            Return "".Join(retStrings[0..index])
        End
    End    
End

Public

Class JSONData

	Function WriteJSON:String(jsonDataItem:JSONDataItem)
		Return jsonDataItem.ToJSONString()
	End

	Function ReadJSON:JSONDataItem(jsonString:String)
		Local tokeniser:JSONTokeniser = New JSONTokeniser(jsonString)
		
		Local data:JSONDataItem = GetJSONDataItem(tokeniser)
			
		If data = Null
			Return New JSONDataError("Unknown JSON error.", tokeniser.GetCurrentSectionString())
		ElseIf data.dataType = JSONDataType.JSON_ERROR
            Print data.ToString()
        ElseIf data.dataType <> JSONDataType.JSON_OBJECT And data.dataType <> JSONDataType.JSON_ARRAY
			Return New JSONDataError("JSON Document malformed. Root node is not an object or an array", tokeniser.GetCurrentSectionString())
		End

		Return data
	End


	Function CreateJSONDataItem:JSONDataItem(value:Float)
		Return New JSONFloat(value)
	End

	Function CreateJSONDataItem:JSONDataItem(value:Int)
		Return New JSONInteger(value)
	End

	Function CreateJSONDataItem:JSONDataItem(value:String)
		Return New JSONString(value)
	End
	
	Function CreateJSONDataItem:JSONDataItem(value:Bool)
		Return New JSONBool(value)
	End

	Function GetJSONDataItem:JSONDataItem(tokeniser:JSONTokeniser)
		Local token:JSONToken = tokeniser.NextToken()
		'Print token
		Select token.tokenType
			Case JSONToken.TOKEN_OPEN_CURLY
				Return GetJSONObject(tokeniser)
			Case JSONToken.TOKEN_OPEN_SQUARE
				Return GetJSONArray(tokeniser)
			Case JSONToken.TOKEN_STRING
				Return New JSONString(StringObject(token.value), False)
			Case JSONToken.TOKEN_FLOAT
				Return New JSONFloat((FloatObject(token.value)).ToFloat())
			Case JSONToken.TOKEN_UNPARSED_FLOAT
				Return New JSONFloat((StringObject(token.value)).ToString())
			Case JSONToken.TOKEN_INTEGER
				Return New JSONInteger(IntObject(token.value))
			Case JSONToken.TOKEN_TRUE
				Return New JSONBool(True)
			Case JSONToken.TOKEN_FALSE
				Return New JSONBool(False)
			Case JSONToken.TOKEN_NULL
				Return New JSONNull()			
			Default
				Return New JSONNonData(token)
		End
	End

	Function GetJSONObject:JSONDataItem(tokeniser:JSONTokeniser)
		Local jsonObject:JSONObject = New JSONObject()
		Local data1:JSONDataItem
		Local data2:JSONDataItem
		
		'Check if this is an empty definition'
		data1 = JSONData.GetJSONDataItem(tokeniser)
		If data1.dataType = JSONDataType.JSON_NON_DATA And JSONNonData(data1).value.tokenType = JSONToken.TOKEN_CLOSE_CURLY
			'End of object'
			Return jsonObject
		End

		Repeat
			If data1.dataType <> JSONDataType.JSON_STRING
				Return New JSONDataError("Expected item name, got " + data1, tokeniser.GetCurrentSectionString())
			End
			
			data2 = JSONData.GetJSONDataItem(tokeniser)
			
			If data2.dataType <> JSONDataType.JSON_NON_DATA
				Return New JSONDataError("Expected ':', got " + data2, tokeniser.GetCurrentSectionString())
			Else
				If JSONNonData(data2).value.tokenType <> JSONToken.TOKEN_COLON
					Return New JSONDataError("Expected ':', got " + JSONNonData(data2).value, tokeniser.GetCurrentSectionString())
				End
			End
			
			data2 = JSONData.GetJSONDataItem(tokeniser)
			
			If data2.dataType = JSONDataType.JSON_ERROR
				Return data2
			ElseIf data2.dataType = JSONDataType.JSON_NON_DATA
				Return New JSONDataError("Expected item value, got " + JSONNonData(data2).value, tokeniser.GetCurrentSectionString())
			End
			
			jsonObject.AddItem(JSONString(data1).value,data2)
			data2 = JSONData.GetJSONDataItem(tokeniser)
			
			If data2.dataType <> JSONDataType.JSON_NON_DATA
				Return New JSONDataError("Expected ',' or '}', got " + data2, tokeniser.GetCurrentSectionString())
			Else
				If JSONNonData(data2).value.tokenType = JSONToken.TOKEN_CLOSE_CURLY
					Exit 'End of Object'
				ElseIf JSONNonData(data2).value.tokenType <> JSONToken.TOKEN_COMMA
					Return New JSONDataError("Expected ',' or '}', got " + JSONNonData(data2).value, tokeniser.GetCurrentSectionString())
				End
			End
			data1 = JSONData.GetJSONDataItem(tokeniser)
		Forever

		Return jsonObject
	End
	
	Function GetJSONArray:JSONDataItem(tokeniser:JSONTokeniser)
		Local jsonArray:JSONArray = New JSONArray()
		Local data:JSONDataItem
		
		'Check for empty array'
		data = JSONData.GetJSONDataItem(tokeniser)
		If data.dataType = JSONDataType.JSON_NON_DATA And JSONNonData(data).value.tokenType = JSONToken.TOKEN_CLOSE_SQUARE
			Return jsonArray
		End
	    
        Repeat
			If data.dataType = JSONDataType.JSON_NON_DATA
				Return New JSONDataError("Expected data value, got " + data, tokeniser.GetCurrentSectionString())
			ElseIf data.dataType = JSONDataType.JSON_ERROR
				return data
			End
			jsonArray.AddItem(data)
			
			data = JSONData.GetJSONDataItem(tokeniser)
			
			If data.dataType = JSONDataType.JSON_NON_DATA
				Local token:JSONToken = JSONNonData(data).value
				If token.tokenType = JSONToken.TOKEN_COMMA
					data = JSONData.GetJSONDataItem(tokeniser)
					Continue
				ElseIf token.tokenType = JSONToken.TOKEN_CLOSE_SQUARE
					Exit 'End of Array'
				Else
					Return New JSONDataError("Expected ',' or '], got " + token, tokeniser.GetCurrentSectionString())
				End
			Else
				Return New JSONDataError("Expected ',' or '], got " + data, tokeniser.GetCurrentSectionString())
			End
        Forever

		Return jsonArray
	End	

	Function EscapeJSON:String( input:String )
    	Local ch:Int
    	Local retString:StringBuilder = New StringBuilder(input.Length())
    	Local lastSlice:Int = 0
    	
    	For Local i := 0 Until input.Length
    		ch = input[i]
    		If ch > 127 Or ch < 32 Or ch = 92 Or ch = 34 Or ch = 47
	    		retString.AddString(input[lastSlice..i])
                If ch = 34 'quote
                    retString.AddString("\~q")
                ElseIf ch = 10 'newline
                    retString.AddString("\n")
                ElseIf ch = 13 'return
                    retString.AddString("\r")
                ElseIf ch = 92 'back slash
                    retString.AddString("\\")
                ElseIf ch = 47 'forward slash
                    retString.AddString("\/")
                ElseIf ch > 127 'unicode
	    		    retString.AddString("\u")
	    			retString.AddString(IntToHexString(ch))
	    		ElseIf ch = 8 'backspace
	    			retString.AddString("\b")
	    		ElseIf ch = 12 'linefeed
	    			retString.AddString("\f")
                ElseIf ch = 9 'tab
	    			retString.AddString("\t")
                End
	    		lastSlice = i+1
	    	End
    	End
    	retString.AddString(input[lastSlice..])
    	Local s:String = retString.ToString()
        'If input.Contains("\\")
        '    Print "Escaped already escaped string!"
        '    Print StackTrace()
        '    Print input
        '    Return input
        'End
    	Return s
    End

    Function IntToHexString:String( input:Int )
    	Local retString:String[] = New String[4]
        Local index:Int = 3
    	Local nibble:Int
    	While input > 0 
    		nibble = input & $F
    		If nibble < 10
    			retString[index] = String.FromChar(48+nibble)
    		Else
    			retString[index] = String.FromChar(55+nibble)
    		End
            index -=1
    		input Shr= 4
    	End

    	While index >= 0
    		retString[index] = "0"
            index -= 1
    	End
    	Return "".Join(retString)
    End

	Function UnEscapeJSON:String(input:String)
		Local escIndex:Int = input.Find("\")
        
        If escIndex = -1
            Return input
        End
        
		Local copyStartIndex:Int = 0
		Local retString:StringBuilder = New StringBuilder(input.Length())
        
		While escIndex <> -1
			retString.AddString( input[copyStartIndex..escIndex] )
            Select input[escIndex+1]
				Case 110 'n - newline
					retString.AddString( "~n" )
				Case 34 'quote
					retString.AddString( "~q" )
				Case 116 'tab
					retString.AddString( "~t" )
				Case 92 '\
					retString.AddString( "\" )
				Case 47 '/
					retString.AddString( "/" )
				Case 114 'r return
					retString.AddString( "~r" )			
				Case 102 'f formfeed
					retString.AddString( String.FromChar(12) )			
				Case 98 'b backspace
					retString.AddString( String.FromChar(8)	)		
				Case 117 'u unicode
					retString.AddString( UnEscapeUnicode(input[escIndex+2..escIndex+6])	)
					escIndex += 4		
			End
            copyStartIndex = escIndex+2
			escIndex = input.Find("\",copyStartIndex)
		End

		If copyStartIndex < input.Length
            retString.AddString( input[copyStartIndex..] )
        End

		Return retString.ToString()
	End
	
	Function HexCharToInt:Int(char:Int)
		If char >= 48 and char <= 57 '0-9'
			Return char-48
		ElseIf char >= 65 And char <= 70 'A-F'
			Return char - 55
		ElseIf char >= 97 And char <= 102 'a-f'
			Return char - 87
		End
        Return 0
	End

	Function UnEscapeUnicode:String(hexString:String)
		Local charCode:Int = 0
		For Local i:= 0 Until 4
			charCode Shl= 4
			charCode += HexCharToInt(hexString[i])
		End
		Return String.FromChar(charCode)
	End
End


Class JSONDataType
	'TODO: Change to typesafe enum pattern? Performance issues, maybe?'
	Const JSON_ERROR:Int = -1
	Const JSON_OBJECT:Int = 1
	Const JSON_ARRAY:Int = 2
	Const JSON_FLOAT:Int = 3
	Const JSON_INTEGER:Int = 4
	Const JSON_STRING:Int = 5
	Const JSON_BOOL:Int = 6
	Const JSON_NULL:Int = 7
	Const JSON_OBJECT_MEMBER:Int = 8
	Const JSON_NON_DATA:Int = 9
End

Class JSONDataItem Abstract

	Field dataType:Int = JSONDataType.JSON_NULL

	Method ToInt:Int()
		Print "Unsupported conversion to Int for " + Self.ToString()
		Return -1
	End

	Method ToFloat:Float()
		Print "Unsupported conversion to Float for " + Self.ToString()
		Return -1.0
	End

	Method ToBool:Bool()
		Print "Unsupported conversion to Bool for " + Self.ToString()
		Return False
	End

	'Method ToPrettyString() Abstract
	Method ToString:String() Abstract
	Method ToJSONString:String() 
		Return ToString()
	End
End

Class JSONDataError Extends JSONDataItem
	Field value:String
	
	Method New(errorDescription:String, location:String) 
		dataType = JSONDataType.JSON_ERROR 
		value = errorDescription + "~nJSON Location: " + location
	End

	Method ToString:String()
		Return value 
	End
End

Class JSONNonData Extends JSONDataItem
	Field value:JSONToken
	
	Method New(token:JSONToken) 
		dataType = JSONDataType.JSON_NON_DATA 
		value = token
	End

	Method ToString:String()
		Return "Non Data"
	End
End

Class JSONFloat Extends JSONDataItem
	Field value:Float
	Field unparsedStr:String
    Field unparsed:Bool = False
    
	Method New(value:Float) 
		dataType = JSONDataType.JSON_FLOAT 
		Self.value = value
	End

    'This constructor creates a float container that stores the unparsed
    'value string. This is to spread the load of parsing the data
    'as parsing floats is very expensive on Android.
    Method New(unparsedStr:String) 
		dataType = JSONDataType.JSON_FLOAT 
		Self.unparsedStr = unparsedStr
        Self.unparsed = True
	End
    
    Method Parse:Void()
        If unparsed
            value = Float(unparsedStr)
            unparsed = False 
        End
    End
    
	Method ToInt:Int()
        Parse()
		Return Int(value)
	End

	Method ToFloat:Float()
		Parse()
        Return value
	End

	Method ToString:String()
		Parse()
        Return String(value)
	End
End

Class JSONInteger Extends JSONDataItem
	Field value:Int
	
	Method New(value:Int) 
		dataType = JSONDataType.JSON_INTEGER 
		Self.value = value
	End

	Method ToInt:Int()
		Return value
	End

	Method ToFloat:Float()
		Return Float(value)
	End

	Method ToString:String()
		Return String(value)
	End
End

Class JSONString Extends JSONDataItem
	Private
    
    Field value:String
    Field jsonReady:String = ""
	
    Public
    
	Method New(value:String, isMonkeyString:Bool = True) 
		dataType = JSONDataType.JSON_STRING
		If Not isMonkeyString
			Self.value = JSONData.UnEscapeJSON(value)
            jsonReady = "~q"+value+"~q"
		Else
            Self.value = value
        End
    End

	Method ToJSONString:String()
        If jsonReady = ""
            jsonReady = "~q"+JSONData.EscapeJSON(value)+"~q"
        End
		Return jsonReady
	End

	Method ToString:String()
		Return value
	End

End

Class JSONBool Extends JSONDataItem
	Field value:Bool 
		
	Method New(value:Bool) 
		dataType = JSONDataType.JSON_BOOL
		Self.value = value
	End

	Method ToBool:Bool()
		return value
	End
	
	Method ToString:String()
		If value
			Return "True"
		Else
			Return "False"
		End
	End

	Method ToJSONString:String()
		If value
			Return "true"
		Else
			Return "false"
		End
	End

End

Class JSONNull Extends JSONDataItem
	Field value:Object = Null 'Necessary?
	
	Method ToString:String()
		dataType = JSONDataType.JSON_NULL 
		Return "NULL"
	End
End

Class JSONArray Extends JSONDataItem
	Field values:List<JSONDataItem> = New List<JSONDataItem>
	
	Method New()
		dataType = JSONDataType.JSON_ARRAY 
	End

	Method AddPrim:Void( value:Bool )
		values.AddLast(JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( value:Int )
		values.AddLast(JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( value:Float )
		values.AddLast(JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( value:String )
		values.AddLast(JSONData.CreateJSONDataItem(value))
	End
	
	Method AddItem:Void( dataItem:JSONDataItem )
		values.AddLast(dataItem)
	End
	
	Method RemoveItem:Void( dataItem:JSONDataItem )
		values.RemoveEach(dataItem)
	End
	
	Method ToJSONString:String()
		Local retString:StringBuilder = New StringBuilder(values.Count()*2+5)
		Local first:Bool = True
        retString.AddString("[")
		For Local v:= Eachin values
			If first
				first = False
			Else
				retString.AddString(",")
			End
			retString.AddString(v.ToJSONString())
		End
        
        retString.AddString("]")
        
		Return retString.ToString()
	End
	
	Method ToString:String()
		Local retString:StringBuilder = New StringBuilder(values.Count()*2+5)
        Local first:Bool = True
        
		retString.AddString("[")
        
        For Local v:= Eachin values
			If first
				first = False
			Else
				retString.AddString(",")
			End
			retString.AddString(v.ToString())
		End
        
        retString.AddString("]")
		
        Return retString.ToString()
	End

	Method ObjectEnumerator:list.Enumerator<JSONDataItem>()
		Return list.Enumerator<JSONDataItem>(values.ObjectEnumerator())
	End
    
    Method Clear:Void()
        values.Clear()
    End
End

Class JSONObjectMember Extends JSONDataItem
	Field name:String
	Field dataItem:JSONDataItem

	Method New(name:String, dataItem:JSONDataItem) 
		dataType = JSONDataType.JSON_OBJECT_MEMBER
		Self.name = name
        Self.dataItem = dataItem
	End

	Method ToBool:Bool()
		Return dataItem.ToBool()
	End
	
	Method ToInt:Int()
		Return dataItem.ToInt()
	End
	
	Method ToFloat:Float()
		Return dataItem.ToFloat()
	End
	
	Method ToString:String()
		Return dataItem.ToString()
	End

	Method ToJSONString:String()
		Return dataItem.ToJSONString()
	End
End

Class JSONObject Extends JSONDataItem
	Field values:StringMap<JSONDataItem> = New StringMap<JSONDataItem>()
	
	Method New()
		dataType = JSONDataType.JSON_OBJECT 
	End

	Method AddPrim:Void( name:String, value:Bool )
		values.Set(name,JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( name:String, value:Int )
		values.Set(name,JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( name:String, value:Float )
		values.Set(name,JSONData.CreateJSONDataItem(value))
	End
	
	Method AddPrim:Void( name:String, value:String )
		values.Set(name,JSONData.CreateJSONDataItem(value))
	End
	
	Method AddItem:Void( name:String, dataItem:JSONDataItem )
		values.Set(name,dataItem)
	End
	
	Method RemoveItem:Void( name:String )
		values.Remove(name)
	End
	
	Method GetItem:JSONDataItem( name:String )
		Return values.Get(name)
	End
	
    Method GetItem:String( name:String, defaultValue:String )
		Local item:JSONDataItem = values.Get(name)
        If item <> Null
            Return item
        End
        Return defaultValue
	End
	
    Method GetItem:Int( name:String, defaultValue:Int )
		Local item:JSONDataItem = values.Get(name)
        If item <> Null
            Return item
        End
        Return defaultValue
	End
	
    Method GetItem:Float( name:String, defaultValue:Float )
		Local item:JSONDataItem = values.Get(name)
        If item <> Null
            Return item
        End
        Return defaultValue
	End
	
    Method GetItem:Bool( name:String, defaultValue:Bool )
		Local item:JSONDataItem = values.Get(name)
        If item <> Null
            Return item
        End
        Return defaultValue
	End
	
    
	Method ToJSONString:String()
		Local retString:StringBuilder = New StringBuilder(values.Count()*5+5)
		Local first:Bool = True
		
        retString.AddString("{")
        
        For Local v:= Eachin values
			If first
				first = False
			Else
				retString.AddString(",")
			End
			retString.AddString("~q")
            retString.AddString(JSONData.EscapeJSON(v.Key()))
            retString.AddString("~q:")
            retString.AddString(v.Value().ToJSONString())
		End
	    retString.AddString("}")
		Return retString.ToString()
	End

	Method ToString:String()
		Local retString:StringBuilder = New StringBuilder(values.Count()*5+5)
		Local first:Bool = True
        
        retString.AddString("{")
        
		For Local v:= Eachin values
			If first
				first = False
			Else
				retString.AddString(",")
			End
			retString.AddString("~q")
            retString.AddString(v.Key())
            retString.AddString("~q:")
            retString.AddString(v.Value())
		End
        retString.AddString("}")
		Return retString.ToString()
	End

    Method Clear:Void()
        values.Clear()
    End
    
	Method Names:map.MapKeys<String,JSONDataItem>()
		Return values.Keys()
	End
	
	Method Items:map.MapValues<String,JSONDataItem>()
		Return values.Values()
	End

	Method ObjectEnumerator:JSONObjectEnumerator()
		Return New JSONObjectEnumerator(NodeEnumerator<String,JSONDataItem>(values.ObjectEnumerator()))
	End
End

Class JSONObjectEnumerator
	Field enumerator:NodeEnumerator<String,JSONDataItem>
	Method New( enumerator:NodeEnumerator<String,JSONDataItem> )
		Self.enumerator = enumerator 
	End

	Method HasNext:Bool()
		Return Self.enumerator.HasNext()
	End
	
	Method NextObject:JSONObjectMember()
		Local node:map.Node<String,JSONDataItem> = enumerator.NextObject()
		Return New JSONObjectMember(node.Key(), node.Value())
	End
End