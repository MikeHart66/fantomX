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
'* Prismatic joint definition. This requires defining a line of
'* motion using an axis and an anchor point. The definition uses local
'* anchor points and a local axis so that the initial configuration
'* can violate the constraint slightly. The joint zero(translation)
'* when the local anchor points coincide in world space. Using local
'* anchors and a local axis helps when saving and loading a game.
'* @see b2PrismaticJoint
'*/
#end
Class b2PrismaticJointDef Extends b2JointDef
    
    Method New()
        Super.New()
        
        type = b2Joint.e_prismaticJoint
        '//localAnchor1.SetZero()
        '//localAnchor2.SetZero()
        localAxisA.Set(1.0, 0.0)
        referenceAngle = 0.0
        enableLimit = False
        lowerTranslation = 0.0
        upperTranslation = 0.0
        enableMotor = False
        maxMotorForce = 0.0
        motorSpeed = 0.0
    End
    Method Initialize : void (bA:b2Body, bB:b2Body, anchor:b2Vec2, axis:b2Vec2)
        
        bodyA = bA
        bodyB = bB
        bodyA.GetLocalPoint(anchor,localAnchorA)
        bodyB.GetLocalPoint(anchor,localAnchorB)
        bodyA.GetLocalVector(axis,localAxisA)
        referenceAngle = bodyB.GetAngle() - bodyA.GetAngle()
    End
    #rem
    '/**
    '* The local anchor point relative to bodyAs origin.
    '*/
    #end
    Field localAnchorA:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The local anchor point relative to bodyBs origin.
    '*/
    #end
    Field localAnchorB:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The local translation axis in body1.0
    '*/
    #end
    Field localAxisA:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The constrained angle between the bodies: bodyB_angle - bodyA_angle.
    '*/
    #end
    Field referenceAngle:Float
    
    #rem
    '/**
    '* Enable/disable the joint limit.
    '*/
    #end
    Field enableLimit:Bool
    
    #rem
    '/**
    '* The lower translation limit, usually in meters.
    '*/
    #end
    Field lowerTranslation:Float
    
    #rem
    '/**
    '* The upper translation limit, usually in meters.
    '*/
    #end
    Field upperTranslation:Float
    
    #rem
    '/**
    '* Enable/disable the joint motor.
    '*/
    #end
    Field enableMotor:Bool
    
    #rem
    '/**
    '* The maximum motor torque, usually in N-m.
    '*/
    #end
    Field maxMotorForce:Float
    
    #rem
    '/**
    '* The desired motor speed in radians per second.
    '*/
    #end
    Field motorSpeed:Float
    
    
End

