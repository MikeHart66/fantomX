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
'* A gear used(joint) to connect two joints together. Either joint
'* can be a revolute or prismatic joint. You specify a gear ratio
'* to bind the motions together:
'* coordinate1 + ratio * coordinate2 = constant
'* The ratio can be negative or positive. If one a(joint) revolute joint
'* and the other a(joint) prismatic joint, then the ratio will have units
'* of length or units of 1/length.
'* @warning The revolute and prismatic joints must be attached to
'* fixed bodies (which must be body1 on those joints).
'* @see b2GearJointDef
'*/
#end
Class b2GearJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void (out:b2Vec2)
        '//return m_bodyA->GetWorldPoint(m_localAnchor1)
        m_bodyA.GetWorldPoint(m_localAnchor1, out)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        '//return m_bodyB->GetWorldPoint(m_localAnchor2)
        m_bodyB.GetWorldPoint(m_localAnchor2,out)
    End
    
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float, out:b2Vec2)
        '// TODO_ERIN not tested
        '// b2Vec2 P = m_impulse * m_J.linear2
        '//return inv_dt * P
        out.Set(inv_dt * m_impulse * m_J.linearB.x, inv_dt * m_impulse * m_J.linearB.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        '// TODO_ERIN not tested
        '//b2Vec2 r = b2Mul(m_bodyB->m_xf.R, m_localAnchor2 - m_bodyB->GetLocalCenter())
        Local tMat :b2Mat22 = m_bodyB.m_xf.R
        Local rX :Float = m_localAnchor1.x - m_bodyB.m_sweep.localCenter.x
        Local rY :Float = m_localAnchor1.y - m_bodyB.m_sweep.localCenter.y
        Local tX :Float = tMat.col1.x * rX + tMat.col2.x * rY
        rY = tMat.col1.y * rX + tMat.col2.y * rY
        rX = tX
        '//b2Vec2 P = m_impulse * m_J.linearB
        Local PX :Float = m_impulse * m_J.linearB.x
        Local PY :Float = m_impulse * m_J.linearB.y
        '//float32 L = m_impulse * m_J.angularB - b2Cross(r, P)
        '//return inv_dt * L
        Return inv_dt * (m_impulse * m_J.angularB - rX * PY + rY * PX)
    End
    #rem
    '/**
    '* Get the gear ratio.
    '*/
    #end
    Method GetRatio : Float ()
        
        Return m_ratio
    End
    #rem
    '/**
    '* Set the gear ratio.
    '*/
    #end
    Method SetRatio : void (ratio:Float)
        
        '//b2Settings.B2Assert(b2Math.b2IsValid(ratio))
        m_ratio = ratio
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2GearJointDef)
        
        '// parent constructor
        Super.New(def)
        Local type1 :Int = def.joint1.m_type
        Local type2 :Int = def.joint2.m_type
        '//b2Settings.B2Assert(type1 = b2Joint.e_revoluteJoint Or type1 = b2Joint.e_prismaticJoint)
        '//b2Settings.B2Assert(type2 = b2Joint.e_revoluteJoint Or type2 = b2Joint.e_prismaticJoint)
        '//b2Settings.B2Assert(def.joint1.GetBodyA().GetType() = b2Body.b2_staticBody)
        '//b2Settings.B2Assert(def.joint2.GetBodyA().GetType() = b2Body.b2_staticBody)
        m_revolute1 = null
        m_prismatic1 = null
        m_revolute2 = null
        m_prismatic2 = null
        Local coordinate1 :Float
        Local coordinate2 :Float
        m_ground1 = def.joint1.GetBodyA()
        m_bodyA = def.joint1.GetBodyB()
        If (type1 = b2Joint.e_revoluteJoint)
            
            m_revolute1 = b2RevoluteJoint(def.joint1)
            m_groundAnchor1.SetV( m_revolute1.m_localAnchor1 )
            m_localAnchor1.SetV( m_revolute1.m_localAnchor2 )
            coordinate1 = m_revolute1.GetJointAngle()
        Else
            
            
            m_prismatic1 = b2PrismaticJoint(def.joint1)
            m_groundAnchor1.SetV( m_prismatic1.m_localAnchor1 )
            m_localAnchor1.SetV( m_prismatic1.m_localAnchor2 )
            coordinate1 = m_prismatic1.GetJointTranslation()
        End
        m_ground2 = def.joint2.GetBodyA()
        m_bodyB = def.joint2.GetBodyB()
        If (type2 = b2Joint.e_revoluteJoint)
            
            m_revolute2 = b2RevoluteJoint(def.joint2)
            m_groundAnchor2.SetV( m_revolute2.m_localAnchor1 )
            m_localAnchor2.SetV( m_revolute2.m_localAnchor2 )
            coordinate2 = m_revolute2.GetJointAngle()
        Else
            
            
            m_prismatic2 = b2PrismaticJoint(def.joint2)
            m_groundAnchor2.SetV( m_prismatic2.m_localAnchor1 )
            m_localAnchor2.SetV( m_prismatic2.m_localAnchor2 )
            coordinate2 = m_prismatic2.GetJointTranslation()
        End
        m_ratio = def.ratio
        m_constant = coordinate1 + m_ratio * coordinate2
        m_impulse = 0.0
    End
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local g1 :b2Body = m_ground1
        Local g2 :b2Body = m_ground2
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        '// temp vars
        Local ugX :Float
        Local ugY :Float
        Local rX :Float
        Local rY :Float
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        Local crug :Float
        Local tX :Float
        Local K :Float = 0.0
        m_J.SetZero()
        If (m_revolute1)
            
            m_J.angularA = -1.0
            K += bA.m_invI
        Else
            
            
            '//b2Vec2 ug = b2MulMV(g1->m_xf.R, m_prismatic1->m_localXAxis1)
            tMat = g1.m_xf.R
            tVec = m_prismatic1.m_localXAxis1
            ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
            ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
            '//b2Vec2 r = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
            tMat = bA.m_xf.R
            rX = m_localAnchor1.x - bA.m_sweep.localCenter.x
            rY = m_localAnchor1.y - bA.m_sweep.localCenter.y
            tX = tMat.col1.x * rX + tMat.col2.x * rY
            rY = tMat.col1.y * rX + tMat.col2.y * rY
            rX = tX
            '//var crug:Float = b2Cross(r, ug)
            crug = rX * ugY - rY * ugX
            '//m_J.linearA = -ug
            m_J.linearA.Set(-ugX, -ugY)
            m_J.angularA = -crug
            K += bA.m_invMass + bA.m_invI * crug * crug
        End
        If (m_revolute2)
            
            m_J.angularB = -m_ratio
            K += m_ratio * m_ratio * bB.m_invI
        Else
            
            
            '//b2Vec2 ug = b2Mul(g2->m_xf.R, m_prismatic2->m_localXAxis1)
            tMat = g2.m_xf.R
            tVec = m_prismatic2.m_localXAxis1
            ugX = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y
            ugY = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y
            '//b2Vec2 r = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
            tMat = bB.m_xf.R
            rX = m_localAnchor2.x - bB.m_sweep.localCenter.x
            rY = m_localAnchor2.y - bB.m_sweep.localCenter.y
            tX = tMat.col1.x * rX + tMat.col2.x * rY
            rY = tMat.col1.y * rX + tMat.col2.y * rY
            rX = tX
            '//float32 crug = b2Cross(r, ug)
            crug = rX * ugY - rY * ugX
            '//m_J.linearB = -m_ratio * ug
            m_J.linearB.Set(-m_ratio*ugX, -m_ratio*ugY)
            m_J.angularB = -m_ratio * crug
            K += m_ratio * m_ratio * (bB.m_invMass + bB.m_invI * crug * crug)
        End
        '// Compute effective mass.
        If( K > 0.0 )
            m_mass =1.0 / K
        Else
            
            
            m_mass =0.0
            
        End
        If (timeStep.warmStarting)
            
            '// Warm starting.
            '//bA.m_linearVelocity += bA.m_invMass * m_impulse * m_J.linearA
            bA.m_linearVelocity.x += bA.m_invMass * m_impulse * m_J.linearA.x
            bA.m_linearVelocity.y += bA.m_invMass * m_impulse * m_J.linearA.y
            bA.m_angularVelocity += bA.m_invI * m_impulse * m_J.angularA
            '//bB.m_linearVelocity += bB.m_invMass * m_impulse * m_J.linearB
            bB.m_linearVelocity.x += bB.m_invMass * m_impulse * m_J.linearB.x
            bB.m_linearVelocity.y += bB.m_invMass * m_impulse * m_J.linearB.y
            bB.m_angularVelocity += bB.m_invI * m_impulse * m_J.angularB
        Else
            
            
            m_impulse = 0.0
        End
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        '//B2_NOT_USED(timeStep)
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local Cdot :Float = m_J.Compute(	bA.m_linearVelocity, bA.m_angularVelocity,
        bB.m_linearVelocity, bB.m_angularVelocity)
        Local impulse :Float = - m_mass * Cdot
        m_impulse += impulse
        bA.m_linearVelocity.x += bA.m_invMass * impulse * m_J.linearA.x
        bA.m_linearVelocity.y += bA.m_invMass * impulse * m_J.linearA.y
        bA.m_angularVelocity  += bA.m_invI * impulse * m_J.angularA
        bB.m_linearVelocity.x += bB.m_invMass * impulse * m_J.linearB.x
        bB.m_linearVelocity.y += bB.m_invMass * impulse * m_J.linearB.y
        bB.m_angularVelocity  += bB.m_invI * impulse * m_J.angularB
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        '//B2_NOT_USED(baumgarte)
        Local linearError :Float = 0.0
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local coordinate1 :Float
        Local coordinate2 :Float
        If (m_revolute1)
            
            coordinate1 = m_revolute1.GetJointAngle()
        Else
            
            
            coordinate1 = m_prismatic1.GetJointTranslation()
        End
        If (m_revolute2)
            
            coordinate2 = m_revolute2.GetJointAngle()
        Else
            
            
            coordinate2 = m_prismatic2.GetJointTranslation()
        End
        Local C :Float = m_constant - (coordinate1 + m_ratio * coordinate2)
        Local impulse :Float = -m_mass * C
        bA.m_sweep.c.x += bA.m_invMass * impulse * m_J.linearA.x
        bA.m_sweep.c.y += bA.m_invMass * impulse * m_J.linearA.y
        bA.m_sweep.a += bA.m_invI * impulse * m_J.angularA
        bB.m_sweep.c.x += bB.m_invMass * impulse * m_J.linearB.x
        bB.m_sweep.c.y += bB.m_invMass * impulse * m_J.linearB.y
        bB.m_sweep.a += bB.m_invI * impulse * m_J.angularB
        bA.SynchronizeTransform()
        bB.SynchronizeTransform()
        '// TODO_ERIN not implemented
        Return linearError < b2Settings.b2_linearSlop
    End
    Field m_ground1:b2Body
    
    
    Field m_ground2:b2Body
    
    '// One of NULL(these).
    Field m_revolute1:b2RevoluteJoint
    
    
    Field m_prismatic1:b2PrismaticJoint
    
    '// One of NULL(these).
    Field m_revolute2:b2RevoluteJoint
    
    
    Field m_prismatic2:b2PrismaticJoint
    
    Field m_groundAnchor1:b2Vec2 = New b2Vec2()
    
    
    Field m_groundAnchor2:b2Vec2 = New b2Vec2()
    
    Field m_localAnchor1:b2Vec2 = New b2Vec2()
    
    
    Field m_localAnchor2:b2Vec2 = New b2Vec2()
    
    Field m_J:b2Jacobian = New b2Jacobian()
    
    Field m_constant:Float
    
    
    Field m_ratio:Float
    
    '// Effective mass
    Field m_mass:Float
    
    '// Impulse for accumulation/warm starting.
    Field m_impulse:Float
    
    
End

