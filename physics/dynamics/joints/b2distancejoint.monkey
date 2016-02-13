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


'// 1-D constrained system
'// m (v2 - v1) = lambda
'// v2 + (beta/h) * x1 + gamma * lambda = 0, gamma has units of inverse mass.
'// x2 = x1 + h * v2
'// 1-D mass-damper-spring system
'// m (v2 - v1) + h * d * v2 + h * k *
'// C = norm(p2 - p1) - L
'// u = (p2 - p1) / norm(p2 - p1)
'// Cdot = dot(u, v2 + cross(w2, r2) - v1 - cross(w1, r1))
'// J = [-u -cross(r1, u) u cross(r2, u)]
'// K = J * invM * JT
'//   = invMass1 + invI1 * cross(r1, u)^2 + invMass2 + invI2 * cross(r2, u)^2
#rem
'/**
'* A distance joint constrains two points on two bodies
'* to remain at a fixed distance from each other. You can view
'* a(this) massless, rigid rod.
'* @see b2DistanceJointDef
'*/
#end
Class b2DistanceJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void (out:b2Vec2)
        m_bodyA.GetWorldPoint(m_localAnchor1,out)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        m_bodyB.GetWorldPoint(m_localAnchor2,out)
    End
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float,out:b2Vec2)
        '//b2Vec2 F = (m_inv_dt * m_impulse) * m_u
        '//return F
        out.Set(inv_dt * m_impulse * m_u.x, inv_dt * m_impulse * m_u.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        '//B2_NOT_USED(inv_dt)
        Return 0.0
    End
    '/// Set the natural length
    Method GetLength : Float ()
        
        Return m_length
    End
    '/// Get the natural length
    Method SetLength : void (length:Float)
        
        m_length = length
    End
    '/// Get the frequency in Hz
    Method GetFrequency : Float ()
        
        Return m_frequencyHz
    End
    '/// Set the frequency in Hz
    Method SetFrequency : void (hz:Float)
        
        m_frequencyHz = hz
    End
    '/// Get damping ratio
    Method GetDampingRatio : Float ()
        
        Return m_dampingRatio
    End
    '/// Set damping ratio
    Method SetDampingRatio : void (ratio:Float)
        
        m_dampingRatio = ratio
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2DistanceJointDef)
        
        Super.New(def)
        Local tMat :b2Mat22
        Local tX :Float
        Local tY :Float
        m_localAnchor1.SetV(def.localAnchorA)
        m_localAnchor2.SetV(def.localAnchorB)
        m_length = def.Length
        m_frequencyHz = def.frequencyHz
        m_dampingRatio = def.dampingRatio
        m_impulse = 0.0
        m_gamma = 0.0
        m_bias = 0.0
    End
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        Local tMat :b2Mat22
        Local tX :Float
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        '// Compute the effective mass matrix.
        '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local r1X :Float = m_localAnchor1.x - bA.m_sweep.localCenter.x
        Local r1Y :Float = m_localAnchor1.y - bA.m_sweep.localCenter.y
        tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
        r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
        r1X = tX
        '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local r2X :Float = m_localAnchor2.x - bB.m_sweep.localCenter.x
        Local r2Y :Float = m_localAnchor2.y - bB.m_sweep.localCenter.y
        tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
        r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
        r2X = tX
        '//m_u = bB->m_sweep.c + r2 - bA->m_sweep.c - r1
        m_u.x = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X
        m_u.y = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y
        '// Handle singularity.
        '//float32 length = m_u.Length()
        Local length :Float = Sqrt(m_u.x*m_u.x + m_u.y*m_u.y)
        If (length > b2Settings.b2_linearSlop)
            
            '//m_u *= 1.0 / length
            m_u.Multiply( 1.0 / length )
        Else
            
            m_u.SetZero()
        End
        '//float32 cr1u = b2Cross(r1, m_u)
        Local cr1u :Float = (r1X * m_u.y - r1Y * m_u.x)
        '//float32 cr2u = b2Cross(r2, m_u)
        Local cr2u :Float = (r2X * m_u.y - r2Y * m_u.x)
        '//m_mass = bA->m_invMass + bA->m_invI * cr1u * cr1u + bB->m_invMass + bB->m_invI * cr2u * cr2u
        Local invMass :Float = bA.m_invMass + bA.m_invI * cr1u * cr1u + bB.m_invMass + bB.m_invI * cr2u * cr2u
        If( invMass <> 0.0  )
            m_mass = 1.0 / invMass
        Else
            
            m_mass = 0.0
        End
        If (m_frequencyHz > 0.0)
            
            Local C :Float = length - m_length
            '// Frequency
            Local omega :Float = 2.0 * Constants.PI * m_frequencyHz
            '// Damping coefficient
            Local d :Float = 2.0 * m_mass * m_dampingRatio * omega
            '// Spring stiffness
            Local k :Float = m_mass * omega * omega
            '// magic formulas
            m_gamma = timeStep.dt * (d + timeStep.dt * k)
            If( m_gamma <> 0.0 )
                m_gamma =1 / m_gamma
            Else
                
                m_gamma =0.0
            End
            
            m_bias = C * timeStep.dt * k * m_gamma
            m_mass = invMass + m_gamma
            If( m_mass <> 0.0  )
                m_mass = 1.0 / m_mass
            Else
                
                m_mass = 0.0
            End
        End
        If (timeStep.warmStarting)
            
            '// Scale the impulse to support a variable time timeStep
            m_impulse *= timeStep.dtRatio
            '//b2Vec2 P = m_impulse * m_u
            Local PX :Float = m_impulse * m_u.x
            Local PY :Float = m_impulse * m_u.y
            '//bA->m_linearVelocity -= bA->m_invMass * P
            bA.m_linearVelocity.x -= bA.m_invMass * PX
            bA.m_linearVelocity.y -= bA.m_invMass * PY
            '//bA->m_angularVelocity -= bA->m_invI * b2Cross(r1, P)
            bA.m_angularVelocity -= bA.m_invI * (r1X * PY - r1Y * PX)
            '//bB->m_linearVelocity += bB->m_invMass * P
            bB.m_linearVelocity.x += bB.m_invMass * PX
            bB.m_linearVelocity.y += bB.m_invMass * PY
            '//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P)
            bB.m_angularVelocity += bB.m_invI * (r2X * PY - r2Y * PX)
        Else
            
            m_impulse = 0.0
        End
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        Local tMat :b2Mat22
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
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
        '// Cdot = dot(u, v + cross(w, r))
        '//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1)
        Local v1X :Float = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y)
        Local v1Y :Float = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X)
        '//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2)
        Local v2X :Float = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y)
        Local v2Y :Float = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X)
        '//float32 Cdot = b2Dot(m_u, v2 - v1)
        Local Cdot :Float = (m_u.x * (v2X - v1X) + m_u.y * (v2Y - v1Y))
        Local impulse :Float = -m_mass * (Cdot + m_bias + m_gamma * m_impulse)
        m_impulse += impulse
        '//b2Vec2 P = impulse * m_u
        Local PX :Float = impulse * m_u.x
        Local PY :Float = impulse * m_u.y
        '//bA->m_linearVelocity -= bA->m_invMass * P
        bA.m_linearVelocity.x -= bA.m_invMass * PX
        bA.m_linearVelocity.y -= bA.m_invMass * PY
        '//bA->m_angularVelocity -= bA->m_invI * b2Cross(r1, P)
        bA.m_angularVelocity -= bA.m_invI * (r1X * PY - r1Y * PX)
        '//bB->m_linearVelocity += bB->m_invMass * P
        bB.m_linearVelocity.x += bB.m_invMass * PX
        bB.m_linearVelocity.y += bB.m_invMass * PY
        '//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P)
        bB.m_angularVelocity += bB.m_invI * (r2X * PY - r2Y * PX)
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        '//B2_NOT_USED(baumgarte)
        Local tMat :b2Mat22
        If (m_frequencyHz > 0.0)
            
            '// no(There) position correction for soft distance constraints
            Return True
        End
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
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
        '//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1
        Local dX :Float = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X
        Local dY :Float = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y
        '//float32 length = d.Normalize()
        Local length :Float = Sqrt(dX*dX + dY*dY)
        dX /= length
        dY /= length
        '//float32 C = length - m_length
        Local C :Float = length - m_length
        C = b2Math.Clamp(C, -b2Settings.b2_maxLinearCorrection, b2Settings.b2_maxLinearCorrection)
        Local impulse :Float = -m_mass * C
        '//m_u = d
        m_u.Set(dX, dY)
        '//b2Vec2 P = impulse * m_u
        Local PX :Float = impulse * m_u.x
        Local PY :Float = impulse * m_u.y
        '//bA->m_sweep.c -= bA->m_invMass * P
        bA.m_sweep.c.x -= bA.m_invMass * PX
        bA.m_sweep.c.y -= bA.m_invMass * PY
        '//bA->m_sweep.a -= bA->m_invI * b2Cross(r1, P)
        bA.m_sweep.a -= bA.m_invI * (r1X * PY - r1Y * PX)
        '//bB->m_sweep.c += bB->m_invMass * P
        bB.m_sweep.c.x += bB.m_invMass * PX
        bB.m_sweep.c.y += bB.m_invMass * PY
        '//bB->m_sweep.a -= bB->m_invI * b2Cross(r2, P)
        bB.m_sweep.a += bB.m_invI * (r2X * PY - r2Y * PX)
        bA.SynchronizeTransform()
        bB.SynchronizeTransform()
        Return b2Math.Abs(C) < b2Settings.b2_linearSlop
    End
    Field m_localAnchor1:b2Vec2 = New b2Vec2()
    
    Field m_localAnchor2:b2Vec2 = New b2Vec2()
    
    Field m_u:b2Vec2 = New b2Vec2()
    
    Field m_frequencyHz:Float
    
    Field m_dampingRatio:Float
    
    Field m_gamma:Float
    
    Field m_bias:Float
    
    Field m_impulse:Float
    
    Field m_mass:Float
    
    '// effective mass for the constraint.
    
    Field m_length:Float
    
End
