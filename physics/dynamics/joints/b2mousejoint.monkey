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


'// p = attached point, m = mouse point
'// C = p - m
'// Cdot = v
'//      = v + cross(w, r)
'// J = [I r_skew]
'// Identity used:
'// w k Mod (rx i + ry j) = w * (-ry i + rx j)
#rem
'/**
'* A mouse used(joint) to make a point on a body track a
'* specified world point. This a soft constraint with a maximum
'* force. This allows the constraint to stretch and without
'* applying huge forces.
'* Note: this not(joint) fully it(documented) is intended primarily
'* for the testbed. See that for more instructions.
'* @see b2MouseJointDef
'*/
#end
Class b2MouseJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void (out:b2Vec2)
        out.SetV(m_target)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        m_bodyB.GetWorldPoint(m_localAnchor,out)
    End
    
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float,out:b2Vec2)
        out.Set(inv_dt * m_impulse.x, inv_dt * m_impulse.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        Return 0.0
    End
    Method GetTarget : b2Vec2 ()
        
        Return m_target
    End
    #rem
    '/**
    '* Use this to update the target point.
    '*/
    #end
    Method SetTarget : void (target:b2Vec2)
        
        If (m_bodyB.IsAwake() = False)
            
            m_bodyB.SetAwake(True)
        End
        
        m_target = target
    End
    '/// Get the maximum force in Newtons.
    Method GetMaxForce : Float ()
        
        Return m_maxForce
    End
    '/// Set the maximum force in Newtons.
    Method SetMaxForce : void (maxForce:Float)
        
        m_maxForce = maxForce
    End
    '/// Get frequency in Hz
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
    Method New(def:b2MouseJointDef)
        
        Super.New(def)
        '//b2Settings.B2Assert(def.target.IsValid())
        '//b2Settings.B2Assert(b2Math.b2IsValid(def.maxForce) And def.maxForce > 0.0)
        '//b2Settings.B2Assert(b2Math.b2IsValid(def.frequencyHz) And def.frequencyHz > 0.0)
        '//b2Settings.B2Assert(b2Math.b2IsValid(def.dampingRatio) And def.dampingRatio > 0.0)
        m_target.SetV(def.target)
        '//m_localAnchor = b2MulT(m_bodyB.m_xf, m_target)
        Local tX :Float = m_target.x - m_bodyB.m_xf.position.x
        Local tY :Float = m_target.y - m_bodyB.m_xf.position.y
        Local tMat :b2Mat22 = m_bodyB.m_xf.R
        m_localAnchor.x = (tX * tMat.col1.x + tY * tMat.col1.y)
        m_localAnchor.y = (tX * tMat.col2.x + tY * tMat.col2.y)
        m_maxForce = def.maxForce
        m_impulse.SetZero()
        m_frequencyHz = def.frequencyHz
        m_dampingRatio = def.dampingRatio
        m_beta = 0.0
        m_gamma = 0.0
    End
    '// Presolve vars
    Field K:b2Mat22 = New b2Mat22()
    
    Field K1:b2Mat22 = New b2Mat22()
    
    Field K2:b2Mat22 = New b2Mat22()
    
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local b :b2Body = m_bodyB
        Local mass :Float = b.GetMass()
        '// Frequency
        Local omega :Float = 2.0 * Constants.PI * m_frequencyHz
        '// Damping co-efficient
        Local d :Float = 2.0 * mass * m_dampingRatio * omega
        '// Spring stiffness
        Local k :Float = mass * omega * omega
        '// magic formulas
        '// gamma has units of inverse mass
        '// beta hs units of inverse time
        '//b2Settings.B2Assert(d + timeStep.dt * k > Constants.EPSILON)
        m_gamma = timeStep.dt * (d + timeStep.dt * k)
        If( m_gamma <> 0  )
            m_gamma = 1 / m_gamma
        Else
            
            m_gamma =0.0
        End
        
        m_beta = timeStep.dt * k * m_gamma
        Local tMat :b2Mat22
        '// Compute the effective mass matrix.
        '//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter())
        tMat = b.m_xf.R
        Local rX :Float = m_localAnchor.x - b.m_sweep.localCenter.x
        Local rY :Float = m_localAnchor.y - b.m_sweep.localCenter.y
        Local tX :Float = (tMat.col1.x * rX + tMat.col2.x * rY)
        rY = (tMat.col1.y * rX + tMat.col2.y * rY)
        rX = tX
        '// K    = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
        '//      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y -r1.x*r1.y]
        '//        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
        Local invMass :Float = b.m_invMass
        Local invI :Float = b.m_invI
        '//b2Mat22 K1
        K1.col1.x = invMass
        K1.col2.x = 0.0
        K1.col1.y = 0.0
        K1.col2.y = invMass
        '//b2Mat22 K2
        K2.col1.x =  invI * rY * rY
        K2.col2.x = -invI * rX * rY
        K2.col1.y = -invI * rX * rY
        K2.col2.y =  invI * rX * rX
        '//b2Mat22 K = K1 + K2
        K.SetM(K1)
        K.AddM(K2)
        K.col1.x += m_gamma
        K.col2.y += m_gamma
        '//m_ptpMass = K.GetInverse()
        K.GetInverse(m_mass)
        '//m_C = b.m_position + r - m_target
        m_C.x = b.m_sweep.c.x + rX - m_target.x
        m_C.y = b.m_sweep.c.y + rY - m_target.y
        '// Cheat with some damping
        b.m_angularVelocity *= 0.98
        '// Warm starting.
        m_impulse.x *= timeStep.dtRatio
        m_impulse.y *= timeStep.dtRatio
        '//b.m_linearVelocity += invMass * m_impulse
        b.m_linearVelocity.x += invMass * m_impulse.x
        b.m_linearVelocity.y += invMass * m_impulse.y
        '//b.m_angularVelocity += invI * b2Cross(r, m_impulse)
        b.m_angularVelocity += invI * (rX * m_impulse.y - rY * m_impulse.x)
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local b :b2Body = m_bodyB
        Local tMat :b2Mat22
        Local tX :Float
        Local tY :Float
        '// Compute the effective mass matrix.
        '//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter())
        tMat = b.m_xf.R
        Local rX :Float = m_localAnchor.x - b.m_sweep.localCenter.x
        Local rY :Float = m_localAnchor.y - b.m_sweep.localCenter.y
        tX = (tMat.col1.x * rX + tMat.col2.x * rY)
        rY = (tMat.col1.y * rX + tMat.col2.y * rY)
        rX = tX
        '// Cdot = v + cross(w, r)
        '//b2Vec2 Cdot = b->m_linearVelocity + b2Cross(b->m_angularVelocity, r)
        Local CdotX :Float = b.m_linearVelocity.x + (-b.m_angularVelocity * rY)
        Local CdotY :Float = b.m_linearVelocity.y + (b.m_angularVelocity * rX)
        '//b2Vec2 impulse = - b2Mul(m_mass, Cdot + m_beta * m_C + m_gamma * m_impulse)
        tMat = m_mass
        tX = CdotX + m_beta * m_C.x + m_gamma * m_impulse.x
        tY = CdotY + m_beta * m_C.y + m_gamma * m_impulse.y
        Local impulseX :Float = -(tMat.col1.x * tX + tMat.col2.x * tY)
        Local impulseY :Float = -(tMat.col1.y * tX + tMat.col2.y * tY)
        Local oldImpulseX :Float = m_impulse.x
        Local oldImpulseY :Float = m_impulse.y
        '//m_impulse += impulse
        m_impulse.x += impulseX
        m_impulse.y += impulseY
        Local maxImpulse :Float = timeStep.dt * m_maxForce
        If (m_impulse.LengthSquared() > maxImpulse*maxImpulse)
            
            '//m_impulse *= m_maxImpulse / m_impulse.Length()
            m_impulse.Multiply(maxImpulse / m_impulse.Length())
        End
        
        '//impulse = m_impulse - oldImpulse
        impulseX = m_impulse.x - oldImpulseX
        impulseY = m_impulse.y - oldImpulseY
        '//b->m_linearVelocity += b->m_invMass * impulse
        b.m_linearVelocity.x += b.m_invMass * impulseX
        b.m_linearVelocity.y += b.m_invMass * impulseY
        '//b->m_angularVelocity += b->m_invI * b2Cross(r, P)
        b.m_angularVelocity += b.m_invI * (rX * impulseY - rY * impulseX)
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        '//B2_NOT_USED(baumgarte)
        Return True
    End
    Field m_localAnchor:b2Vec2 = New b2Vec2()
    
    Field m_target:b2Vec2 = New b2Vec2()
    
    Field m_impulse:b2Vec2 = New b2Vec2()
    Field m_mass:b2Mat22 = New b2Mat22()
    '// effective mass for point-to-point constraint.
    
    Field m_C:b2Vec2 = New b2Vec2()
    
    '// position error
    
    Field m_maxForce:Float
    
    Field m_frequencyHz:Float
    
    Field m_dampingRatio:Float
    
    Field m_beta:Float
    
    '// bias factor
    
    Field m_gamma:Float
    
    '// softness
    
End
