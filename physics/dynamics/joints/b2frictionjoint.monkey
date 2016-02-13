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


'// Point-to-point constraint
'// Cdot = v2 - v1
'//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
'// J = [-I -r1_skew I r2_skew ]
'// Identity used:
'// w k Mod (rx i + ry j) = w * (-ry i + rx j)
'// Angle constraint
'// Cdot = w2 - w1
'// J = [0 0 -1 0 0 1]
'// K = invI1 + invI2
#rem
'/**
'* Friction joint. used(This) for top-down friction.
'* It provides 2D translational friction and angular friction.
'* @see b2FrictionJointDef
'*/
#end
Class b2FrictionJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void (out:b2Vec2)
        m_bodyA.GetWorldPoint(m_localAnchorA,out)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        m_bodyB.GetWorldPoint(m_localAnchorB,out)
    End
    
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float, out:b2Vec2)
        out.Set(inv_dt * m_linearImpulse.x, inv_dt * m_linearImpulse.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        '//B2_NOT_USED(inv_dt)
        Return inv_dt * m_angularImpulse
    End
    Method SetMaxForce : void (force:Float)
        
        m_maxForce = force
    End
    Method GetMaxForce : Float ()
        
        Return m_maxForce
    End
    Method SetMaxTorque : void (torque:Float)
        
        m_maxTorque = torque
    End
    Method GetMaxTorque : Float ()
        
        Return m_maxTorque
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2FrictionJointDef)
        
        Super.New(def)
        m_localAnchorA.SetV(def.localAnchorA)
        m_localAnchorB.SetV(def.localAnchorB)
        m_linearMass.SetZero()
        m_angularMass = 0.0
        m_linearImpulse.SetZero()
        m_angularImpulse = 0.0
        m_maxForce = def.maxForce
        m_maxTorque = def.maxTorque
    End
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local tMat :b2Mat22
        Local tX :Float
        Local bA :b2Body = m_bodyA
        Local bB :b2Body= m_bodyB
        '// Compute the effective mass matrix.
        '//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local rAX :Float = m_localAnchorA.x - bA.m_sweep.localCenter.x
        Local rAY :Float = m_localAnchorA.y - bA.m_sweep.localCenter.y
        tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY)
        rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY)
        rAX = tX
        '//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local rBX :Float = m_localAnchorB.x - bB.m_sweep.localCenter.x
        Local rBY :Float = m_localAnchorB.y - bB.m_sweep.localCenter.y
        tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY)
        rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY)
        rBX = tX
        '// J = [-I -r1_skew I r2_skew]
        '//     [ 0       -1 0       1]
        '// r_skew = [-ry; rx]
        '// Matlab
        '// K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
        '//     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
        '//     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]
        Local mA :Float = bA.m_invMass
        Local mB :Float = bB.m_invMass
        Local iA :Float = bA.m_invI
        Local iB :Float = bB.m_invI
        Local K :b2Mat22 = New b2Mat22()
        K.col1.x = mA + mB
        K.col2.x = 0.0
        K.col1.y = 0.0
        K.col2.y = mA + mB
        K.col1.x+=  iA * rAY * rAY
        K.col2.x+= -iA * rAX * rAY
        K.col1.y+= -iA * rAX * rAY
        K.col2.y+=  iA * rAX * rAX
        K.col1.x+=  iB * rBY * rBY
        K.col2.x+= -iB * rBX * rBY
        K.col1.y+= -iB * rBX * rBY
        K.col2.y+=  iB * rBX * rBX
        K.GetInverse(m_linearMass)
        m_angularMass = iA + iB
        If (m_angularMass > 0.0)
            
            m_angularMass = 1.0 / m_angularMass
        End
        If (timeStep.warmStarting)
            
            '// Scale impulses to support a variable time timeStep.
            m_linearImpulse.x *= timeStep.dtRatio
            m_linearImpulse.y *= timeStep.dtRatio
            m_angularImpulse *= timeStep.dtRatio
            Local P :b2Vec2 = m_linearImpulse
            bA.m_linearVelocity.x -= mA * P.x
            bA.m_linearVelocity.y -= mA * P.y
            bA.m_angularVelocity -= iA * (rAX * P.y - rAY * P.x + m_angularImpulse)
            bB.m_linearVelocity.x += mB * P.x
            bB.m_linearVelocity.y += mB * P.y
            bB.m_angularVelocity += iB * (rBX * P.y - rBY * P.x + m_angularImpulse)
        Else
            
            
            m_linearImpulse.SetZero()
            m_angularImpulse = 0.0
        End
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        '//B2_NOT_USED(timeStep)
        Local tMat :b2Mat22
        Local tX :Float
        Local bA :b2Body = m_bodyA
        Local bB :b2Body= m_bodyB
        Local vA :b2Vec2 = bA.m_linearVelocity
        Local wA :Float = bA.m_angularVelocity
        Local vB :b2Vec2 = bB.m_linearVelocity
        Local wB :Float = bB.m_angularVelocity
        Local mA :Float = bA.m_invMass
        Local mB :Float = bB.m_invMass
        Local iA :Float = bA.m_invI
        Local iB :Float = bB.m_invI
        '//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local rAX :Float = m_localAnchorA.x - bA.m_sweep.localCenter.x
        Local rAY :Float = m_localAnchorA.y - bA.m_sweep.localCenter.y
        tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY)
        rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY)
        rAX = tX
        '//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local rBX :Float = m_localAnchorB.x - bB.m_sweep.localCenter.x
        Local rBY :Float = m_localAnchorB.y - bB.m_sweep.localCenter.y
        tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY)
        rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY)
        rBX = tX
        Local maxImpulse :Float
        '// Solve angular friction
        
        Local Cdot :Float = wB - wA
        Local impulse :Float = -m_angularMass * Cdot
        Local oldImpulse :Float = m_angularImpulse
        maxImpulse = timeStep.dt * m_maxTorque
        m_angularImpulse = b2Math.Clamp(m_angularImpulse + impulse, -maxImpulse, maxImpulse)
        impulse = m_angularImpulse - oldImpulse
        wA -= iA * impulse
        wB += iB * impulse
        'End
        '// Solve linear friction
        
        '//b2Vec2 Cdot = vB + b2Cross(wB, rB) - vA - b2Cross(wA, rA)
        Local CdotX :Float = vB.x - wB * rBY - vA.x + wA * rAY
        Local CdotY :Float = vB.y + wB * rBX - vA.y - wA * rAX
        Local impulseV:b2Vec2 = New b2Vec2(-CdotX, -CdotY)
        b2Math.MulMV(m_linearMass, impulseV, impulseV)
        Local oldImpulseV :b2Vec2 = m_linearImpulse.Copy()
        m_linearImpulse.Add(impulseV)
        maxImpulse = timeStep.dt * m_maxForce
        If (m_linearImpulse.LengthSquared() > maxImpulse * maxImpulse)
            m_linearImpulse.Normalize()
            m_linearImpulse.Multiply(maxImpulse)
        End
        b2Math.SubtractVV(m_linearImpulse, oldImpulseV, impulseV)
        vA.x -= mA * impulseV.x
        vA.y -= mA * impulseV.y
        wA -= iA * (rAX * impulseV.y - rAY * impulseV.x)
        vB.x += mB * impulseV.x
        vB.y += mB * impulseV.y
        wB += iB * (rBX * impulseV.y - rBY * impulseV.x)
        'End
        '// References has made some sets unnecessary
        '//bA->m_linearVelocity = vA
        bA.m_angularVelocity = wA
        '//bB->m_linearVelocity = vB
        bB.m_angularVelocity = wB
    End
    
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        '//B2_NOT_USED(baumgarte)
        Return True
    End
    
    Field m_localAnchorA:b2Vec2 = New b2Vec2()
    Field m_localAnchorB:b2Vec2 = New b2Vec2()
    Field m_linearMass:b2Mat22 = New b2Mat22()
    Field m_angularMass:Float
    Field m_linearImpulse:b2Vec2 = New b2Vec2()
    Field m_angularImpulse:Float
    Field m_maxForce:Float
    Field m_maxTorque:Float
    
End

