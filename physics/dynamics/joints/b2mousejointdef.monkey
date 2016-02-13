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
'* Mouse joint definition. This requires a world target point,
'* tuning parameters, and the time timeStep.
'* @see b2MouseJoint
'*/
#end
Class b2MouseJointDef Extends b2JointDef
    
    Method New()
        Super.New()
        
        type = b2Joint.e_mouseJoint
        maxForce = 0.0
        frequencyHz = 5.0
        dampingRatio = 0.7
    End
    #rem
    '/**
    '* The initial world target point. assumed(This)
    '* to coincide with the body anchor initially.
    '*/
    #end
    Field target:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The maximum constraint force that can be exerted
    '* to move the candidate body. Usually you will express
    '* as some multiple of the weight (multiplier * mass * gravity).
    '*/
    #end
    Field maxForce:Float
    
    #rem
    '/**
    '* The response speed.
    '*/
    #end
    Field frequencyHz:Float
    
    #rem
    '/**
    '* The damping ratio. 0 = no damping, 1 = critical damping.
    '*/
    #end
    Field dampingRatio:Float
    
    
End

