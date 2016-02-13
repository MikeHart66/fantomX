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

#rem
'//Attributions for this file
'//Ported to Monkey by Skn3 http://www.skn3.com
'//Ported to AS3 by Allan Bishop http:'//allanbishop.com
#end

Import fantomX

#rem
/// Rope joint definition. This requires two body anchor points and
/// a maximum lengths.
/// Note: by default the connected objects will not collide.
/// see collideConnected in b2JointDef.
#end
class b2RopeJointDef Extends b2JointDef
    Method New()
        Super.New()
		type = b2Joint.e_ropeJoint
		localAnchorA.Set(-1.0, 0.0)
		localAnchorB.Set(1.0, 0.0)
		maxLength = 0
	End
	
	Method Initialize:Void(bA:b2Body, bB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2, maxLength:Float)
		bodyA = bA;
		bodyB = bB;
		'localAnchorA.SetV(bodyA.GetLocalPoint(anchorA))  'MikeHart 20151030
		'localAnchorB.SetV(bodyB.GetLocalPoint(anchorB))  'MikeHart 20151030
		localAnchorA.SetV(bodyA.GetLocalPointR(anchorA))  'MikeHart 20151030
		localAnchorB.SetV(bodyB.GetLocalPointR(anchorB))  'MikeHart 20151030
		Local dX:Float = anchorB.x - anchorA.x
		Local dY:Float = anchorB.y - anchorA.y
		'length = Math.sqrt(dX * dX + dY * dY)  'MikeHart 20151030
		length = Sqrt(dX * dX + dY * dY)  'MikeHart 20151030
		'this.maxLength = maxLength	'MikeHart 20151030
		Self.maxLength = maxLength	'MikeHart 20151030

	End

	Field localAnchorA:b2Vec2 = New b2Vec2()
	Field localAnchorB:b2Vec2 = New b2Vec2()
	Field maxLength:Float
	Field length:Float
End