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
'* @
'*/
#end
Class b2Jacobian
    
    Field linearA:b2Vec2 = New b2Vec2()
    Field angularA:Float
    Field linearB:b2Vec2 = New b2Vec2()
    Field angularB:Float
    Method SetZero : void ()
        
        linearA.SetZero()
        
        angularA = 0.0
        linearB.SetZero()
        angularB = 0.0
    End
    
    Method Set : void (x1:b2Vec2, a1:Float, x2:b2Vec2, a2:Float)
        
        linearA.SetV(x1)
        
        angularA = a1
        linearB.SetV(x2)
        angularB = a2
    End
    
    Method Compute : Float (x1:b2Vec2, a1:Float, x2:b2Vec2, a2:Float)
        '//return b2Math.b2Dot(linearA, x1) + angularA * a1 + b2Math.b2Dot(linearV, x2) + angularV * a2
        Return (linearA.x*x1.x + linearA.y*x1.y) + angularA * a1 + (linearB.x*x2.x + linearB.y*x2.y) + angularB * a2
    End
End
