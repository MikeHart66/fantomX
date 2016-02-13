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
'// C = p2 - p1
'// Cdot = v2 - v1
'//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
'// J = [-I -r1_skew I r2_skew ]
'// Identity used:
'// w k Mod (rx i + ry j) = w * (-ry i + rx j)
'// Motor constraint
'// Cdot = w2 - w1
'// J = [0 0 -1 0 0 1]
'// K = invI1 + invI2
#rem
'/**
'* A revolute joint constrains to bodies to share a common point while they
'* are free to rotate about the point. The relative rotation about the shared
'* the(point) joint angle. You can limit the relative rotation with
'* a joint limit that specifies a lower and upper angle. You can use a motor
'* to drive the relative rotation about the shared point. A maximum motor torque
'* is provided so that infinite forces are not generated.
'* @see b2RevoluteJointDef
'*/
#end
Class b2RevoluteJoint Extends b2Joint
    
    '* @inheritDoc
    Method GetAnchorA:Void (out:b2Vec2)
        m_bodyA.GetWorldPoint(m_localAnchor1,out)
    End
    
    '* @inheritDoc
    Method GetAnchorB:Void (out:b2Vec2)
        m_bodyB.GetWorldPoint(m_localAnchor2,out)
    End
    
    '* @inheritDoc
    Method GetReactionForce:Void (inv_dt:Float, out:b2Vec2)
        out.Set(inv_dt * m_impulse.x, inv_dt * m_impulse.y)
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        
        Return inv_dt * m_impulse.z
    End
    #rem
    '/**
    '* Get the current joint angle in radians.
    '*/
    #end
    Method GetJointAngle : Float ()
        
        '//b2Body* bA = m_bodyA
        '//b2Body* bB = m_bodyB
        Return m_bodyB.m_sweep.a - m_bodyA.m_sweep.a - m_referenceAngle
    End
    #rem
    '/**
    '* Get the current joint angle speed in radians per second.
    '*/
    #end
    Method GetJointSpeed : Float ()
        
        '//b2Body* bA = m_bodyA
        '//b2Body* bB = m_bodyB
        Return m_bodyB.m_angularVelocity - m_bodyA.m_angularVelocity
    End
    #rem
    '/**
    '* Is the joint limit enabled?
    '*/
    #end
    Method IsLimitEnabled : Bool ()
        
        Return m_enableLimit
    End
    #rem
    '/**
    '* Enable/disable the joint limit.
    '*/
    #end
    Method EnableLimit : void (flag:Bool)
        
        m_enableLimit = flag
    End
    #rem
    '/**
    '* Get the lower joint limit in radians.
    '*/
    #end
    Method GetLowerLimit : Float ()
        
        Return m_lowerAngle
    End
    #rem
    '/**
    '* Get the upper joint limit in radians.
    '*/
    #end
    Method GetUpperLimit : Float ()
        
        Return m_upperAngle
    End
    #rem
    '/**
    '* Set the joint limits in radians.
    '*/
    #end
    Method SetLimits : void (lower:Float, upper:Float)
        
        '//b2Settings.B2Assert(lower <= upper)
        m_lowerAngle = lower
        m_upperAngle = upper
    End
    #rem
    '/**
    '* Is the joint motor enabled?
    '*/
    #end
    Method IsMotorEnabled : Bool ()
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        Return m_enableMotor
    End
    #rem
    '/**
    '* Enable/disable the joint motor.
    '*/
    #end
    Method EnableMotor : void (flag:Bool)
        
        m_enableMotor = flag
    End
    #rem
    '/**
    '* Set the motor speed in radians per second.
    '*/
    #end
    Method SetMotorSpeed : void (speed:Float)
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_motorSpeed = speed
    End
    #rem
    '/**
    '* Get the motor speed in radians per second.
    '*/
    #end
    Method GetMotorSpeed : Float ()
        
        Return m_motorSpeed
    End
    #rem
    '/**
    '* Set the maximum motor torque, usually in N-m.
    '*/
    #end
    Method SetMaxMotorTorque : void (torque:Float)
        
        m_maxMotorTorque = torque
    End
    #rem
    '/**
    '* Get the current motor torque, usually in N-m.
    '*/
    #end
    Method GetMotorTorque : Float ()
        
        Return m_maxMotorTorque
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2RevoluteJointDef)
        
        Super.New(def)
        '//m_localAnchor1 = def->localAnchorA
        m_localAnchor1.SetV(def.localAnchorA)
        '//m_localAnchor2 = def->localAnchorB
        m_localAnchor2.SetV(def.localAnchorB)
        m_referenceAngle = def.referenceAngle
        m_impulse.SetZero()
        m_motorImpulse = 0.0
        m_lowerAngle = def.lowerAngle
        m_upperAngle = def.upperAngle
        m_maxMotorTorque = def.maxMotorTorque
        m_motorSpeed = def.motorSpeed
        m_enableLimit = def.enableLimit
        m_enableMotor = def.enableMotor
        m_limitState = e_inactiveLimit
    End
    '// internal vars
    Field K:b2Mat22 = New b2Mat22()
    
    
    Field K1:b2Mat22 = New b2Mat22()
    
    
    Field K2:b2Mat22 = New b2Mat22()
    
    
    Field K3:b2Mat22 = New b2Mat22()
    
    
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        Local tX :Float
        If (m_enableMotor Or m_enableLimit)
            
            '// You cannot create prismatic joint between bodies that
            '// both have fixed rotation.
            '//b2Settings.B2Assert(bA.m_invI > 0.0 Or bB.m_invI > 0.0)
        End
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
        '// J = [-I -r1_skew I r2_skew]
        '// [ 0 -1 0 1]
        '// r_skew = [-ry; rx]
        '// Matlab
        '// K = [ m1+r1y^2*i1+m2+r2y^2*i2, -r1y*i1*r1x-r2y*i2*r2x, -r1y*i1-r2y*i2]
        '//     [ -r1y*i1*r1x-r2y*i2*r2x, m1+r1x^2*i1+m2+r2x^2*i2, r1x*i1+r2x*i2]
        '//     [ -r1y*i1-r2y*i2, r1x*i1+r2x*i2, i1+i2]
        Local m1 :Float = bA.m_invMass
        Local m2 :Float = bB.m_invMass
        Local i1 :Float = bA.m_invI
        Local i2 :Float = bB.m_invI
        m_mass.col1.x = m1 + m2 + r1Y * r1Y * i1 + r2Y * r2Y * i2
        m_mass.col2.x = -r1Y * r1X * i1 - r2Y * r2X * i2
        m_mass.col3.x = -r1Y * i1 - r2Y * i2
        m_mass.col1.y = m_mass.col2.x
        m_mass.col2.y = m1 + m2 + r1X * r1X * i1 + r2X * r2X * i2
        m_mass.col3.y = r1X * i1 + r2X * i2
        m_mass.col1.z = m_mass.col3.x
        m_mass.col2.z = m_mass.col3.y
        m_mass.col3.z = i1 + i2
        m_motorMass = 1.0 / (i1 + i2)
        If (m_enableMotor = False)
            
            m_motorImpulse = 0.0
        End
        If (m_enableLimit)
            
            '//float32 jointAngle = bB->m_sweep.a - bA->m_sweep.a - m_referenceAngle
            Local jointAngle :Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle
            If (b2Math.Abs(m_upperAngle - m_lowerAngle) < 2.0 * b2Settings.b2_angularSlop)
                
                m_limitState = e_equalLimits
            Else  If (jointAngle <= m_lowerAngle)
                
                
                If (m_limitState <> e_atLowerLimit)
                    
                    m_impulse.z = 0.0
                End
                
                m_limitState = e_atLowerLimit
            Else  If (jointAngle >= m_upperAngle)
                
                
                If (m_limitState <> e_atUpperLimit)
                    
                    m_impulse.z = 0.0
                End
                
                m_limitState = e_atUpperLimit
            Else
                
                
                m_limitState = e_inactiveLimit
                m_impulse.z = 0.0
            End
            
        Else
            
            
            m_limitState = e_inactiveLimit
        End
        '// Warm starting.
        If (timeStep.warmStarting)
            
            '//Scale impulses to support a variable time timeStep
            m_impulse.x *= timeStep.dtRatio
            m_impulse.y *= timeStep.dtRatio
            m_motorImpulse *= timeStep.dtRatio
            Local PX :Float = m_impulse.x
            Local PY :Float = m_impulse.y
            '//bA->m_linearVelocity -= m1 * P
            bA.m_linearVelocity.x -= m1 * PX
            bA.m_linearVelocity.y -= m1 * PY
            '//bA->m_angularVelocity -= i1 * (b2Cross(r1, P) + m_motorImpulse + m_impulse.z)
            bA.m_angularVelocity -= i1 * ((r1X * PY - r1Y * PX) + m_motorImpulse + m_impulse.z)
            '//bB->m_linearVelocity += m2 * P
            bB.m_linearVelocity.x += m2 * PX
            bB.m_linearVelocity.y += m2 * PY
            '//bB->m_angularVelocity += i2 * (b2Cross(r2, P) + m_motorImpulse + m_impulse.z)
            bB.m_angularVelocity += i2 * ((r2X * PY - r2Y * PX) + m_motorImpulse + m_impulse.z)
        Else
            
            
            m_impulse.SetZero()
            m_motorImpulse = 0.0
        End
    End
    Field impulse3:b2Vec3 = New b2Vec3()
    
    
    Field impulse2:b2Vec2 = New b2Vec2()
    
    
    Field reduced:b2Vec2 = New b2Vec2()
    
    
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        Local tX :Float
        Local newImpulse :Float
        Local r1X :Float
        Local r1Y :Float
        Local r2X :Float
        Local r2Y :Float
        Local v1 :b2Vec2 = bA.m_linearVelocity
        Local w1 :Float = bA.m_angularVelocity
        Local v2 :b2Vec2 = bB.m_linearVelocity
        Local w2 :Float = bB.m_angularVelocity
        Local m1 :Float = bA.m_invMass
        Local m2 :Float = bB.m_invMass
        Local i1 :Float = bA.m_invI
        Local i2 :Float = bB.m_invI
        '// Solve motor constraint.
        If (m_enableMotor And m_limitState <> e_equalLimits)
            
            Local Cdot :Float = w2 - w1 - m_motorSpeed
            Local impulse :Float = m_motorMass * ( -Cdot)
            Local oldImpulse :Float = m_motorImpulse
            Local maxImpulse :Float = timeStep.dt * m_maxMotorTorque
            m_motorImpulse = b2Math.Clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse)
            impulse = m_motorImpulse - oldImpulse
            w1 -= i1 * impulse
            w2 += i2 * impulse
        End
        '// Solve limit constraint.
        If (m_enableLimit And m_limitState <> e_inactiveLimit)
            
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
            '// Solve point-to-point constraint
            '//b2Vec2 Cdot1 = v2 + b2Cross(w2, r2) - v1 - b2Cross(w1, r1)
            Local Cdot1X :Float = v2.x + (w2 * -r2Y) - v1.x - (w1 * -r1Y)
            Local Cdot1Y :Float = v2.y + (w2 * r2X) - v1.y - (w1 * r1X)
            Local Cdot2 :Float  = w2 - w1
            m_mass.Solve33(impulse3, -Cdot1X, -Cdot1Y, -Cdot2)
            If (m_limitState = e_equalLimits)
                
                m_impulse.Add(impulse3)
            Else  If (m_limitState = e_atLowerLimit)
                
                
                newImpulse = m_impulse.z + impulse3.z
                If (newImpulse < 0.0)
                    
                    m_mass.Solve22(reduced, -Cdot1X, -Cdot1Y)
                    impulse3.x = reduced.x
                    impulse3.y = reduced.y
                    impulse3.z = -m_impulse.z
                    m_impulse.x += reduced.x
                    m_impulse.y += reduced.y
                    m_impulse.z = 0.0
                End
                
            Else  If (m_limitState = e_atUpperLimit)
                
                
                newImpulse = m_impulse.z + impulse3.z
                If (newImpulse > 0.0)
                    
                    m_mass.Solve22(reduced, -Cdot1X, -Cdot1Y)
                    impulse3.x = reduced.x
                    impulse3.y = reduced.y
                    impulse3.z = -m_impulse.z
                    m_impulse.x += reduced.x
                    m_impulse.y += reduced.y
                    m_impulse.z = 0.0
                End
            End
            v1.x -= m1 * impulse3.x
            v1.y -= m1 * impulse3.y
            w1 -= i1 * (r1X * impulse3.y - r1Y * impulse3.x + impulse3.z)
            v2.x += m2 * impulse3.x
            v2.y += m2 * impulse3.y
            w2 += i2 * (r2X * impulse3.y - r2Y * impulse3.x + impulse3.z)
        Else
            
            
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
            '//b2Vec2 Cdot = v2 + b2Cross(w2, r2) - v1 - b2Cross(w1, r1)
            Local CdotX :Float = v2.x + ( w2 * -r2Y) - v1.x - ( w1 * -r1Y)
            Local CdotY :Float = v2.y + (w2 * r2X) - v1.y - (w1 * r1X)
            m_mass.Solve22(impulse2, -CdotX, -CdotY)
            m_impulse.x += impulse2.x
            m_impulse.y += impulse2.y
            v1.x -= m1 * impulse2.x
            v1.y -= m1 * impulse2.y
            '//w1 -= i1 * b2Cross(r1, impulse2)
            w1 -= i1 * ( r1X * impulse2.y - r1Y * impulse2.x)
            v2.x += m2 * impulse2.x
            v2.y += m2 * impulse2.y
            '//w2 += i2 * b2Cross(r2, impulse2)
            w2 += i2 * ( r2X * impulse2.y - r2Y * impulse2.x)
        End
        bA.m_linearVelocity.SetV(v1)
        bA.m_angularVelocity = w1
        bB.m_linearVelocity.SetV(v2)
        bB.m_angularVelocity = w2
    End
    Global tImpulse:b2Vec2 = New b2Vec2()
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        '// TODO_ERIN block solve with limit
        Local oldLimitImpulse :Float
        Local C :Float
        Local tMat :b2Mat22
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local angularError :Float = 0.0
        Local positionError :Float = 0.0
        Local tX :Float
        Local impulseX :Float
        Local impulseY :Float
        '// Solve angular limit constraint.
        If (m_enableLimit And m_limitState <> e_inactiveLimit)
            
            Local angle :Float = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle
            Local limitImpulse :Float = 0.0
            If (m_limitState = e_equalLimits)
                
                '// Prevent large angular corrections
                C = b2Math.Clamp(angle - m_lowerAngle, -b2Settings.b2_maxAngularCorrection, b2Settings.b2_maxAngularCorrection)
                limitImpulse = -m_motorMass * C
                angularError = b2Math.Abs(C)
            Else  If (m_limitState = e_atLowerLimit)
                
                
                C = angle - m_lowerAngle
                angularError = -C
                '// Prevent large angular corrections and allow some slop.
                C = b2Math.Clamp(C + b2Settings.b2_angularSlop, -b2Settings.b2_maxAngularCorrection, 0.0)
                limitImpulse = -m_motorMass * C
            Else  If (m_limitState = e_atUpperLimit)
                
                
                C = angle - m_upperAngle
                angularError = C
                '// Prevent large angular corrections and allow some slop.
                C = b2Math.Clamp(C - b2Settings.b2_angularSlop, 0.0, b2Settings.b2_maxAngularCorrection)
                limitImpulse = -m_motorMass * C
            End
            bA.m_sweep.a -= bA.m_invI * limitImpulse
            bB.m_sweep.a += bB.m_invI * limitImpulse
            bA.SynchronizeTransform()
            bB.SynchronizeTransform()
        End
        '// Solve point-to-point constraint
        
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
        '//b2Vec2 C = bB->m_sweep.c + r2 - bA->m_sweep.c - r1
        Local CX :Float = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X
        Local CY :Float = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y
        Local CLengthSquared :Float = CX * CX + CY * CY
        Local CLength :Float = Sqrt(CLengthSquared)
        positionError = CLength
        Local invMass1 :Float = bA.m_invMass
        Local invMass2 :Float = bB.m_invMass
        Local invI1 :Float = bA.m_invI
        Local invI2 :Float = bB.m_invI
        '//Handle large detachment.
        const k_allowedStretch:Float = 10.0 * b2Settings.b2_linearSlop
        If (CLengthSquared > k_allowedStretch * k_allowedStretch)
            
            '// Use a particle solution (no rotation)
            '//b2Vec2 u = C; u.Normalize()
            Local uX :Float = CX / CLength
            Local uY :Float = CY / CLength
            Local k :Float = invMass1 + invMass2
            '//b2Settings.B2Assert(k>Constants.EPSILON)
            Local m :Float = 1.0 / k
            impulseX = m * ( -CX)
            impulseY = m * ( -CY)
            const k_beta:Float = 0.5
            bA.m_sweep.c.x -= k_beta * invMass1 * impulseX
            bA.m_sweep.c.y -= k_beta * invMass1 * impulseY
            bB.m_sweep.c.x += k_beta * invMass2 * impulseX
            bB.m_sweep.c.y += k_beta * invMass2 * impulseY
            '//C = bB->m_sweep.c + r2 - bA->m_sweep.c - r1
            CX = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X
            CY = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y
        End
        '//b2Mat22 K1
        K1.col1.x = invMass1 + invMass2
        K1.col2.x = 0.0
        K1.col1.y = 0.0
        K1.col2.y = invMass1 + invMass2
        '//b2Mat22 K2
        K2.col1.x =  invI1 * r1Y * r1Y
        K2.col2.x = -invI1 * r1X * r1Y
        K2.col1.y = -invI1 * r1X * r1Y
        K2.col2.y =  invI1 * r1X * r1X
        '//b2Mat22 K3
        K3.col1.x =  invI2 * r2Y * r2Y
        K3.col2.x = -invI2 * r2X * r2Y
        K3.col1.y = -invI2 * r2X * r2Y
        K3.col2.y =  invI2 * r2X * r2X
        '//b2Mat22 K = K1 + K2 + K3
        K.SetM(K1)
        K.AddM(K2)
        K.AddM(K3)
        '//b2Vec2 impulse = K.Solve(-C)
        K.Solve(tImpulse, -CX, -CY)
        impulseX = tImpulse.x
        impulseY = tImpulse.y
        '//bA.m_sweep.c -= bA.m_invMass * impulse
        bA.m_sweep.c.x -= bA.m_invMass * impulseX
        bA.m_sweep.c.y -= bA.m_invMass * impulseY
        '//bA.m_sweep.a -= bA.m_invI * b2Cross(r1, impulse)
        bA.m_sweep.a -= bA.m_invI * (r1X * impulseY - r1Y * impulseX)
        '//bB.m_sweep.c += bB.m_invMass * impulse
        bB.m_sweep.c.x += bB.m_invMass * impulseX
        bB.m_sweep.c.y += bB.m_invMass * impulseY
        '//bB.m_sweep.a += bB.m_invI * b2Cross(r2, impulse)
        bB.m_sweep.a += bB.m_invI * (r2X * impulseY - r2Y * impulseX)
        bA.SynchronizeTransform()
        bB.SynchronizeTransform()
        'End
        Return positionError <= b2Settings.b2_linearSlop And angularError <= b2Settings.b2_angularSlop
    End
    
    Field m_localAnchor1:b2Vec2 = New b2Vec2()
    '// relative
    
    
    Field m_localAnchor2:b2Vec2 = New b2Vec2()
    
    
    Field m_impulse:b2Vec3 = New b2Vec3()
    
    
    Field m_motorImpulse:Float
    
    Field m_mass:b2Mat33 = New b2Mat33()
    '// effective mass for point-to-point constraint.
    
    
    Field m_motorMass:Float
    
    '// effective mass for motor/limit angular constraint.
    
    
    Field m_enableMotor:Bool
    
    
    Field m_maxMotorTorque:Float
    
    
    Field m_motorSpeed:Float
    
    Field m_enableLimit:Bool
    
    
    Field m_referenceAngle:Float
    
    
    Field m_lowerAngle:Float
    
    
    Field m_upperAngle:Float
    
    
    Field m_limitState:Int
    
    
End


