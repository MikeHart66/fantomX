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
'* A fixture used(definition) to create a fixture. This class defines an
'* abstract fixture definition. You can reuse fixture definitions safely.
'*/
#end
Class b2FixtureDef
    #rem
    '/**
    '* The constructor sets the default fixture definition values.
    '*/
    #end
    Method New()
        
        shape = null
        userData = null
        friction = 0.2
        restitution = 0.0
        density = 0.0
        filter.categoryBits = $0001
        filter.maskBits = $FFFF
        filter.groupIndex = 0
        isSensor = False
    End
    #rem
    '/**
    '* The shape, this must be set. The shape will be cloned, so you
    '* can create the shape on the stack.
    '*/
    #end
    Field shape:b2Shape
    #rem
    '/**
    '* Use this to store application specific fixture data.
    '*/
    #end
    Field userData: Object
    #rem
    '/**
    '* The friction coefficient, usually in the range [0,1].
    '*/
    #end
    Field friction:Float
    #rem
    '/**
    '* The restitution (elasticity) usually in the range [0,1].
    '*/
    #end
    Field restitution:Float
    #rem
    '/**
    '* The density, usually in kg/m^2.0
    '*/
    #end
    Field density:Float
    #rem
    '/**
    '* A sensor shape collects contact information but never generates a collision
    '* response.
    '*/
    #end
    Field isSensor:Bool
    #rem
    '/**
    '* Contact filtering data.
    '*/
    #end
    Field filter:b2FilterData = New b2FilterData()
    
End
