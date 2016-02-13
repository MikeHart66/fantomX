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
'* Revolute joint definition. This requires defining an
'* anchor point where the bodies are joined. The definition
'* uses local anchor points so that the initial configuration
'* can violate the constraint slightly. You also need to
'* specify the initial relative angle for joint limits. This
'* helps when saving and loading a game.
'* The local anchor points are measured from the bodys origin
'* rather than the center of mass because:
'* 1.0 you might not know where the center of mass will be.
'* 2.0 if you add/remove shapes from a body and recompute the mass,
'* the joints will be broken.
'* @see b2RevoluteJoint
'*/
#end
Class b2RevoluteJointDef Extends b2JointDef
    
    Method New()
        Super.New()
        type = b2Joint.e_revoluteJoint
        localAnchorA.Set(0.0, 0.0)
        localAnchorB.Set(0.0, 0.0)
        referenceAngle = 0.0
        lowerAngle = 0.0
        upperAngle = 0.0
        maxMotorTorque = 0.0
        motorSpeed = 0.0
        enableLimit = False
        enableMotor = False
    End
    
    #rem
    '/**
    '* Initialize the bodies, anchors, and reference angle using the world
    '* anchor.
    '*/
    #end
    Method Initialize : void (bA:b2Body, bB:b2Body, anchor:b2Vec2)
        bodyA = bA
        bodyB = bB
        bodyA.GetLocalPoint(anchor,localAnchorA)
        bodyB.GetLocalPoint(anchor,localAnchorB)
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
    '* The bodyB angle minus bodyA angle in the reference state (radians).
    '*/
    #end
    Field referenceAngle:Float
    
    #rem
    '/**
    '* A flag to enable joint limits.
    '*/
    #end
    Field enableLimit:Bool
    
    #rem
    '/**
    '* The lower angle for the joint limit (radians).
    '*/
    #end
    Field lowerAngle:Float
    
    #rem
    '/**
    '* The upper angle for the joint limit (radians).
    '*/
    #end
    Field upperAngle:Float
    
    #rem
    '/**
    '* A flag to enable the joint motor.
    '*/
    #end
    Field enableMotor:Bool
    
    #rem
    '/**
    '* The desired motor speed. Usually in radians per second.
    '*/
    #end
    Field motorSpeed:Float
    
    #rem
    '/**
    '* The maximum motor torque used to achieve the desired motor speed.
    '* Usually in N-m.
    '*/
    #end
    Field maxMotorTorque:Float
    
End

