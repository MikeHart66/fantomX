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
'* Distance joint definition. This requires defining an
'* anchor point on both bodies and the non-zero length of the
'* distance joint. The definition uses local anchor points
'* so that the initial configuration can violate the constraint
'* slightly. This helps when saving and loading a game.
'* @warning Do not use a zero or short length.
'* @see b2DistanceJoint
'*/
#end
Class b2DistanceJointDef Extends b2JointDef
    
    Method New()
        Super.New()
        type = b2Joint.e_distanceJoint
        '//localAnchor1.Set(0.0, 0.0)
        '//localAnchor2.Set(0.0, 0.0)
        Length = 1.0
        frequencyHz = 0.0
        dampingRatio = 0.0
    End
    #rem
    '/**
    '* Initialize the bodies, anchors, and length using the world
    '* anchors.
    '*/
    #end
    Method Initialize : void (bA:b2Body, bB:b2Body,
        anchorA:b2Vec2, anchorB:b2Vec2)
        
        bodyA = bA
        bodyB = bB
        bodyA.GetLocalPoint(anchorA,localAnchorA)
        bodyB.GetLocalPoint(anchorB,localAnchorB)
        Local dX :Float = anchorB.x - anchorA.x
        Local dY :Float = anchorB.y - anchorA.y
        Length = Sqrt(dX*dX + dY*dY)
        frequencyHz = 0.0
        dampingRatio = 0.0
    End
    #rem
    '/**
    '* The local anchor point relative to body1s origin.
    '*/
    #end
    Field localAnchorA:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The local anchor point relative to body2s origin.
    '*/
    #end
    Field localAnchorB:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The natural length between the anchor points.
    '*/
    #end
    Field Length:Float
    
    #rem
    '/**
    '* The mass-spring-damper frequency in Hertz.
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

