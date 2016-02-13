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


'// Linear constraint (point-to-line)
'// d = p2 - p1 = x2 + r2 - x1 - r1
'// C = dot(perp, d)
'// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
'//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
'// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
'//
'// Angular constraint
'// C = a2 - a1 + a_initial
'// Cdot = w2 - w1
'// J = [0 0 -1 0 0 1]
'//
'// K = J * invM * JT
'//
'// J = [-a -s1 a s2]
'//     [0  -1  0  1]
'// a = perp
'// s1 = cross(d + r1, a) = cross(p2 - x1, a)
'// s2 = cross(r2, a) = cross(p2 - x2, a)
'// Motor/Limit linear constraint
'// C = dot(ax1, d)
'// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
'// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]
'// Block Solver
'// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic) even
'// when the mass has poor distribution (leading to large torques about the joint anchor points).
'//
'// The Jacobian has 3 rows:
'// J = [-uT -s1 uT s2] // linear
'//     [0   -1   0  1] // angular
'//     [-vT -a1 vT a2] // limit
'//
'// u = perp
'// v = axis
'// s1 = cross(d + r1, u), s2 = cross(r2, u)
'// a1 = cross(d + r1, v), a2 = cross(r2, v)
'// M * (v2 - v1) = JT * df
'// J * v2 = bias
'//
'// v2 = v1 + invM * JT * df
'// J * (v1 + invM * JT * df) = bias
'// K * df = bias - J * v1 = -Cdot
'// K = J * invM * JT
'// Cdot = J * v1 - bias
'//
'// Now solve for f2.0
'// df = f2 - f1
'// K * (f2 - f1) = -Cdot
'// f2 = invK * (-Cdot) + f1
'//
'// Clamp accumulated limit impulse.
'// lower: f2(3) = max(f2(3), 0)
'// upper: f2(3) = min(f2(3), 0)
'//
'// Solve for correct f2(1:2)
'// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:3) * f1
'//                       = -Cdot(1:2) - K(1:2,3) * f2(3) + K(1:2,1:2) * f1(1:2) + K(1:2,3) * f1(3)
'// K(1:2, 1:2) * f2(1:2) = -Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3)) + K(1:2,1:2) * f1(1:2)
'// f2(1:2) = invK(1:2,1:2) * (-Cdot(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
'//
'// Now compute impulse to be applied:
'// df = f2 - f1
#rem
'/**
'* A prismatic joint. This joint provides one degree of freedom: translation
'* along an axis fixed in body1.0 Relative prevented(rotation). You can
'* use a joint limit to restrict the range of motion and a joint motor to
'* drive the motion or to model joint friction.
'* @see b2PrismaticJointDef
'*/
#end
Class b2PrismaticJoint Extends b2Joint
    
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
        '//return inv_dt * (m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis)
        out.Set(	inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x),
        inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y))
    End
    
    '* @inheritDoc
    Method GetReactionTorque : Float (inv_dt:Float)
        Return inv_dt * m_impulse.y
    End
    
    #rem
    '/**
    '* Get the current joint translation, usually in meters.
    '*/
    #end
    Field tmpVec1:b2Vec2 = New b2Vec2()
    Field tmpVec2:b2Vec2 = New b2Vec2()
    Method GetJointTranslation : Float ()
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        bA.GetWorldPoint(m_localAnchor1,tmpVec1)
        bB.GetWorldPoint(m_localAnchor2,tmpVec2)
        
        tmpVec2.Subtract(tmpVec1)
        
        bA.GetWorldVector(m_localXAxis1,tmpVec1)
        
        Local translation:Float = tmpVec1.x*tmpVec2.x + tmpVec1.y*tmpVec2.y
        Return translation
    End
    #rem
    '/**
    '* Get the current joint translation speed, usually in meters per second.
    '*/
    #end
    Method GetJointSpeed : Float ()
        
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
        '//var d:b2Vec2 = b2Math.SubtractVV(p2, p1)
        Local dX :Float = p2X - p1X
        Local dY :Float = p2Y - p1Y
        '//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1)
        Local axis :b2Vec2 = New b2Vec2()
        bA.GetWorldVector(m_localXAxis1,axis)
        Local v1 :b2Vec2 = bA.m_linearVelocity
        Local v2 :b2Vec2 = bB.m_linearVelocity
        Local w1 :Float = bA.m_angularVelocity
        Local w2 :Float = bB.m_angularVelocity
        '//var speed:Float = b2Math.b2Dot(d, b2Math.b2CrossFV(w1, ax1)) + b2Math.b2Dot(ax1, b2Math.SubtractVV( b2Math.SubtractVV( b2Math.AddVV( v2 , b2Math.b2CrossFV(w2, r2)) , v1) , b2Math.b2CrossFV(w1, r1)))
        '//var b2D:Float = (dX*(-w1 * ax1Y) + dY*(w1 * ax1X))
        '//var b2D2:Float = (ax1X * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + ax1Y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)))
        Local speed :Float = (dX*(-w1 * axis.y) + dY*(w1 * axis.x)) + (axis.x * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + axis.y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)))
        Return speed
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
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_enableLimit = flag
    End
    #rem
    '/**
    '* Get the lower joint limit, usually in meters.
    '*/
    #end
    Method GetLowerLimit : Float ()
        
        Return m_lowerTranslation
    End
    #rem
    '/**
    '* Get the upper joint limit, usually in meters.
    '*/
    #end
    Method GetUpperLimit : Float ()
        
        Return m_upperTranslation
    End
    #rem
    '/**
    '* Set the joint limits, usually in meters.
    '*/
    #end
    Method SetLimits : void (lower:Float, upper:Float)
        
        '//b2Settings.B2Assert(lower <= upper)
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_lowerTranslation = lower
        m_upperTranslation = upper
    End
    #rem
    '/**
    '* Is the joint motor enabled?
    '*/
    #end
    Method IsMotorEnabled : Bool ()
        
        Return m_enableMotor
    End
    #rem
    '/**
    '* Enable/disable the joint motor.
    '*/
    #end
    Method EnableMotor : void (flag:Bool)
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_enableMotor = flag
    End
    #rem
    '/**
    '* Set the motor speed, usually in meters per second.
    '*/
    #end
    Method SetMotorSpeed : void (speed:Float)
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_motorSpeed = speed
    End
    #rem
    '/**
    '* Get the motor speed, usually in meters per second.
    '*/
    #end
    Method GetMotorSpeed : Float ()
        
        Return m_motorSpeed
    End
    #rem
    '/**
    '* Set the maximum motor force, usually in N.
    '*/
    #end
    Method SetMaxMotorForce : void (force:Float)
        
        m_bodyA.SetAwake(True)
        m_bodyB.SetAwake(True)
        m_maxMotorForce = force
    End
    #rem
    '/**
    '* Get the current motor force, usually in N.
    '*/
    #end
    Method GetMotorForce : Float ()
        
        Return m_motorImpulse
    End
    '//--------------- Internals Below -------------------
    '* @
    Method New(def:b2PrismaticJointDef)
        
        Super.New(def)
        Local tMat :b2Mat22
        Local tX :Float
        Local tY :Float
        m_localAnchor1.SetV(def.localAnchorA)
        m_localAnchor2.SetV(def.localAnchorB)
        m_localXAxis1.SetV(def.localAxisA)
        '//m_localYAxisA = b2Cross(1.0f, m_localXAxisA)
        m_localYAxis1.x = -m_localXAxis1.y
        m_localYAxis1.y = m_localXAxis1.x
        m_refAngle = def.referenceAngle
        m_impulse.SetZero()
        m_motorMass = 0.0
        m_motorImpulse = 0.0
        m_lowerTranslation = def.lowerTranslation
        m_upperTranslation = def.upperTranslation
        m_maxMotorForce = def.maxMotorForce
        m_motorSpeed = def.motorSpeed
        m_enableLimit = def.enableLimit
        m_enableMotor = def.enableMotor
        m_limitState = e_inactiveLimit
        m_axis.SetZero()
        m_perp.SetZero()
    End
    Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local tMat :b2Mat22
        Local tX :Float
        m_localCenterA.SetV(bA.GetLocalCenter())
        m_localCenterB.SetV(bB.GetLocalCenter())
        Local xf1 :b2Transform = bA.GetTransform()
        Local xf2 :b2Transform = bB.GetTransform()
        '// Compute the effective masses.
        '//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter())
        tMat = bA.m_xf.R
        Local r1X :Float = m_localAnchor1.x - m_localCenterA.x
        Local r1Y :Float = m_localAnchor1.y - m_localCenterA.y
        tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
        r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
        r1X = tX
        '//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter())
        tMat = bB.m_xf.R
        Local r2X :Float = m_localAnchor2.x - m_localCenterB.x
        Local r2Y :Float = m_localAnchor2.y - m_localCenterB.y
        tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
        r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
        r2X = tX
        '//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1
        Local dX :Float = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X
        Local dY :Float = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y
        m_invMassA = bA.m_invMass
        m_invMassB = bB.m_invMass
        m_invIA = bA.m_invI
        m_invIB = bB.m_invI
        '// Compute motor Jacobian and effective mass.
        
        b2Math.MulMV(xf1.R, m_localXAxis1,m_axis)
        '//m_a1 = b2Math.b2Cross(d + r1, m_axis)
        m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x
        '//m_a2 = b2Math.b2Cross(r2, m_axis)
        m_a2 = r2X * m_axis.y - r2Y * m_axis.x
        m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2
        If(m_motorMass > Constants.EPSILON)
            m_motorMass = 1.0 / m_motorMass
        End
        'End
        '// Prismatic constraint.
        
        b2Math.MulMV(xf1.R, m_localYAxis1,m_perp)
        '//m_s1 = b2Math.b2Cross(d + r1, m_perp)
        m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x
        '//m_s2 = b2Math.b2Cross(r2, m_perp)
        m_s2 = r2X * m_perp.y - r2Y * m_perp.x
        Local m1 :Float = m_invMassA
        Local m2 :Float = m_invMassB
        Local i1 :Float = m_invIA
        Local i2 :Float = m_invIB
        m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2
        m_K.col1.y = i1 * m_s1 + i2 * m_s2
        m_K.col1.z = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2
        m_K.col2.x = m_K.col1.y
        m_K.col2.y = i1 + i2
        m_K.col2.z = i1 * m_a1 + i2 * m_a2
        m_K.col3.x = m_K.col1.z
        m_K.col3.y = m_K.col2.z
        m_K.col3.z = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2
        'End
        '// Compute motor and limit terms
        If (m_enableLimit)
            
            '//float32 jointTranslation = b2Dot(m_axis, d)
            Local jointTransition :Float = m_axis.x * dX + m_axis.y * dY
            If (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0 * b2Settings.b2_linearSlop)
                
                m_limitState = e_equalLimits
            Else  If (jointTransition <= m_lowerTranslation)
                
                
                If (m_limitState <> e_atLowerLimit)
                    
                    m_limitState = e_atLowerLimit
                    m_impulse.z = 0.0
                End
                
            Else  If (jointTransition >= m_upperTranslation)
                
                
                If (m_limitState <> e_atUpperLimit)
                    
                    m_limitState = e_atUpperLimit
                    m_impulse.z = 0.0
                End
                
            Else
                
                
                m_limitState = e_inactiveLimit
                m_impulse.z = 0.0
            End
            
        Else
            
            
            m_limitState = e_inactiveLimit
        End
        If (m_enableMotor = False)
            
            m_motorImpulse = 0.0
        End
        If (timeStep.warmStarting)
            
            '// Account for variable time timeStep.
            m_impulse.x *= timeStep.dtRatio
            m_impulse.y *= timeStep.dtRatio
            m_motorImpulse *= timeStep.dtRatio
            '//b2Vec2 P = m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis
            Local PX :Float = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x
            Local PY :Float = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y
            Local L1 :Float = m_impulse.x * m_s1 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a1
            Local L2 :Float = m_impulse.x * m_s2 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a2
            '//bA->m_linearVelocity -= m_invMassA * P
            bA.m_linearVelocity.x -= m_invMassA * PX
            bA.m_linearVelocity.y -= m_invMassA * PY
            '//bA->m_angularVelocity -= m_invIA * L1
            bA.m_angularVelocity -= m_invIA * L1
            '//bB->m_linearVelocity += m_invMassB * P
            bB.m_linearVelocity.x += m_invMassB * PX
            bB.m_linearVelocity.y += m_invMassB * PY
            '//bB->m_angularVelocity += m_invIB * L2
            bB.m_angularVelocity += m_invIB * L2
        Else
            
            
            m_impulse.SetZero()
            m_motorImpulse = 0.0
        End
    End
    Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local v1 :b2Vec2 = bA.m_linearVelocity
        Local w1 :Float = bA.m_angularVelocity
        Local v2 :b2Vec2 = bB.m_linearVelocity
        Local w2 :Float = bB.m_angularVelocity
        Local PX :Float
        Local PY :Float
        Local L1 :Float
        Local L2 :Float
        '// Solve linear motor constraint
        If (m_enableMotor And m_limitState <> e_equalLimits)
            
            '//float32 Cdot = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1
            Local Cdot :Float = m_axis.x * (v2.x -v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1
            Local impulse :Float = m_motorMass * (m_motorSpeed - Cdot)
            Local oldImpulse :Float = m_motorImpulse
            Local maxImpulse :Float = timeStep.dt * m_maxMotorForce
            m_motorImpulse = b2Math.Clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse)
            impulse = m_motorImpulse - oldImpulse
            PX = impulse * m_axis.x
            PY = impulse * m_axis.y
            L1 = impulse * m_a1
            L2 = impulse * m_a2
            v1.x -= m_invMassA * PX
            v1.y -= m_invMassA * PY
            w1 -= m_invIA * L1
            v2.x += m_invMassB * PX
            v2.y += m_invMassB * PY
            w2 += m_invIB * L2
        End
        '//Cdot1.x = b2Dot(m_perp, v2 - v1) + m_s2 * w2 - m_s1 * w1
        Local Cdot1X :Float = m_perp.x * (v2.x - v1.x) + m_perp.y * (v2.y - v1.y) + m_s2 * w2 - m_s1 * w1
        Local Cdot1Y :Float = w2 - w1
        If (m_enableLimit And m_limitState <> e_inactiveLimit)
            
            '// Solve prismatic and limit constraint in block form
            '//Cdot2 = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1
            Local Cdot2 :Float = m_axis.x * (v2.x - v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1
            Local f1 :b2Vec3 = m_impulse.Copy()
            Local df :b2Vec3 = m_K.Solve33(New b2Vec3(), -Cdot1X, -Cdot1Y, -Cdot2)
            m_impulse.Add(df)
            If (m_limitState = e_atLowerLimit)
                
                m_impulse.z = b2Math.Max(m_impulse.z, 0.0)
            Else  If (m_limitState = e_atUpperLimit)
                
                
                m_impulse.z = b2Math.Min(m_impulse.z, 0.0)
            End
            '// f2(1:2) = invK(1:2,1:2) * (-Cdot3\(1:2) - K(1:2,3) * (f2(3) - f1(3))) + f1(1:2)
            '//b2Vec2 b = -Cdot1 - (m_impulse.z - f1.z) * b2Vec2(m_K.col3.x, m_K.col3.y)
            Local bX :Float = -Cdot1X - (m_impulse.z - f1.z) * m_K.col3.x
            Local bY :Float = -Cdot1Y - (m_impulse.z - f1.z) * m_K.col3.y
            Local f2r :b2Vec2 = m_K.Solve22(New b2Vec2(), bX, bY)
            f2r.x += f1.x
            f2r.y += f1.y
            m_impulse.x = f2r.x
            m_impulse.y = f2r.y
            df.x = m_impulse.x - f1.x
            df.y = m_impulse.y - f1.y
            df.z = m_impulse.z - f1.z
            PX = df.x * m_perp.x + df.z * m_axis.x
            PY = df.x * m_perp.y + df.z * m_axis.y
            L1 = df.x * m_s1 + df.y + df.z * m_a1
            L2 = df.x * m_s2 + df.y + df.z * m_a2
            v1.x -= m_invMassA * PX
            v1.y -= m_invMassA * PY
            w1 -= m_invIA * L1
            v2.x += m_invMassB * PX
            v2.y += m_invMassB * PY
            w2 += m_invIB * L2
        Else
            
            
            '// inactive(Limit), just solve the prismatic constraint in block form.
            Local df2 :b2Vec2 = m_K.Solve22(New b2Vec2(), -Cdot1X, -Cdot1Y)
            m_impulse.x += df2.x
            m_impulse.y += df2.y
            PX = df2.x * m_perp.x
            PY = df2.x * m_perp.y
            L1 = df2.x * m_s1 + df2.y
            L2 = df2.x * m_s2 + df2.y
            v1.x -= m_invMassA * PX
            v1.y -= m_invMassA * PY
            w1 -= m_invIA * L1
            v2.x += m_invMassB * PX
            v2.y += m_invMassB * PY
            w2 += m_invIB * L2
        End
        bA.m_linearVelocity.SetV(v1)
        bA.m_angularVelocity = w1
        bB.m_linearVelocity.SetV(v2)
        bB.m_angularVelocity = w2
    End
    Method SolvePositionConstraints : Bool (baumgarte:Float )
        
        '//B2_NOT_USED(baumgarte)
        Local limitC :Float
        Local oldLimitImpulse :Float
        Local bA :b2Body = m_bodyA
        Local bB :b2Body = m_bodyB
        Local c1 :b2Vec2 = bA.m_sweep.c
        Local a1 :Float = bA.m_sweep.a
        Local c2 :b2Vec2 = bB.m_sweep.c
        Local a2 :Float = bB.m_sweep.a
        Local tMat :b2Mat22
        Local tX :Float
        Local m1 :Float
        Local m2 :Float
        Local i1 :Float
        Local i2 :Float
        '// Solve linear limit constraint
        Local linearError :Float = 0.0
        Local angularError :Float = 0.0
        Local active :Bool = False
        Local C2 :Float = 0.0
        Local R1 :b2Mat22 = b2Mat22.FromAngle(a1)
        Local R2 :b2Mat22 = b2Mat22.FromAngle(a2)
        '//b2Vec2 r1 = b2Mul(R1, m_localAnchor1 - m_localCenterA)
        tMat = R1
        Local r1X :Float = m_localAnchor1.x - m_localCenterA.x
        Local r1Y :Float = m_localAnchor1.y - m_localCenterA.y
        tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
        r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
        r1X = tX
        '//b2Vec2 r2 = b2Mul(R2, m_localAnchor2 - m_localCenterB)
        tMat = R2
        Local r2X :Float = m_localAnchor2.x - m_localCenterB.x
        Local r2Y :Float = m_localAnchor2.y - m_localCenterB.y
        tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
        r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y)
        r2X = tX
        Local dX :Float = c2.x + r2X - c1.x - r1X
        Local dY :Float = c2.y + r2Y - c1.y - r1Y
        If (m_enableLimit)
            
            b2Math.MulMV(R1, m_localXAxis1,m_axis)
            '//m_a1 = b2Math.b2Cross(d + r1, m_axis)
            m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x
            '//m_a2 = b2Math.b2Cross(r2, m_axis)
            m_a2 = r2X * m_axis.y - r2Y * m_axis.x
            Local translation :Float = m_axis.x * dX + m_axis.y * dY
            If (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0 * b2Settings.b2_linearSlop)
                
                '// Prevent large angular corrections.
                C2 = b2Math.Clamp(translation, -b2Settings.b2_maxLinearCorrection, b2Settings.b2_maxLinearCorrection)
                linearError = b2Math.Abs(translation)
                active = True
            Else  If (translation <= m_lowerTranslation)
                
                
                '// Prevent large angular corrections and allow some slop.
                C2 = b2Math.Clamp(translation - m_lowerTranslation + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0)
                linearError = m_lowerTranslation - translation
                active = True
            Else  If (translation >= m_upperTranslation)
                
                
                '// Prevent large angular corrections and allow some slop.
                C2 = b2Math.Clamp(translation - m_upperTranslation + b2Settings.b2_linearSlop, 0.0, b2Settings.b2_maxLinearCorrection)
                linearError = translation - m_upperTranslation
                active = True
            End
        End
        b2Math.MulMV(R1, m_localYAxis1,m_perp)
        '//m_s1 = b2Cross(d + r1, m_perp)
        m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x
        '//m_s2 = b2Cross(r2, m_perp)
        m_s2 = r2X * m_perp.y - r2Y * m_perp.x
        Local impulse :b2Vec3 = New b2Vec3()
        Local C1X :Float = m_perp.x * dX + m_perp.y * dY
        Local C1Y :Float = a2 - a1 - m_refAngle
        linearError = b2Math.Max(linearError, b2Math.Abs(C1X))
        angularError = b2Math.Abs(C1Y)
        If (active)
            
            m1 = m_invMassA
            m2 = m_invMassB
            i1 = m_invIA
            i2 = m_invIB
            m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2
            m_K.col1.y = i1 * m_s1 + i2 * m_s2
            m_K.col1.z = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2
            m_K.col2.x = m_K.col1.y
            m_K.col2.y = i1 + i2
            m_K.col2.z = i1 * m_a1 + i2 * m_a2
            m_K.col3.x = m_K.col1.z
            m_K.col3.y = m_K.col2.z
            m_K.col3.z = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2
            m_K.Solve33(impulse, -C1X, -C1Y, -C2)
        Else
            
            
            m1 = m_invMassA
            m2 = m_invMassB
            i1 = m_invIA
            i2 = m_invIB
            Local k11 :Float  = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2
            Local k12 :Float = i1 * m_s1 + i2 * m_s2
            Local k22 :Float = i1 + i2
            m_K.col1.Set(k11, k12, 0.0)
            m_K.col2.Set(k12, k22, 0.0)
            Local impulse1 :b2Vec2 = m_K.Solve22(New b2Vec2(), -C1X, -C1Y)
            impulse.x = impulse1.x
            impulse.y = impulse1.y
            impulse.z = 0.0
        End
        Local PX :Float = impulse.x * m_perp.x + impulse.z * m_axis.x
        Local PY :Float = impulse.x * m_perp.y + impulse.z * m_axis.y
        Local L1 :Float = impulse.x * m_s1 + impulse.y + impulse.z * m_a1
        Local L2 :Float = impulse.x * m_s2 + impulse.y + impulse.z * m_a2
        c1.x -= m_invMassA * PX
        c1.y -= m_invMassA * PY
        a1 -= m_invIA * L1
        c2.x += m_invMassB * PX
        c2.y += m_invMassB * PY
        a2 += m_invIB * L2
        '// TODO_ERIN remove need for this
        '//bA.m_sweep.c = c1	//Already done by reference
        bA.m_sweep.a = a1
        '//bB.m_sweep.c = c2	//Already done by reference
        bB.m_sweep.a = a2
        bA.SynchronizeTransform()
        bB.SynchronizeTransform()
        Return linearError <= b2Settings.b2_linearSlop And angularError <= b2Settings.b2_angularSlop
    End
    
    Field m_localAnchor1:b2Vec2 = New b2Vec2()
    
    
    Field m_localAnchor2:b2Vec2 = New b2Vec2()
    
    
    Field m_localXAxis1:b2Vec2 = New b2Vec2()
    
    
    Field m_localYAxis1:b2Vec2 = New b2Vec2()
    
    
    Field m_refAngle:Float
    
    Field m_axis:b2Vec2 = New b2Vec2()
    
    
    Field m_perp:b2Vec2 = New b2Vec2()
    
    
    Field m_s1:Float
    
    
    Field m_s2:Float
    
    
    Field m_a1:Float
    
    
    Field m_a2:Float
    
    Field m_K:b2Mat33 = New b2Mat33()
    
    
    Field m_impulse:b2Vec3 = New b2Vec3()
    
    Field m_motorMass:Float
    '// effective mass for motor/limit translational constraint.
    
    
    Field m_motorImpulse:Float
    
    Field m_lowerTranslation:Float
    
    
    Field m_upperTranslation:Float
    
    
    Field m_maxMotorForce:Float
    
    
    Field m_motorSpeed:Float
    
    Field m_enableLimit:Bool
    
    
    Field m_enableMotor:Bool
    
    
    Field m_limitState:Int
    
    
End

