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
'* A transform contains translation and rotation. used(It) to represent
'* the position and orientation of rigid frames.
'*/
#end
Class b2Transform
    #rem
    '/**
    '* The default constructor does nothing (for performance).
    '*/
    #end
    Method New (pos:b2Vec2=null, r:b2Mat22=null)
        
        If (pos)
            
            position.SetV(pos)
            R.SetM(r)
        End
    End
    #rem
    '/**
    '* Initialize using a position vector and a rotation matrix.
    '*/
    #end
    Method Initialize : void (pos:b2Vec2, r:b2Mat22)
        
        position.SetV(pos)
        R.SetM(r)
    End
    #rem
    '/**
    '* Set this to the identity transform.
    '*/
    #end
    Method SetIdentity : void ()
        
        position.SetZero()
        R.SetIdentity()
    End
    Method Set : void (x:b2Transform)
        position.SetV(x.position)
        R.SetM(x.R)
    End
    #rem
    '/**
    '* Calculate the angle that the rotation matrix represents.
    '*/
    #end
    Method GetAngle : Float ()
        
        Return ATan2r(R.col1.y, R.col1.x)
    End
    Field position:b2Vec2 = New b2Vec2
    
    
    Field R:b2Mat22 = New b2Mat22()
    
    
End

