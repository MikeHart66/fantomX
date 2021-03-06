#rem
	Title:        fantomX
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

'nav:<blockquote><nav><b>fantomX documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
'header:The module cftFunctions is a collection of several functions for IOS, ANDROID and HTML5 targets to retrieve some device and browser informations.

#if HOST="macos" And TARGET="glfw"
	'Import "native/fantomX.${TARGET}.mac.${LANG}"
#elseif TARGET="android" Or TARGET="ios" Or TARGET="html5"
	Import "native/fantomX.${TARGET}.${LANG}"
#else 
	'Import "native/fantomX.${TARGET}.${LANG}"
#end

'Import mojo

Extern
'#DOCOFF#
	#If TARGET = "android" Then
		Function GetDeviceName:String() = "fantomX.DeviceName"
		Function GetHardware:String() = "fantomX.Hardware"
		Function GetUser:String() = "fantomX.User"
		Function GetProduct:String() = "fantomX.Product"
		Function GetSerial:String() = "fantomX.Serial"
		Function GetBrowserName:String() = "fantomX.GetBrowserName"
		Function GetBrowserVersion:String() = "fantomX.GetBrowserVersion"
		Function GetBrowserPlatform:String() = "fantomX.GetBrowserPlatform"
	#ElseIf TARGET = "ios" Then
		Function GetDeviceName:String() = "fantomX::DeviceName"
		Function GetHardware:String() = "fantomX::Hardware"
		Function GetUser:String() = "fantomX::User"
		Function GetProduct:String() = "fantomX::Product"
		Function GetSerial:String() = "fantomX::Serial"
		Function GetBrowserName:String() = "fantomX::GetBrowserName"
		Function GetBrowserVersion:String() = "fantomX::GetBrowserVersion"
		Function GetBrowserPlatform:String() = "fantomX::GetBrowserPlatform"
	#ElseIf TARGET = "html5" Then
		Function GetDeviceName:String() = "fantomX.DeviceName"
		Function GetHardware:String() = "fantomX.Hardware"
		Function GetUser:String() = "fantomX.User"
		Function GetProduct:String() = "fantomX.Product"
		Function GetSerial:String() = "fantomX.Serial"
		Function GetBrowserName:String() = "fantomX.GetBrowserName"
		Function GetBrowserVersion:String() = "fantomX.GetBrowserVersion"
		Function GetBrowserPlatform:String() = "fantomX.GetBrowserPlatform"
		
		Function MaximizeCanvas:Void() = "fantomX.MaximizeCanvas"
		Function ResizeCanvas:Void(x:Int, y:Int) = "fantomX.ResizeCanvas"
		Function ResizeConsole:Void(x:Int, y:Int) = "fantomX.ResizeConsole"
		Function HideConsole:Void() = "fantomX.HideConsole"
		Function IsMobileBrowser:Bool() = "fantomX.IsMobileBrowser"
		Function GetLanguage:String() = "fantomX.GetLanguage"
		Function GetDomain:String() = "fantomX.GetDomain"
	#Endif
Public
'#DOCON#
	#If TARGET <> "android" And TARGET <> "ios" And TARGET <> "html5" Then
'------------------------------------------
#Rem
'summery:Returns the name of the device.
'Returns valid information on Android/iOS only.
#End
		Function GetDeviceName:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Returns the hardware of the device.
'Returns valid information on Android/iOS only.
#End
		Function GetHardware:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Returns the name of the device user.
'Returns valid information on Android/iOS only.
#End
		Function GetUser:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Return the product of the device.
'Returns valid information on Android only.
#End
		Function GetProduct:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Return the serial number of the device.
'Returns valid information on Android/iOS only.
#End

		Function GetSerial:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Returns the name of the HTML5 browser.
'Returns valid information on HTML5 only.
#End
		Function GetBrowserName:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Returns the version of the HTML5 browser.
'Returns valid information on HTML5 only.
#End
		Function GetBrowserVersion:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Returns the platform the HTML5 browser is running on.
'Returns valid information on HTML5 only.
#End
		Function GetBrowserPlatform:String()
			Local s:String = "---"
			Return s
		End
'------------------------------------------
#Rem
'summery:Maximizes the HTML5 canvas.
'HTML5 only.
'Attention: You need to set the variable CANVAS_RESIZE_MODE to 0 in your exported MonkeyGame.html file to make this work correctly!
#End
		Function MaximizeCanvas:Void()
			'
		End
'------------------------------------------
#Rem
'summery:Resizes the HTML5 canvas to the given proportions.
'HTML5 only.
'Attention: You need to set the variable CANVAS_RESIZE_MODE to 0 in your exported MonkeyGame.html file to make this work correctly!
#End
		Function ResizeCanvas:Void(x:Int, y:Int)
			'
		End
'------------------------------------------
#Rem
'summery:Resizes the HTML5 console to the given proportions.
'HTML5 only.
'Attention: You need to set the variable CANVAS_RESIZE_MODE to 0 in your exported MonkeyGame.html file to make this work correctly!
#End
		Function ResizeConsole:Void(x:Int, y:Int)
			'
		End
'------------------------------------------
#Rem
'summery:Hides the HTML5 console.
'HTML5 only.
'Attention: You need to set the variable CANVAS_RESIZE_MODE to 0 in your exported MonkeyGame.html file to make this work correctly!
#End
		Function HideConsole:Void()
			'
		End
'------------------------------------------
#Rem
'summery:Returns TRUE, if your HTML5 runs on a mobile browser.
'Returns valid information on HTML5 only.
#End
		Function IsMobileBrowser:Bool()
			Return False
		End

'------------------------------------------
#Rem
'summery:Returns the language of a browser.
'Returns valid information on HTML5 only.
#End
		Function GetLanguage:String()
			Return "---"
		End
	#End

	

#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end	