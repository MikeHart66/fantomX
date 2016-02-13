Strict
#rem
'/*
'* Copyright (c) 2011, Damian Sinclair
'*
'* This is a port of Box2D by Erin Catto (box2d.org).
'* It is translated from the Flash port: Box2DFlash, by BorisTheBrave (http://www.box2dflash.org/).
'* Box2DFlash also credits Matt Bush and John Nesky as contributors.
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
'* THIS SOFTWARE IS PROVIDED BY THE MONKEYBOX2D PROJECT CONTRIBUTORS "AS IS" AND
'* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
'* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
'* DISCLAIMED. IN NO EVENT SHALL THE MONKEYBOX2D PROJECT CONTRIBUTORS BE LIABLE
'* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
'* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
'* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
'* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
'* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
'* DAMAGE.
'*/
#end
Import fantomX
#rem
'/**
'* Implement and register this class with a b2World to provide debug drawing of physics
'* entities in your game.
'*/
#end
Class b2DebugDraw
    Method New()
        m_drawFlags = 0
    End
    '// ~b2DebugDraw() {}
    '//enum
    '//{
    '* Draw shapes
    Global e_shapeBit:Int 			= $0001
    '* Draw joint connections
    Global e_jointBit:Int			= $0002
    '* Draw axis aligned bounding boxes
    Global e_aabbBit:Int			= $0004
    '* Draw broad-phase pairs
    Global e_pairBit:Int			= $0008
    '* Draw center of mass frame
    Global e_centerOfMassBit:Int	= $0010
    '* Draw controllers
    Global e_controllerBit:Int		= $0020
    '//}
    #rem
    '/**
    '* Set the drawing flags.
    '*/
    #end
    Method SetFlags : void (flags:Int)
        
        m_drawFlags = flags
    End
    #rem
    '/**
    '* Get the drawing flags.
    '*/
    #end
    Method GetFlags : Int ()
        
        Return m_drawFlags
    End
    #rem
    '/**
    '* Append flags to the current flags.
    '*/
    #end
    Method AppendFlags : void (flags:Int)
        
        m_drawFlags |= flags
    End
    #rem
    '/**
    '* Clear flags from the current flags.
    '*/
    #end
    Method ClearFlags : void (flags:Int)
        
        m_drawFlags &= ~flags
    End
    
    #rem
    '/**
    '* Set the draw scale
    '*/
    #end
    Method SetDrawScale : void (drawScale:Float)
        
        m_drawScale = drawScale
    End
    #rem
    '/**
    '* Get the draw
    '*/
    #end
    Method GetDrawScale : Float ()
        
        Return m_drawScale
    End
    #rem
    '/**
    '* Set the line thickness
    '*/
    #end
    Method SetLineThickness : void (lineThickness:Float)
        
        m_lineThickness = lineThickness
    End
    #rem
    '/**
    '* Get the line thickness
    '*/
    #end
    Method GetLineThickness : Float ()
        
        Return m_lineThickness
    End
    #rem
    '/**
    '* Set the alpha value used for lines
    '*/
    #end
    Method SetAlpha : void (alpha:Float)
        
        m_alpha = alpha
    End
    #rem
    '/**
    '* Get the alpha value used for lines
    '*/
    #end
    Method GetAlpha : Float ()
        
        Return m_alpha
    End
    #rem
    '/**
    '* Set the alpha value used for fills
    '*/
    #end
    Method SetFillAlpha : void (alpha:Float)
        
        m_fillAlpha = alpha
    End
    #rem
    '/**
    '* Get the alpha value used for fills
    '*/
    #end
    Method GetFillAlpha : Float ()
        
        Return m_fillAlpha
    End
    #rem
    '/**
    '* Set the scale used for drawing XForms
    '*/
    #end
    Method SetXFormScale : void (xformScale:Float)
        
        m_xformScale = xformScale
    End
    #rem
    '/**
    '* Get the scale used for drawing XForms
    '*/
    #end
    Method GetXFormScale : Float ()
        
        Return m_xformScale
    End
    #rem
    '/**
    '* Draw a closed polygon provided in CCW order.
    '*/
    #end
    Method DrawPolygon : void (vertices:b2Vec2[], vertexCount:Int, color:b2Color)
        'm_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha)
        b2dCanvas.SetAlpha(m_alpha)
        b2dCanvas.SetColor(color._r/255.0,color._g/255.0,color._b/255.0)
        Local i:Int
        For i = 0 Until vertexCount-1
            b2dCanvas.DrawLine(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale,
            vertices[i+1].x * m_drawScale, vertices[i+1].y * m_drawScale)
        End
        
        b2dCanvas.DrawLine(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale,
        vertices[0].x * m_drawScale, vertices[0].y * m_drawScale)
    End
    #rem
    '/**
    '* Draw a solid closed polygon provided in CCW order.
    '*/
    #end
    Method DrawSolidPolygon : void (vertices:b2Vec2[], vertexCount:Int, color:b2Color)
        'punt on the fill
        DrawPolygon(vertices, vertexCount, color)
    End
    #rem
    '/**
    '* Draw a circle.
    '*/
    #end
    Method DrawCircle : void (center:b2Vec2, radius:Float, color:b2Color)
        'm_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha)
        b2dCanvas.SetAlpha(m_alpha)
        b2dCanvas.SetColor(color._r/255.0,color._g/255.0,color._b/255.0)
        'mojo.graphics.DrawCircle((center.x * m_drawScale), (center.y * m_drawScale), radius * m_drawScale)
        b2dCanvas.DrawCircle((center.x * m_drawScale), (center.y * m_drawScale), radius * m_drawScale)
    End
    #rem
    '/**
    '* Draw a solid circle.
    '*/
    #end
    Method DrawSolidCircle : Void (center:b2Vec2, radius:Float, axis:b2Vec2, color:b2Color)
        b2dCanvas.SetAlpha(m_alpha)
        DrawCircle( center, radius, color)
        b2dCanvas.SetColor 64.0/255.0,64.0/255.0,64.0/255.0
        b2dCanvas.DrawLine(center.x * m_drawScale, center.y * m_drawScale,(center.x + axis.x*radius) * m_drawScale, (center.y + axis.y*radius) * m_drawScale)
        b2dCanvas.SetColor 1.0,1.0,1.0
    End
    #rem
    '/**
    '* Draw a line segment.
    '*/
    #end
    Method DrawSegment : void (p1:b2Vec2, p2:b2Vec2, color:b2Color)
        'm_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha)
        b2dCanvas.SetAlpha(m_alpha)
        b2dCanvas.SetColor(color._r/255.0,color._g/255.0,color._b/255.0)
        b2dCanvas.DrawLine(p1.x * m_drawScale, p1.y * m_drawScale, p2.x * m_drawScale, p2.y * m_drawScale)
    End
    #rem
    '/**
    '* Draw a transform. Choose your own length scale.
    '* @param xf a transform.
    '*/
    #end
    Method DrawTransform : void (xf:b2Transform)
        'm_sprite.graphics.lineStyle(m_lineThickness, $ff0000, m_alpha)
        b2dCanvas.SetAlpha(m_alpha)
        b2dCanvas.SetColor(1,0,0)
        b2dCanvas.DrawLine(xf.position.x * m_drawScale, xf.position.y * m_drawScale,(xf.position.x + m_xformScale*xf.R.col1.x) * m_drawScale, (xf.position.y + m_xformScale*xf.R.col1.y) * m_drawScale)
        'm_sprite.graphics.lineStyle(m_lineThickness, $00ff00, m_alpha)
        b2dCanvas.DrawLine(xf.position.x * m_drawScale, xf.position.y * m_drawScale,(xf.position.x + m_xformScale*xf.R.col2.x) * m_drawScale, (xf.position.y + m_xformScale*xf.R.col2.y) * m_drawScale)
    End
    
    Method SetSprite:Void( spr:FlashSprite)
        m_sprite = spr
    End
    
    Method Clear:Void()
        b2dCanvas.Clear(0,0,0)
    End
    
    Field m_drawFlags:Int
    
    
    Field m_sprite:FlashSprite
    
    
    Field m_drawScale:Float = 1.0
    
    Field m_lineThickness:Float = 1.0
    
    
    Field m_alpha:Float = 1.0
    
    
    Field m_fillAlpha:Float = 1.0
    
    
    Field m_xformScale:Float = 1.0
    
End




