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
'* Pulley joint definition. This requires two ground anchors,
'* two  body anchor points, max lengths for each side,
'* and a pulley ratio.
'* @see b2PulleyJoint
'*/
#end
Class b2PulleyJointDef Extends b2JointDef
    
    Method New()
        Super.New()
        
        type = b2Joint.e_pulleyJoint
        groundAnchorA.Set(-1.0, 1.0)
        groundAnchorB.Set(1.0, 1.0)
        localAnchorA.Set(-1.0, 0.0)
        localAnchorB.Set(1.0, 0.0)
        lengthA = 0.0
        maxLengthA = 0.0
        lengthB = 0.0
        maxLengthB = 0.0
        ratio = 1.0
        collideConnected = True
    End
    Method Initialize : void (bA:b2Body, bB:b2Body,
        gaA:b2Vec2, gaB:b2Vec2,
        anchorA:b2Vec2, anchorB:b2Vec2,
        r:Float)
        
        bodyA = bA
        bodyB = bB
        groundAnchorA.SetV( gaA )
        groundAnchorB.SetV( gaB )
        bodyA.GetLocalPoint(anchorA,localAnchorA)
        bodyB.GetLocalPoint(anchorB,localAnchorB)
        '//b2Vec2 d1 = anchorA - gaA
        Local d1X :Float = anchorA.x - gaA.x
        Local d1Y :Float = anchorA.y - gaA.y
        '//length1 = d1.Length()
        lengthA = Sqrt(d1X*d1X + d1Y*d1Y)
        '//b2Vec2 d2 = anchor2 - ga2
        Local d2X :Float = anchorB.x - gaB.x
        Local d2Y :Float = anchorB.y - gaB.y
        '//length2 = d2.Length()
        lengthB = Sqrt(d2X*d2X + d2Y*d2Y)
        ratio = r
        '//b2Settings.B2Assert(ratio > Constants.EPSILON)
        Local C :Float = lengthA + ratio * lengthB
        maxLengthA = C - ratio * b2PulleyJoint.b2_minPulleyLength
        maxLengthB = (C - b2PulleyJoint.b2_minPulleyLength) / ratio
    End
    #rem
    '/**
    '* The first ground anchor in world coordinates. This point never moves.
    '*/
    #end
    Field groundAnchorA:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The second ground anchor in world coordinates. This point never moves.
    '*/
    #end
    Field groundAnchorB:b2Vec2 = New b2Vec2()
    
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
    '* The a reference length for the segment attached to bodyA.
    '*/
    #end
    Field lengthA:Float
    
    #rem
    '/**
    '* The maximum length of the segment attached to bodyA.
    '*/
    #end
    Field maxLengthA:Float
    
    #rem
    '/**
    '* The a reference length for the segment attached to bodyB.
    '*/
    #end
    Field lengthB:Float
    
    #rem
    '/**
    '* The maximum length of the segment attached to bodyB.
    '*/
    #end
    Field maxLengthB:Float
    
    #rem
    '/**
    '* The pulley ratio, used to simulate a block-and-tackle.
    '*/
    #end
    Field ratio:Float
    
End

