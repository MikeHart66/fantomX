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
'* The pulley connected(joint) to two bodies and two fixed ground points.
'* The pulley supports a ratio such that:
'* length1 + ratio * length2 <= constant
'* Yes, the force scaled(transmitted) by the ratio.
'* The pulley also enforces a maximum length limit on both sides. This is
'* useful to prevent one side of the pulley hitting the top.
'* @see b2PulleyJointDef
'*/
#end
Class b2PulleyJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void(out:b2Vec2)
        m_bodyA.GetWorldPoint(m_localAnchor1, out)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        m_bodyB.GetWorldPoint(m_localAnchor2,out)
    End
    
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float, out:b2Vec2)
        '//b2Vec2 P = m_impulse * m_u2
        '//return inv_dt * P
        out.Set(inv_dt * m_impulse * m_u2.x, inv_dt * m_impulse * m_u2.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        '//B2_NOT_USED(inv_dt)
        Return 0.0
    End
    
    #rem
    '/**
    '* Get the first ground anchor.
    '*/
    #end
    Method GetGroundAnchorA:Void (out:b2Vec2)
        '//return m_ground.m_xf.position + m_groundAnchor1
        out.SetV(m_ground.m_xf.position)
        out.Add(m_groundAnchor1)
    End
    
    #rem
    '/**
    '* Get the second ground anchor.
    '*/
    #end
    Method GetGroundAnchorB:Void (out:b2Vec2)
        '//return m_ground.m_xf.position + m_groundAnchor2
        out.SetV( m_ground.m_xf.position)
        out.Add(m_groundAnchor2)
    End
    
    #rem
    '/**
    '* Get the current length of the segment attached to body1.0
    '*/
    #end
    Method GetLength1 : Float ()
        Local p :b2Vec2 = New b2Vec2()
        m_bodyA.GetWorldPoint(m_localAnchor1,p)
        '//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor1
        Local sX :Float = m_ground.m_xf.position.x + m_groundAnchor1.x
        Local sY :Float = m_ground.m_xf.position.y + m_groundAnchor1.y
        '//b2Vec2 d = p - s
        Local dX :Float = p.x - sX
        Local dY :Float = p.y - sY
        '//return d.Length()
        Return Sqrt(dX*dX + dY*dY)
    End
    
    #rem
    '/**
    '* Get the current length of the segment attached to body2.0
    '*/
    #end
    Method GetLength2 : Float ()
        
        Local p :b2Vec2 = New b2Vec2()
        m_bodyB.GetWorldPoint(m_localAnchor2,p)
        '//b2Vec2 s = m_ground->m_xf.position + m_groundAnchor2
        Local sX :Float = m_ground.m_xf.position.x + m_groundAnchor2.x
        Local sY :Float = m_ground.m_xf.position.y + m_groundAnchor2.y
        '//b2Vec2 d = p - s
        Local dX :Float = p.x - sX
        Local dY :Float = p.y - sY
        '//return d.Length()
        Return Sqrt(dX*dX + dY*dY)
    End
    
    #rem
    '/**
    '* Get the pulley ratio.
    '*/
    #end
    Method GetRatio : Float ()
        
        Return m_ratio
    End
    
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2PulleyJointDef)
        '// parent
        Super.New(def)
        Local tMat :b2Mat22
        Local tX :Float
        Local tY :Float
        m_ground = m_bodyA.m_world.m_groundBody
        '//m_groundAnchor1 = def->groundAnchorA - m_ground->m_xf.position
        m_groundAnchor1.x = def.groundAnchorA.x - m_ground.m_xf.position.x
        m_groundAnchor1.y = def.groundAnchorA.y - m_ground.m_xf.position.y
        '//m_groundAnchor2 = def->groundAnchorB - m_ground->m_xf.position
        m_groundAnchor2.x = def.groundAnchorB.x - m_ground.m_xf.position.x
        m_groundAnchor2.y = def.groundAnchorB.y - m_ground.m_xf.position.y
        '//m_localAnchor1 = def->localAnchorA
        m_localAnchor1.SetV(def.localAnchorA)
        '//m_localAnchor2 = def->localAnchorB
        m_localAnchor2.SetV(def.localAnchorB)
        '//b2Settings.B2Assert(def.ratio <> 0.0)
        m_ratio = def.ratio
        m_constant = def.lengthA + m_ratio * def.lengthB
        m_maxLength1 = b2Math.Min(def.maxLengthA, m_constant - m_ratio * b2_minPulleyLength)
        m_maxLength2 = b2Math.Min(def.maxLengthB, (m_constant - b2_minPulleyLength) / m_ratio)
        m_impulse = 0.0
        m_limitImpulse1 = 0.0
        m_limitImpulse2 = 0.0
    End
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local r1X :Float = m_localAnchor1.x - bA.m_sweep.localCenter.x
        Local r1Y :Float = m_localAnchor1.y - bA.m_sweep.localCenter.y
        Local tX :Float =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
        r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
        r1X = tX
        '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local r2X :Float = m_localAnchor2.x - bB.m_sweep.localCenter.x
        Local r2Y :Float = m_localAnchor2.y - bB.m_sweep.localCenter.y
        tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
        r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
        r2X = tX
        '//b2Vec2 p1 = bA->m_sweep.c + r1
        Local p1X :Float = bA.m_sweep.c.x + r1X
        Local p1Y :Float = bA.m_sweep.c.y + r1Y
        '//b2Vec2 p2 = bB->m_sweep.c + r2
        Local p2X :Float = bB.m_sweep.c.x + r2X
        Local p2Y :Float = bB.m_sweep.c.y + r2Y
        '//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1
        Local s1X :Float = m_ground.m_xf.position.x + m_groundAnchor1.x
        Local s1Y :Float = m_ground.m_xf.position.y + m_groundAnchor1.y
        '//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2
        Local s2X :Float = m_ground.m_xf.position.x + m_groundAnchor2.x
        Local s2Y :Float = m_ground.m_xf.position.y + m_groundAnchor2.y
        '// Get the pulley axes.
        '//m_u1 = p1 - s1
        m_u1.Set(p1X - s1X, p1Y - s1Y)
        '//m_u2 = p2 - s2
        m_u2.Set(p2X - s2X, p2Y - s2Y)
        Local length1 :Float = m_u1.Length()
        Local length2 :Float = m_u2.Length()
        If (length1 > b2Settings.b2_linearSlop)
            
            '//m_u1 *= 1.0f / length1
            m_u1.Multiply(1.0 / length1)
        Else
            
            
            m_u1.SetZero()
        End
        If (length2 > b2Settings.b2_linearSlop)
            
            '//m_u2 *= 1.0f / length2
            m_u2.Multiply(1.0 / length2)
        Else
            
            
            m_u2.SetZero()
        End
        Local C :Float = m_constant - length1 - m_ratio * length2
        If (C > 0.0)
            
            m_state = e_inactiveLimit
            m_impulse = 0.0
        Else
            
            
            m_state = e_atUpperLimit
        End
        If (length1 < m_maxLength1)
            
            m_limitState1 = e_inactiveLimit
            m_limitImpulse1 = 0.0
        Else
            
            
            m_limitState1 = e_atUpperLimit
        End
        If (length2 < m_maxLength2)
            
            m_limitState2 = e_inactiveLimit
            m_limitImpulse2 = 0.0
        Else
            
            
            m_limitState2 = e_atUpperLimit
        End
        '// Compute effective mass.
        '//var cr1u1:Float = b2Cross(r1, m_u1)
        Local cr1u1 :Float = r1X * m_u1.y - r1Y * m_u1.x
        '//var cr2u2:Float = b2Cross(r2, m_u2)
        Local cr2u2 :Float = r2X * m_u2.y - r2Y * m_u2.x
        m_limitMass1 = bA.m_invMass + bA.m_invI * cr1u1 * cr1u1
        m_limitMass2 = bB.m_invMass + bB.m_invI * cr2u2 * cr2u2
        m_pulleyMass = m_limitMass1 + m_ratio * m_ratio * m_limitMass2
        '//b2Settings.B2Assert(m_limitMass1 > Constants.EPSILON)
        '//b2Settings.B2Assert(m_limitMass2 > Constants.EPSILON)
        '//b2Settings.B2Assert(m_pulleyMass > Constants.EPSILON)
        m_limitMass1 = 1.0 / m_limitMass1
        m_limitMass2 = 1.0 / m_limitMass2
        m_pulleyMass = 1.0 / m_pulleyMass
        If (timeStep.warmStarting)
            
            '// Scale impulses to support variable time steps.
            m_impulse *= timeStep.dtRatio
            m_limitImpulse1 *= timeStep.dtRatio
            m_limitImpulse2 *= timeStep.dtRatio
            '// Warm starting.
            '//b2Vec2 P1 = (-m_impulse - m_limitImpulse1) * m_u1
            Local P1X :Float = (-m_impulse - m_limitImpulse1) * m_u1.x
            Local P1Y :Float = (-m_impulse - m_limitImpulse1) * m_u1.y
            '//b2Vec2 P2 = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2
            Local P2X :Float = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.x
            Local P2Y :Float = (-m_ratio * m_impulse - m_limitImpulse2) * m_u2.y
            '//bA.m_linearVelocity += bA.m_invMass * P1
            bA.m_linearVelocity.x += bA.m_invMass * P1X
            bA.m_linearVelocity.y += bA.m_invMass * P1Y
            '//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1)
            bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X)
            '//bB.m_linearVelocity += bB.m_invMass * P2
            bB.m_linearVelocity.x += bB.m_invMass * P2X
            bB.m_linearVelocity.y += bB.m_invMass * P2Y
            '//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2)
            bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X)
        Else
            
            
            m_impulse = 0.0
            m_limitImpulse1 = 0.0
            m_limitImpulse2 = 0.0
        End
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        '//B2_NOT_USED(timeStep)
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local r1X :Float = m_localAnchor1.x - bA.m_sweep.localCenter.x
        Local r1Y :Float = m_localAnchor1.y - bA.m_sweep.localCenter.y
        Local tX :Float =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
        r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
        r1X = tX
        '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local r2X :Float = m_localAnchor2.x - bB.m_sweep.localCenter.x
        Local r2Y :Float = m_localAnchor2.y - bB.m_sweep.localCenter.y
        tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
        r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
        r2X = tX
        '// temp vars
        Local v1X :Float
        Local v1Y :Float
        Local v2X :Float
        Local v2Y :Float
        Local P1X :Float
        Local P1Y :Float
        Local P2X :Float
        Local P2Y :Float
        Local Cdot :Float
        Local impulse :Float
        Local oldImpulse :Float
        If (m_state = e_atUpperLimit)
            
            '//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1)
            v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y)
            v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X)
            '//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2)
            v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y)
            v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X)
            '//Cdot = -b2Dot(m_u1, v1) - m_ratio * b2Dot(m_u2, v2)
            Cdot = -(m_u1.x * v1X + m_u1.y * v1Y) - m_ratio * (m_u2.x * v2X + m_u2.y * v2Y)
            impulse = m_pulleyMass * (-Cdot)
            oldImpulse = m_impulse
            m_impulse = b2Math.Max(0.0, m_impulse + impulse)
            impulse = m_impulse - oldImpulse
            '//b2Vec2 P1 = -impulse * m_u1
            P1X = -impulse * m_u1.x
            P1Y = -impulse * m_u1.y
            '//b2Vec2 P2 = - m_ratio * impulse * m_u2
            P2X = -m_ratio * impulse * m_u2.x
            P2Y = -m_ratio * impulse * m_u2.y
            '//bA.m_linearVelocity += bA.m_invMass * P1
            bA.m_linearVelocity.x += bA.m_invMass * P1X
            bA.m_linearVelocity.y += bA.m_invMass * P1Y
            '//bA.m_angularVelocity += bA.m_invI * b2Cross(r1, P1)
            bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X)
            '//bB.m_linearVelocity += bB.m_invMass * P2
            bB.m_linearVelocity.x += bB.m_invMass * P2X
            bB.m_linearVelocity.y += bB.m_invMass * P2Y
            '//bB.m_angularVelocity += bB.m_invI * b2Cross(r2, P2)
            bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X)
        End
        If (m_limitState1 = e_atUpperLimit)
            
            '//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1)
            v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y)
            v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X)
            '//float32 Cdot = -b2Dot(m_u1, v1)
            Cdot = -(m_u1.x * v1X + m_u1.y * v1Y)
            impulse = -m_limitMass1 * Cdot
            oldImpulse = m_limitImpulse1
            m_limitImpulse1 = b2Math.Max(0.0, m_limitImpulse1 + impulse)
            impulse = m_limitImpulse1 - oldImpulse
            '//b2Vec2 P1 = -impulse * m_u1
            P1X = -impulse * m_u1.x
            P1Y = -impulse * m_u1.y
            '//bA.m_linearVelocity += bA->m_invMass * P1
            bA.m_linearVelocity.x += bA.m_invMass * P1X
            bA.m_linearVelocity.y += bA.m_invMass * P1Y
            '//bA.m_angularVelocity += bA->m_invI * b2Cross(r1, P1)
            bA.m_angularVelocity += bA.m_invI * (r1X * P1Y - r1Y * P1X)
        End
        If (m_limitState2 = e_atUpperLimit)
            
            '//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2)
            v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y)
            v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X)
            '//float32 Cdot = -b2Dot(m_u2, v2)
            Cdot = -(m_u2.x * v2X + m_u2.y * v2Y)
            impulse = -m_limitMass2 * Cdot
            oldImpulse = m_limitImpulse2
            m_limitImpulse2 = b2Math.Max(0.0, m_limitImpulse2 + impulse)
            impulse = m_limitImpulse2 - oldImpulse
            '//b2Vec2 P2 = -impulse * m_u2
            P2X = -impulse * m_u2.x
            P2Y = -impulse * m_u2.y
            '//bB->m_linearVelocity += bB->m_invMass * P2
            bB.m_linearVelocity.x += bB.m_invMass * P2X
            bB.m_linearVelocity.y += bB.m_invMass * P2Y
            '//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P2)
            bB.m_angularVelocity += bB.m_invI * (r2X * P2Y - r2Y * P2X)
        End
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        '//B2_NOT_USED(baumgarte)
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        '//b2Vec2 s1 = m_ground->m_xf.position + m_groundAnchor1
        Local s1X :Float = m_ground.m_xf.position.x + m_groundAnchor1.x
        Local s1Y :Float = m_ground.m_xf.position.y + m_groundAnchor1.y
        '//b2Vec2 s2 = m_ground->m_xf.position + m_groundAnchor2
        Local s2X :Float = m_ground.m_xf.position.x + m_groundAnchor2.x
        Local s2Y :Float = m_ground.m_xf.position.y + m_groundAnchor2.y
        '// temp vars
        Local r1X :Float
        Local r1Y :Float
        Local r2X :Float
        Local r2Y :Float
        Local p1X :Float
        Local p1Y :Float
        Local p2X :Float
        Local p2Y :Float
        Local length1 :Float
        Local length2 :Float
        Local C :Float
        Local impulse :Float
        Local oldImpulse :Float
        Local oldLimitPositionImpulse :Float
        Local tX :Float
        Local linearError :Float = 0.0
        If (m_state = e_atUpperLimit)
            
            '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
            tMat = bA.m_xf.R
            r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x
            r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y
            tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
            r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
            r1X = tX
            '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
            tMat = bB.m_xf.R
            r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x
            r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y
            tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
            r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
            r2X = tX
            '//b2Vec2 p1 = bA->m_sweep.c + r1
            p1X = bA.m_sweep.c.x + r1X
            p1Y = bA.m_sweep.c.y + r1Y
            '//b2Vec2 p2 = bB->m_sweep.c + r2
            p2X = bB.m_sweep.c.x + r2X
            p2Y = bB.m_sweep.c.y + r2Y
            '// Get the pulley axes.
            '//m_u1 = p1 - s1
            m_u1.Set(p1X - s1X, p1Y - s1Y)
            '//m_u2 = p2 - s2
            m_u2.Set(p2X - s2X, p2Y - s2Y)
            length1 = m_u1.Length()
            length2 = m_u2.Length()
            If (length1 > b2Settings.b2_linearSlop)
                
                '//m_u1 *= 1.0f / length1
                m_u1.Multiply( 1.0 / length1 )
            Else
                
                
                m_u1.SetZero()
            End
            If (length2 > b2Settings.b2_linearSlop)
                
                '//m_u2 *= 1.0f / length2
                m_u2.Multiply( 1.0 / length2 )
            Else
                
                
                m_u2.SetZero()
            End
            C = m_constant - length1 - m_ratio * length2
            linearError = b2Math.Max(linearError, -C)
            C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0)
            impulse = -m_pulleyMass * C
            p1X = -impulse * m_u1.x
            p1Y = -impulse * m_u1.y
            p2X = -m_ratio * impulse * m_u2.x
            p2Y = -m_ratio * impulse * m_u2.y
            bA.m_sweep.c.x += bA.m_invMass * p1X
            bA.m_sweep.c.y += bA.m_invMass * p1Y
            bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X)
            bB.m_sweep.c.x += bB.m_invMass * p2X
            bB.m_sweep.c.y += bB.m_invMass * p2Y
            bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X)
            bA.SynchronizeTransform()
            bB.SynchronizeTransform()
        End
        If (m_limitState1 = e_atUpperLimit)
            
            '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
            tMat = bA.m_xf.R
            r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x
            r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y
            tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
            r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
            r1X = tX
            '//b2Vec2 p1 = bA->m_sweep.c + r1
            p1X = bA.m_sweep.c.x + r1X
            p1Y = bA.m_sweep.c.y + r1Y
            '//m_u1 = p1 - s1
            m_u1.Set(p1X - s1X, p1Y - s1Y)
            length1 = m_u1.Length()
            If (length1 > b2Settings.b2_linearSlop)
                
                '//m_u1 *= 1.0 / length1
                m_u1.x *= 1.0 / length1
                m_u1.y *= 1.0 / length1
            Else
                
                
                m_u1.SetZero()
            End
            C = m_maxLength1 - length1
            linearError = b2Math.Max(linearError, -C)
            C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0)
            impulse = -m_limitMass1 * C
            '//P1 = -impulse * m_u1
            p1X = -impulse * m_u1.x
            p1Y = -impulse * m_u1.y
            bA.m_sweep.c.x += bA.m_invMass * p1X
            bA.m_sweep.c.y += bA.m_invMass * p1Y
            '//bA.m_rotation += bA.m_invI * b2Cross(r1, P1)
            bA.m_sweep.a += bA.m_invI * (r1X * p1Y - r1Y * p1X)
            bA.SynchronizeTransform()
        End
        If (m_limitState2 = e_atUpperLimit)
            
            '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
            tMat = bB.m_xf.R
            r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x
            r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y
            tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
            r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
            r2X = tX
            '//b2Vec2 p2 = bB->m_position + r2
            p2X = bB.m_sweep.c.x + r2X
            p2Y = bB.m_sweep.c.y + r2Y
            '//m_u2 = p2 - s2
            m_u2.Set(p2X - s2X, p2Y - s2Y)
            length2 = m_u2.Length()
            If (length2 > b2Settings.b2_linearSlop)
                
                '//m_u2 *= 1.0 / length2
                m_u2.x *= 1.0 / length2
                m_u2.y *= 1.0 / length2
            Else
                
                
                m_u2.SetZero()
            End
            C = m_maxLength2 - length2
            linearError = b2Math.Max(linearError, -C)
            C = b2Math.Clamp(C + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0)
            impulse = -m_limitMass2 * C
            '//P2 = -impulse * m_u2
            p2X = -impulse * m_u2.x
            p2Y = -impulse * m_u2.y
            '//bB.m_sweep.c += bB.m_invMass * P2
            bB.m_sweep.c.x += bB.m_invMass * p2X
            bB.m_sweep.c.y += bB.m_invMass * p2Y
            '//bB.m_sweep.a += bB.m_invI * b2Cross(r2, P2)
            bB.m_sweep.a += bB.m_invI * (r2X * p2Y - r2Y * p2X)
            bB.SynchronizeTransform()
        End
        Return linearError < b2Settings.b2_linearSlop
    End
    Field m_ground:b2Body
    
    
    Field m_groundAnchor1:b2Vec2 = New b2Vec2()
    
    
    Field m_groundAnchor2:b2Vec2 = New b2Vec2()
    
    
    Field m_localAnchor1:b2Vec2 = New b2Vec2()
    
    
    Field m_localAnchor2:b2Vec2 = New b2Vec2()
    
    Field m_u1:b2Vec2 = New b2Vec2()
    
    
    Field m_u2:b2Vec2 = New b2Vec2()
    
    Field m_constant:Float
    
    
    Field m_ratio:Float
    
    Field m_maxLength1:Float
    
    
    Field m_maxLength2:Float
    
    '// Effective masses
    Field m_pulleyMass:Float
    
    
    Field m_limitMass1:Float
    
    
    Field m_limitMass2:Float
    
    '// Impulses for accumulation/warm starting.
    Field m_impulse:Float
    
    
    Field m_limitImpulse1:Float
    
    
    Field m_limitImpulse2:Float
    
    Field m_state:Int
    
    
    Field m_limitState1:Int
    
    
    Field m_limitState2:Int
    
    '// static
    'static b2internal
    const b2_minPulleyLength:Float = 2.0
End

