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
'* A weld joint essentially glues two bodies together. A weld joint may
'* distort somewhat because the island constraint approximate(solver).
'*/
#end
Class b2WeldJoint Extends b2Joint
    
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
        
        out.Set(inv_dt * m_impulse.x, inv_dt * m_impulse.y)
    End
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        Return inv_dt * m_impulse.z
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2WeldJointDef)
        
        Super.New(def)
        m_localAnchorA.SetV(def.localAnchorA)
        m_localAnchorB.SetV(def.localAnchorB)
        m_referenceAngle = def.referenceAngle
        m_impulse.SetZero()
        m_mass = New b2Mat33()
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
        m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB
        m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB
        m_mass.col3.x = -rAY * iA - rBY * iB
        m_mass.col1.y = m_mass.col2.x
        m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB
        m_mass.col3.y = rAX * iA + rBX * iB
        m_mass.col1.z = m_mass.col3.x
        m_mass.col2.z = m_mass.col3.y
        m_mass.col3.z = iA + iB
        If (timeStep.warmStarting)
            
            '// Scale impulses to support a variable time timeStep.
            m_impulse.x *= timeStep.dtRatio
            m_impulse.y *= timeStep.dtRatio
            m_impulse.z *= timeStep.dtRatio
            bA.m_linearVelocity.x -= mA * m_impulse.x
            bA.m_linearVelocity.y -= mA * m_impulse.y
            bA.m_angularVelocity -= iA * (rAX * m_impulse.y - rAY * m_impulse.x + m_impulse.z)
            bB.m_linearVelocity.x += mB * m_impulse.x
            bB.m_linearVelocity.y += mB * m_impulse.y
            bB.m_angularVelocity += iB * (rBX * m_impulse.y - rBY * m_impulse.x + m_impulse.z)
        Else
            
            m_impulse.SetZero()
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
        '// Solve point-to-point constraint
        Local Cdot1X :Float = vB.x - wB * rBY - vA.x + wA * rAY
        Local Cdot1Y :Float = vB.y + wB * rBX - vA.y - wA * rAX
        Local Cdot2 :Float = wB - wA
        Local impulse :b2Vec3 = New b2Vec3()
        m_mass.Solve33(impulse, -Cdot1X, -Cdot1Y, -Cdot2)
        m_impulse.Add(impulse)
        vA.x -= mA * impulse.x
        vA.y -= mA * impulse.y
        wA -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z)
        vB.x += mB * impulse.x
        vB.y += mB * impulse.y
        wB += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z)
        '// References has made some sets unnecessary
        '//bA->m_linearVelocity = vA
        bA.m_angularVelocity = wA
        '//bB->m_linearVelocity = vB
        bB.m_angularVelocity = wB
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        '//B2_NOT_USED(baumgarte)
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
        '//b2Vec2 C1 =  bB->m_sweep.c + rB - bA->m_sweep.c - rA
        Local C1X :Float =  bB.m_sweep.c.x + rBX - bA.m_sweep.c.x - rAX
        Local C1Y :Float =  bB.m_sweep.c.y + rBY - bA.m_sweep.c.y - rAY
        Local C2 :Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle
        '// Handle large detachment.
        Local k_allowedStretch :Float = 10.0 * b2Settings.b2_linearSlop
        Local positionError :Float = Sqrt(C1X * C1X + C1Y * C1Y)
        Local angularError :Float = b2Math.Abs(C2)
        If (positionError > k_allowedStretch)
            
            iA *= 1.0
            iB *= 1.0
        End
        m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB
        m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB
        m_mass.col3.x = -rAY * iA - rBY * iB
        m_mass.col1.y = m_mass.col2.x
        m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB
        m_mass.col3.y = rAX * iA + rBX * iB
        m_mass.col1.z = m_mass.col3.x
        m_mass.col2.z = m_mass.col3.y
        m_mass.col3.z = iA + iB
        Local impulse :b2Vec3 = New b2Vec3()
        m_mass.Solve33(impulse, -C1X, -C1Y, -C2)
        bA.m_sweep.c.x -= mA * impulse.x
        bA.m_sweep.c.y -= mA * impulse.y
        bA.m_sweep.a -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z)
        bB.m_sweep.c.x += mB * impulse.x
        bB.m_sweep.c.y += mB * impulse.y
        bB.m_sweep.a += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z)
        bA.SynchronizeTransform()
        bB.SynchronizeTransform()
        Return positionError <= b2Settings.b2_linearSlop And angularError <= b2Settings.b2_angularSlop
    End
    Field m_localAnchorA:b2Vec2 = New b2Vec2()
    
    Field m_localAnchorB:b2Vec2 = New b2Vec2()
    
    Field m_referenceAngle:Float
    Field m_impulse:b2Vec3 = New b2Vec3()
    
    Field m_mass:b2Mat33 = New b2Mat33()
    
End
