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
'* A 2-by-2 matrix. Stored in column-major order.
'*/
#end
Class b2Mat22
    
    Method New()
        col2.y = 1.0
        col1.x = 1.0
    End
    
    Function FromAngle : b2Mat22 (angle:Float)
        Local mat :b2Mat22 = New b2Mat22()
        mat.Set(angle)
        Return mat
    End
    
    Function FromVV : b2Mat22 (c1:b2Vec2, c2:b2Vec2)
        Local mat :b2Mat22 = New b2Mat22()
        mat.SetVV(c1, c2)
        Return mat
    End
    
    Method Set : void (angle:Float)
        Local c :Float = Cosr(angle)
        Local s :Float = Sinr(angle)
        col1.x = c
        col2.x = -s
        col1.y = s
        col2.y = c
    End
    
    Method SetVV : void (c1:b2Vec2, c2:b2Vec2)
        col1.SetV(c1)
        col2.SetV(c2)
    End
    
    Method Copy : b2Mat22 ()
        Local mat :b2Mat22 = New b2Mat22()
        mat.SetM(Self)
        Return mat
    End
    
    Method SetM : void (m:b2Mat22)
        col1.x = m.col1.x
        col1.y = m.col1.y
        col2.x = m.col2.x
        col2.y = m.col2.y
    End
    
    Method AddM : void (m:b2Mat22)
        col1.x += m.col1.x
        col1.y += m.col1.y
        col2.x += m.col2.x
        col2.y += m.col2.y
    End
    
    Method SetIdentity : void ()
        col1.x = 1.0
        col2.x = 0.0
        col1.y = 0.0
        col2.y = 1.0
    End
    
    Method SetZero : void ()
        col1.x = 0.0
        col2.x = 0.0
        col1.y = 0.0
        col2.y = 0.0
    End
    
    Method GetAngle : Float ()
        Return ATan2r(col1.y, col1.x)
    End
    
    #rem
    '/**
    '* Compute the inverse of this matrix, such that inv(A) * A = identity.
    '*/
    #end
    Method GetInverse : b2Mat22 (out:b2Mat22)
        Local a :Float = col1.x
        Local b :Float = col2.x
        Local c :Float = col1.y
        Local d :Float = col2.y
        '//var B:b2Mat22 = New b2Mat22()
        Local det :Float = a * d - b * c
    
        If (det <> 0.0)
            det = 1.0 / det
        End
        
        out.col1.x =  det * d
        out.col2.x = -det * b
        out.col1.y = -det * c
        out.col2.y =  det * a
        Return out
    End
    
    '// Solve A * x = b
    Method Solve : b2Vec2 (out:b2Vec2, bX:Float, bY:Float)
        
        '//float32 a11 = col1.x, a12 = col2.x, a21 = col1.y, a22 = col2.y
        Local a11 :Float = col1.x
        Local a12 :Float = col2.x
        Local a21 :Float = col1.y
        Local a22 :Float = col2.y
        '//float32 det = a11 * a22 - a12 * a21
        Local det :Float = a11 * a22 - a12 * a21
    
        If (det <> 0.0)
            det = 1.0 / det
        End
        
        out.x = det * (a22 * bX - a12 * bY)
        out.y = det * (a11 * bY - a21 * bX)
        Return out
    End
    
    Method Abs : void ()
        col1.Abs()
        col2.Abs()
    End
    
    Field col1:b2Vec2 = New b2Vec2()
    Field col2:b2Vec2 = New b2Vec2()
    
End

