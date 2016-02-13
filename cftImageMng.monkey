'#DOCON#
#rem
	Title:        fantomX
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End


'nav:<blockquote><nav><b>fantomX documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>

'header:The module cftImageMng contains several classes to manage loaded images inside your game.

Import fantomX

'***************************************
'summery:The ftImage class contains a mojo image and some information about.
Class ftImage
'#DOCOFF#
	Field img:Image[]
	Field atlas:ftImage = Null
	Field flags:Int = 000
	Field path:String = ""
	Field imageNode:list.Node<ftImage> = Null  
	Field frameWidth:Int = -1
	Field frameHeight:Int = -1
	Field frameStartX:Int = -1
	Field frameStartY:Int = -1
	Field isGrabed:Bool = False
	Field isAtlas:Bool = False
	Field engine:ftEngine
'#DOCON#
	'------------------------------------------
'summery:Returns the frame count of a ftImage.
	Method GetFrameCount:Int()
		Return Self.img.Length()
	End
	'------------------------------------------
'summery:Returns the frame height of a ftImage.
	Method GetFrameHeight:Int()
		Return Self.frameHeight
	End
	'------------------------------------------
'summery:Returns the frame width of a ftImage.
	Method GetFrameWidth:Int()
		Return Self.frameWidth
	End
	'------------------------------------------
	Method GetImage:Image[]()
'summery:Returns the image of a ftImage.
		Return Self.img
	End
	'------------------------------------------
'summery:Returns the path (filename) of a ftImage.
	Method GetPath:String()
		Return Self.path
	End
	'------------------------------------------
	
'summery:Reloads an image.
	Method ReLoad:Void()
		If path.Length() > 1 Or Self.isGrabed = True Then
			If Self.isGrabed = True Or Self.path.Length()> 1 Then
				Local fc:Int = Self.img.Length()
				For Local i:= 1 To Self.img.Length()
					Self.img[i-1].Discard()
					If Self.isGrabed = True Then
						'Self.img[i-1] = atlas.img.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
						Self.img[i-1] = New Image( Self.atlas.img[0],frameStartX+(frameWidth*(i-1)), frameStartY, frameWidth ,frameHeight )
						Self.img[i-1].SetFlagsMask(flags)
					Else
						If Self.img.Length = 1 Then
							Self.img[0] = Image.Load(path)
							Self.img[0].SetFlagsMask(flags)
						Else
							Self.img = Image.LoadFrames(path, fc, False, 0.5, 0.5, flags)
						Endif
					Endif
				Next
			Endif
		Endif
	End
	
	'------------------------------------------
'summery:Removes an ftImage.
	Method Remove:Void(discard:Bool = False)
		If discard = True
			For Local i:= 1 To Self.img.Length()
				Self.img[i-1].Discard()
			Next
		Endif
		'Self.img = Self.img.Resize(0)
		Self.img = []
		Self.engine = Null
		Self.imageNode.Remove()
	End
	'------------------------------------------
'summery:Sets the path (filename) of a ftImage.
	Method SetPath:String(filePath:String)
		Self.path = filePath
	End
End

'***************************************
'summery:The ftImageManager class handles all images for fantomX.
Class ftImageManager
'#DOCOFF#
	Field imageList := New List<ftImage>
	Field engine:ftEngine
'#DOCON#
	
	'-----------------------------------------------------------------------------
'summery:Creates an ftImage by grabbing it from a ftImage atlas.
	Method GrabImage:ftImage(atlas:ftImage, frameStartX:Int,frameStartY:Int,frameWidth:Int,frameHeight:Int,frameCount:Int, flags:Int=Image.Filter)
		Local newImg:ftImage = Null
		
		If newImg = Null Then 
			newImg = New ftImage
			newImg.engine = Self.engine
			newImg.atlas = atlas
			newImg.flags = flags
			newImg.frameHeight = frameHeight
			newImg.frameWidth = frameWidth
			newImg.frameStartX = frameStartX
			newImg.frameStartY = frameStartY
			newImg.isGrabed = True
			
			' Mark the atlas is being one
			atlas.isAtlas = True
			'tmpImg = atlas.img.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
			newImg.img = New Image[frameCount]
			
			Local xc :Int = atlas.img[0].Width()/frameWidth
			Local yc :Int = atlas.img[0].Height()/frameHeight
			Local i:Int = 0		
			'For Local y := 1 To yc
			'	For Local x := 1 To xc
			'		newImg.img[i] =	New Image( atlas.img[0], frameStartX+(frameWidth*(x-1)), frameStartY+(frameHeight*(y-1)), frameWidth ,frameHeight )
			'		newImg.img[i].SetFlagsMask(flags)
			'		i = i + 1
			'	Next
			'Next
			Local x:Int = 0
			Local y:Int = 0
			While i < frameCount
				newImg.img[i] =	New Image( atlas.img[0], frameStartX+(frameWidth*(x)), frameStartY+(frameHeight*(y)), frameWidth ,frameHeight )
				newImg.img[i].SetFlagsMask(flags)
				i = i + 1
				x = x + 1
				If x >= xc
					x = 0
					y = y + 1
				Endif
				If y >= yc
					Exit
				Endif
			Wend			
#If CONFIG="debug"
			If newImg.img[0] = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.GrabImage~n~nCould not grab image from atlas~n~n")
#End
			newImg.imageNode = Self.imageList.AddLast(newImg)
		Endif

		Return newImg
	End	
	
	'-----------------------------------------------------------------------------
'summery:Creates an ftImage by grabbing it from a Image atlas.
	Method GrabImage:ftImage(atlas:Image, frameStartX:Int,frameStartY:Int,frameWidth:Int,frameHeight:Int,frameCount:Int, flags:Int=Image.Filter)
		Local newImg:ftImage = Null
		If newImg = Null Then 
			newImg = New ftImage
			newImg.engine = Self.engine
			newImg.flags = flags
			newImg.frameHeight = frameHeight
			newImg.frameWidth = frameWidth
			newImg.frameStartX = frameStartX
			newImg.frameStartY = frameStartY
			newImg.isGrabed = True
			
			' Mark the atlas is being one
			For Local tmpImgNode := Eachin Self.imageList
				If tmpImgNode.img[0] = atlas Then 
					tmpImgNode.isAtlas = True
					newImg.atlas = tmpImgNode
					Exit
				Endif
			Next
			'tmpImg = atlas.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
			newImg.img = New Image[frameCount]

			Local xc :Int = atlas.Width()/frameWidth
			Local yc :Int = atlas.Height()/frameHeight
			Local i:Int = 0		

			Local x:Int = 0
			Local y:Int = 0
			While i < frameCount
				newImg.img[i] =	New Image( atlas, frameStartX+(frameWidth*(x)), frameStartY+(frameHeight*(y)), frameWidth ,frameHeight )
				newImg.img[i].SetFlagsMask(flags)
				i = i + 1
				x = x + 1
				If x >= xc
					x = 0
					y = y + 1
				Endif
				If y >= yc
					Exit
				Endif
			Wend
						

#If CONFIG="debug"
			If newImg.img[0] = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.GrabImage~n~nCould not grab image from atlas~n~n")
#End
			newImg.imageNode = Self.imageList.AddLast(newImg)
		Endif

		Return newImg
	End	

	'-----------------------------------------------------------------------------
#Rem
'summery:Creates an ftImage from an image.
#End
	Method LoadImage:ftImage(image:Image)

		Local newImg:ftImage = Null
		
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.img[0] = image Then 
				newImg = tmpImgNode
				Exit
			Endif
		Next
		
		If newImg = Null Then 
			newImg = New ftImage
			newImg.engine = Self.engine
			newImg.path = ""
			newImg.flags = image.FlagsMask()
			newImg.img = New Image[1]
			newImg.img[0] = New Image(image,0,0,image.Width(), image.Height())
			newImg.imageNode = Self.imageList.AddLast(newImg)
		Endif

		Return newImg
	End
	
	'-----------------------------------------------------------------------------
#Rem
'summery:Loads an image like mogo2.LoadImage.
#End
	Method LoadImage:ftImage(path:String, frameCount:Int=1, flags:Int=Image.Filter)
		Local newImg:ftImage = Null
		
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.path = path Then 
				newImg = tmpImgNode
				Exit
			Endif
		Next
		
		If newImg = Null Then 
			newImg = New ftImage
			newImg.engine = Self.engine
			newImg.path = path
			newImg.flags = flags

			newImg.img = Image.LoadFrames(path, frameCount, False, 0.5, 0.5, flags)
#If CONFIG="debug"
			If newImg.img[0] = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.LoadImage~n~nCould not load image~n~n"+path)
#End
			newImg.imageNode = Self.imageList.AddLast(newImg)
		Endif

		Return newImg
	End

	'-----------------------------------------------------------------------------
#Rem
'summery:Loads an image like mogo2.LoadImage.
#End
	Method LoadImage:ftImage(path:String,  frameWidth:Int, frameHeight:Int, frameCount:Int, flags:Int=Image.Filter)
		Local newImg:ftImage = Null
		Local tmpImg:Image = Null
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.path = path Then 
				newImg = tmpImgNode
				Exit
			Endif
		Next
		
		If newImg = Null Then 
			newImg = New ftImage
			newImg.engine = Self.engine
			newImg.path = path
			newImg.flags = flags
			newImg.frameHeight = frameHeight
			newImg.frameWidth = frameWidth

			tmpImg = Image.Load(path, 0.5, 0.5, flags)
			newImg.img = New Image[frameCount]
			'For Local i:= 1 To newImg.img.Length()
			'	newImg.img[i-1] =	New Image( tmpImg, frameWidth*(i-1), 0, frameWidth ,frameHeight )
			'	newImg.img[i-1].SetFlagsMask(flags)
			'Next
			
			Local xc :Int = tmpImg.Width()/frameWidth
			Local yc :Int = tmpImg.Height()/frameHeight
			Local i:Int = 0		
			'For Local y := 1 To yc
			'	For Local x := 1 To xc
			'		newImg.img[i] =	New Image( tmpImg, (frameWidth*(x-1)), (frameHeight*(y-1)), frameWidth ,frameHeight )
			'		newImg.img[i].SetFlagsMask(flags)
			'		i = i + 1
			'	Next
			'Next
						
			Local x:Int = 0
			Local y:Int = 0
			While i < frameCount
				newImg.img[i] =	New Image( tmpImg, (frameWidth*(x)), (frameHeight*(y)), frameWidth ,frameHeight )
				newImg.img[i].SetFlagsMask(flags)
				i = i + 1
				x = x + 1
				If x >= xc
					x = 0
					y = y + 1
				Endif
				If y >= yc
					Exit
				Endif
			Wend
		
			
			
			
			
			
#If CONFIG="debug"
			If newImg.img[0] = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.LoadImage~n~nCould not load image~n~n"+path)
#End
			newImg.imageNode = Self.imageList.AddLast(newImg)
			tmpImg.Discard()
		Endif

		Return newImg

	End
	'------------------------------------------
#Rem
'summery:Reload all images.
#End
	Method ReLoadAllImages:Void()
		' Reload sprite atlas
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isAtlas = True Then item.ReLoad()
		Next
		' Reload grabbed images
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isGrabed = True Then item.ReLoad()
		Next
		' Reload single images
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isGrabed = False And item.isAtlas = False Then item.ReLoad()
		Next
	End
	'------------------------------------------
#Rem
'summery:Removes all images from the image handler.
#End
	Method RemoveAllImages:Void(discard:Bool = False)
		For Local item:= Eachin Self.imageList.Backwards()
			item.Remove(discard)
		Next
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Removes an image from the image handler by the given Image handle.
#End
	Method RemoveImage:Void(image:Image, discard:Bool = False)
		For Local item := Eachin Self.imageList.Backwards()
			If item.img[0] = image Then
				item.Remove(discard)
				Exit
			Endif
		Next
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Removes an image from the image handler by the given filename.
#End
	Method RemoveImage:Void(filepath:String, discard:Bool = False)
		For Local item := Eachin Self.imageList.Backwards()
			If item.path = filepath Then
				item.Remove(discard)
				Exit
			Endif
		Next
	End
End


#rem
footer:This fantomX framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end