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
'* A 3-by-3 matrix. Stored in column-major order.
'*/
#end
Class b2Mat33
    
    Method New(c1:b2Vec3=null, c2:b2Vec3=null, c3:b2Vec3=null)
        
        If (Not(c1) And Not(c2) And Not(c3))
            
            col1.SetZero()
            col2.SetZero()
            col3.SetZero()
        Else
            
            col1.SetV(c1)
            col2.SetV(c2)
            col3.SetV(c3)
        End
    End
    Method SetVVV : void (c1:b2Vec3, c2:b2Vec3, c3:b2Vec3)
        
        col1.SetV(c1)
        col2.SetV(c2)
        col3.SetV(c3)
    End
    Method Copy : b2Mat33 ()
        
        Return New b2Mat33(col1, col2, col3)
    End
    Method SetM : void (m:b2Mat33)
        
        col1.SetV(m.col1)
        col2.SetV(m.col2)
        col3.SetV(m.col3)
    End
    Method AddM : void (m:b2Mat33)
        
        col1.x += m.col1.x
        col1.y += m.col1.y
        col1.z += m.col1.z
        col2.x += m.col2.x
        col2.y += m.col2.y
        col2.z += m.col2.z
        col3.x += m.col3.x
        col3.y += m.col3.y
        col3.z += m.col3.z
    End
    Method SetIdentity : void ()
        
        col1.x = 1.0
        
        col2.x = 0.0
        
        col3.x = 0.0
        col1.y = 0.0
        col2.y = 1.0
        col3.y = 0.0
        col1.z = 0.0
        col2.z = 0.0
        col3.z = 1.0
    End
    Method SetZero : void ()
        
        col1.x = 0.0
        
        col2.x = 0.0
        
        col3.x = 0.0
        col1.y = 0.0
        col2.y = 0.0
        col3.y = 0.0
        col1.z = 0.0
        col2.z = 0.0
        col3.z = 0.0
    End
    '// Solve A * x = b
    Method Solve22 : b2Vec2 (out:b2Vec2, bX:Float, bY:Float)
        
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
    '// Solve A * x = b
    Method Solve33 : b2Vec3 (out:b2Vec3, bX:Float, bY:Float, bZ:Float)
        
        Local a11 :Float = col1.x
        Local a21 :Float = col1.y
        Local a31 :Float = col1.z
        Local a12 :Float = col2.x
        Local a22 :Float = col2.y
        Local a32 :Float = col2.z
        Local a13 :Float = col3.x
        Local a23 :Float = col3.y
        Local a33 :Float = col3.z
        '//float32 det = b2Dot(col1, b2Cross(col2, col3))
        Local det :Float = 	a11 * (a22 * a33 - a32 * a23) +
        a21 * (a32 * a13 - a12 * a33) +
        a31 * (a12 * a23 - a22 * a13)
        If (det <> 0.0)
            
            det = 1.0 / det
        End
        
        '//out.x = det * b2Dot(b, b2Cross(col2, col3))
        out.x = det * (	bX * (a22 * a33 - a32 * a23) +
        bY * (a32 * a13 - a12 * a33) +
        bZ * (a12 * a23 - a22 * a13) )
        '//out.y = det * b2Dot(col1, b2Cross(b, col3))
        out.y = det * (	a11 * (bY * a33 - bZ * a23) +
        a21 * (bZ * a13 - bX * a33) +
        a31 * (bX * a23 - bY * a13))
        '//out.z = det * b2Dot(col1, b2Cross(col2, b))
        out.z = det * (	a11 * (a22 * bZ - a32 * bY) +
        a21 * (a32 * bX - a12 * bZ) +
        a31 * (a12 * bY - a22 * bX))
        Return out
    End
    Field col1:b2Vec3 = New b2Vec3()
    
    Field col2:b2Vec3 = New b2Vec3()
    
    Field col3:b2Vec3 = New b2Vec3()
    
End
