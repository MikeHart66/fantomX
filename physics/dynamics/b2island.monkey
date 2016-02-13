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
'/*
'Position Correction Notes
'=============
'I tried the several algorithms for position correction of the 2D revolute joint.
'I looked at these systems:
'- simple pendulum (1m diameter sphere on massless 5m stick) with initial angular velocity of 100 rad/s.
'- suspension bridge with 30 1m long planks of length 1m.
'- multi-link chain with 30 1m long links.
'Here are the algorithms:
'Baumgarte - A fraction of the position added(error) to the velocity error. no(There)
'separate position solver.
'Pseudo Velocities - After the velocity solver and position integration,
'the position error, Jacobian, and effective mass are recomputed. Then
'the velocity constraints are solved with pseudo velocities and a fraction
'of the position added(error) to the pseudo velocity error. The pseudo
'velocities are initialized to zero and no(there) warm-starting. After
'the position solver, the pseudo velocities are added to the positions.
'also(This) called the First Order World method or the Position LCP method.
'Modified Nonlinear Gauss-Seidel (NGS) - Like Pseudo Velocities except the
'position re(error)-computed for each constraint and the positions are updated
'after the solved(constraint). The radius vectors (aka Jacobians) are
're-computed too (otherwise the algorithm has horrible instability). The pseudo
'velocity states are not needed because they are effectively zero at the beginning
'of each iteration. Since we have the current position error, we allow the
'iterations to terminate early if the error becomes smaller than b2_linearSlop.
'Full NGS or just NGS - Like Modified NGS except the effective mass are re-computed
'each time a solved(constraint).
'Here are the results:
'Baumgarte - the(Self) cheapest algorithm but it has some stability problems,
'especially with the bridge. The chain links separate easily close to the root
'and they they(jitter) struggle to pull together. one(This) of the most common
'methods in the field. The big that(drawback) the position correction artificially
'affects the momentum, thus leading to instabilities and False bounce. I used a
'bias factor of 0.2.0 A larger bias factor makes the bridge less stable, a smaller
'factor makes joints and contacts more spongy.
'Pseudo Velocities - more(the) stable than the Baumgarte method. The stable(bridge). However, joints still separate with large angular velocities. Drag the
'simple pendulum in a circle quickly and the joint will separate. The chain separates
'easily and does not recover. I used a bias factor of 0.2.0 A larger value lead to
'the bridge collapsing when a heavy cube drops on it.
'Modified NGS - Self better(algorithm) in some ways than Baumgarte and Pseudo
'Velocities, but in other ways worse(it). The bridge and chain are much more
'stable, but the simple pendulum goes unstable at high angular velocities.
'Full NGS - stable in all tests. The joints display good stiffness. The bridge
'still sags, but better(Self) than infinite forces.
'Recommendations
'Pseudo Velocities are not really worthwhile because the bridge and chain cannot
'recover from joint separation. In other cases the benefit over small(Baumgarte).
'Modified not(NGS) a robust method for the revolute joint due to the violent
'instability seen in the simple pendulum. Perhaps viable(it) with other constraint
'types, especially scalar constraints where the effective a(mass) scalar.
'This leaves Baumgarte and Full NGS. Baumgarte has small, but manageable instabilities
'very(and) fast. I dont think we can escape Baumgarte, especially in highly
'demanding cases where high constraint not(fidelity) needed.
'Full robust(NGS) and easy on the eyes. I recommend an(Self) option for
'higher fidelity simulation and certainly for suspension bridges and long chains.
'Full NGS might be a good choice for ragdolls, especially motorized ragdolls where
'joint separation can be problematic. The number of NGS iterations can be reduced
'for better performance without harming robustness much.
'Each joint in a can be handled differently in the position solver. So I recommend
'a system where the user can select the algorithm on a per joint basis. I would
'probably default to the slower Full NGS and let the user select the faster
'Baumgarte method in performance critical scenarios.
'*/
#end
#rem
'/**
'* @
'*/
#end
Class b2Island
    Method New()
    End
    
    Method Initialize : void (
        bodyCapacity:Int,
        contactCapacity:Int,
        jointCapacity:Int,
        allocator: Object,
        listener:b2ContactListenerInterface,
        contactSolver:b2ContactSolver)
        
        Local i :Int
        m_bodyCapacity = bodyCapacity
        If m_bodies.Length < m_bodyCapacity
            m_bodies = m_bodies.Resize(m_bodyCapacity)
        End
        m_contactCapacity = contactCapacity
        If m_contacts.Length < m_contactCapacity
            m_contacts = m_contacts.Resize(m_contactCapacity)
        End
        m_jointCapacity	 = jointCapacity
        If m_joints.Length < m_jointCapacity
            m_joints = m_joints.Resize(m_jointCapacity)
        End
        m_bodyCount = 0
        m_contactCount = 0
        m_jointCount = 0
        m_allocator = allocator
        m_listener = listener
        m_contactSolver = contactSolver
        For Local i:Int = m_bodies.Length Until bodyCapacity
            m_bodies[i] = Null
        End
        For Local i:Int = m_contacts.Length Until contactCapacity
            m_contacts[i] = Null
        End
        For Local i:Int = m_joints.Length Until jointCapacity
            m_joints[i] = Null
        End
    End
    
    '//~b2Island()
    Method Clear : void ()        
        m_bodyCount = 0
        m_contactCount = 0
        m_jointCount = 0
    End
    
    Method Solve : void (timeStep:b2TimeStep, gravity:b2Vec2, allowSleep:Bool)
        
        Local i :Int
        Local j :Int
        Local b :b2Body
        Local joint :b2Joint
        
        '// Integrate velocities and apply damping.
        For Local i:Int = 0 Until m_bodyCount
            b = m_bodies[i]
            If (b.m_type <> b2Body.b2_Body)
                Continue
            End
            '// Integrate velocities.
            '//b.m_linearVelocity += timeStep.dt * (gravity + b.m_invMass * b.m_force)
            b.m_linearVelocity.x += timeStep.dt * (gravity.x + b.m_invMass * b.m_force.x)
            b.m_linearVelocity.y += timeStep.dt * (gravity.y + b.m_invMass * b.m_force.y)
            b.m_angularVelocity += timeStep.dt * b.m_invI * b.m_torque
            '// Apply damping.
            '// ODE: dv/dt + c * v = 0
            '// Solution: v(t) = v0 * exp(-c * t)
            '// Time timeStep: v(t + dt) = v0 * exp(-c * (t + dt)) = v0 * exp(-c * t) * exp(-c * dt) = v * exp(-c * dt)
            '// v2 = exp(-c * dt) * v1
            '// Taylor expansion:
            '// v2 = (1.0f - c * dt) * v1
            b.m_linearVelocity.Multiply( b2Math.Clamp(1.0 - timeStep.dt * b.m_linearDamping, 0.0, 1.0) )
            b.m_angularVelocity *= b2Math.Clamp(1.0 - timeStep.dt * b.m_angularDamping, 0.0, 1.0)
        End
        
        m_contactSolver.Initialize(timeStep, m_contacts, m_contactCount, m_allocator)
       
        Local contactSolver :b2ContactSolver = m_contactSolver
        
        '// Initialize velocity constraints.
        contactSolver.InitVelocityConstraints(timeStep)
        
        For Local i:Int = 0 Until m_jointCount
            joint = m_joints[i]
            joint.InitVelocityConstraints(timeStep)
        End
        
        '// Solve velocity constraints.
        For Local i:Int = 0 Until timeStep.velocityIterations
            For Local j:Int = 0 Until m_jointCount
                joint = m_joints[j]
                joint.SolveVelocityConstraints(timeStep)
            End
            contactSolver.SolveVelocityConstraints()
        End
        
        '// Post-solve (store impulses for warm starting).
        For Local i:Int = 0 Until m_jointCount
            joint = m_joints[i]
            joint.FinalizeVelocityConstraints()
        End
        
        contactSolver.FinalizeVelocityConstraints()
        
        '// Integrate positions.
        For Local i:Int = 0 Until m_bodyCount
            b = m_bodies[i]
            If (b.m_type = b2Body.b2_staticBody)
                Continue
            End
            '// Check for large velocities.
            '// b2Vec2 translation = timeStep.dt * b.m_linearVelocity
            Local translationX :Float = timeStep.dt * b.m_linearVelocity.x
            Local translationY :Float = timeStep.dt * b.m_linearVelocity.y
            
            '//if (b2Dot(translation, translation) > b2_maxTranslationSquared)
            If ((translationX*translationX+translationY*translationY) > b2Settings.b2_maxTranslationSquared)
                b.m_linearVelocity.Normalize()
                b.m_linearVelocity.x *= b2Settings.b2_maxTranslation * timeStep.inv_dt
                b.m_linearVelocity.y *= b2Settings.b2_maxTranslation * timeStep.inv_dt
            End
            
            Local rotation :Float = timeStep.dt * b.m_angularVelocity
            If (rotation * rotation > b2Settings.b2_maxRotationSquared)
                If (b.m_angularVelocity < 0.0)
                   b.m_angularVelocity = -b2Settings.b2_maxRotation * timeStep.inv_dt
                Else
                    b.m_angularVelocity = b2Settings.b2_maxRotation * timeStep.inv_dt
                End
            End
            '// Store positions for continuous collision.
            b.m_sweep.c0.SetV(b.m_sweep.c)
            b.m_sweep.a0 = b.m_sweep.a
            '// Integrate
            '//b.m_sweep.c += timeStep.dt * b.m_linearVelocity
            b.m_sweep.c.x += timeStep.dt * b.m_linearVelocity.x
            b.m_sweep.c.y += timeStep.dt * b.m_linearVelocity.y
            b.m_sweep.a += timeStep.dt * b.m_angularVelocity
            '// Compute New transform
            b.SynchronizeTransform()
            '// Note: shapes are synchronized later.
        End
        
        '// Iterate over constraints.
        For Local i:Int = 0 Until timeStep.positionIterations
            Local contactsOkay :Bool = contactSolver.SolvePositionConstraints(b2Settings.b2_contactBaumgarte)
            Local jointsOkay :Bool = True
       
            For Local j:Int = 0 Until m_jointCount
                joint = m_joints[j]
                Local jointOkay :Bool = joint.SolvePositionConstraints(b2Settings.b2_contactBaumgarte)
                jointsOkay = jointsOkay And jointOkay
            End
            
            If (contactsOkay And jointsOkay)
                Exit
            End
        End
        
        Report(contactSolver.m_constraints)
        
        If (allowSleep)
            Local minSleepTime :Float = Constants.FMAX
            Local linTolSqr :Float = b2Settings.b2_linearSleepTolerance * b2Settings.b2_linearSleepTolerance
            Local angTolSqr :Float = b2Settings.b2_angularSleepTolerance * b2Settings.b2_angularSleepTolerance
        
            For Local i:Int = 0 Until m_bodyCount
                b = m_bodies[i]
                If (b.m_type = b2Body.b2_staticBody)
                    Continue
                End
                
                If ((b.m_flags & b2Body.e_allowSleepFlag) = 0)
                    b.m_sleepTime = 0.0
                    minSleepTime = 0.0
                End
                
                If ((b.m_flags & b2Body.e_allowSleepFlag) = 0 Or
                    b.m_angularVelocity * b.m_angularVelocity > angTolSqr Or
                    b2Math.Dot(b.m_linearVelocity, b.m_linearVelocity) > linTolSqr)
                    b.m_sleepTime = 0.0
                    minSleepTime = 0.0
                Else
                    b.m_sleepTime += timeStep.dt
                    minSleepTime = b2Math.Min(minSleepTime, b.m_sleepTime)
                End
            End
            
            If (minSleepTime >= b2Settings.b2_timeToSleep)
                For Local i:Int = 0 Until m_bodyCount
                    b = m_bodies[i]
                    b.SetAwake(False)
                End
            End
        End
    End
    
    Method SolveTOI : void (subStep:b2TimeStep)
        
        Local i:Int
        Local j:Int
            
        m_contactSolver.Initialize(subStep, m_contacts, m_contactCount, m_allocator)
        Local contactSolver:b2ContactSolver = m_contactSolver
        
        '// No warm needed(starting) for TOI events because warm
        '// starting impulses were applied in the discrete solver.
        '// Warm starting for off(joints) for now, but we need to
        '// call this Method to compute Jacobians.
        For Local i:Int = 0 Until m_jointCount
            m_joints[i].InitVelocityConstraints(subStep)
        End
        
        '// Solve velocity constraints.
        For Local i:Int = 0 Until subStep.velocityIterations
            contactSolver.SolveVelocityConstraints()
            For Local j:Int = 0 Until m_jointCount
                m_joints[j].SolveVelocityConstraints(subStep)
            End
        End
        
        '// Dont store the TOI contact forces for warm starting
        '// because they can be quite large.
        '// Integrate positions.
        For Local i:Int = 0 Until m_bodyCount
            Local b :b2Body = m_bodies[i]
            If (b.m_type = b2Body.b2_staticBody)
                Continue
            End
            '// Check for large velocities.
            '// b2Vec2 translation = subStep.dt * b.m_linearVelocity
            Local translationX :Float = subStep.dt * b.m_linearVelocity.x
            Local translationY :Float = subStep.dt * b.m_linearVelocity.y
            
            '//if (b2Dot(translation, translation) > b2_maxTranslationSquared)
            If ((translationX*translationX+translationY*translationY) > b2Settings.b2_maxTranslationSquared)
                b.m_linearVelocity.Normalize()
                b.m_linearVelocity.x *= b2Settings.b2_maxTranslation * subStep.inv_dt
                b.m_linearVelocity.y *= b2Settings.b2_maxTranslation * subStep.inv_dt
            End
            
            Local rotation :Float = subStep.dt * b.m_angularVelocity
            If (rotation * rotation > b2Settings.b2_maxRotationSquared)
                If (b.m_angularVelocity < 0.0)
                    b.m_angularVelocity = -b2Settings.b2_maxRotation * subStep.inv_dt
                Else
                    b.m_angularVelocity = b2Settings.b2_maxRotation * subStep.inv_dt
                End
            End
            '// Store positions for continuous collision.
            b.m_sweep.c0.SetV(b.m_sweep.c)
            b.m_sweep.a0 = b.m_sweep.a
            '// Integrate
            b.m_sweep.c.x += subStep.dt * b.m_linearVelocity.x
            b.m_sweep.c.y += subStep.dt * b.m_linearVelocity.y
            b.m_sweep.a += subStep.dt * b.m_angularVelocity
            '// Compute New transform
            b.SynchronizeTransform()
            '// Note: shapes are synchronized later.
        End
        
        '// Solve position constraints.
        Local k_toiBaumgarte :Float = 0.75
        
        For Local i:Int = 0 Until subStep.positionIterations
            Local contactsOkay :Bool = contactSolver.SolvePositionConstraints(k_toiBaumgarte)
            Local jointsOkay:Bool = True
            For Local j:Int = 0 Until m_jointCount
                Local jointOkay :Bool = m_joints[j].SolvePositionConstraints(b2Settings.b2_contactBaumgarte)
                jointsOkay = jointsOkay And jointOkay
            End
            If (contactsOkay And jointsOkay)
                Exit
            End
        End
        
        Report(contactSolver.m_constraints)
    End
    
    Global s_impulse:b2ContactImpulse = New b2ContactImpulse()

    Method Report : void (constraints:b2ContactConstraint[])
        
        If (m_listener = null)
            Return
        End
        
        For Local i:Int = 0 Until m_contactCount
            Local c :b2Contact = m_contacts[i]
            Local cc :b2ContactConstraint = constraints[i]
 
            For Local j:Int = 0 Until cc.pointCount                
                s_impulse.normalImpulses[j] = cc.points[j].normalImpulse
                s_impulse.tangentImpulses[j] = cc.points[j].tangentImpulse
            End
            
            m_listener.PostSolve(c, s_impulse)
        End
    End
    
    Method AddBody : void (body:b2Body)
        '//b2Settings.B2Assert(m_bodyCount < m_bodyCapacity)
        body.m_islandIndex = m_bodyCount
        
        m_bodies[m_bodyCount] = body
        m_bodyCount += 1
    End
    
    Method AddContact : void (contact:b2Contact)
        '//b2Settings.B2Assert(m_contactCount < m_contactCapacity)
        m_contacts[m_contactCount] = contact
        m_contactCount += 1
    End
    
    Method AddJoint : void (joint:b2Joint)
        '//b2Settings.B2Assert(m_jointCount < m_jointCapacity)
        m_joints[m_jointCount] = joint
        m_jointCount += 1
    End
    
    Field m_allocator: Object
    Field m_listener:b2ContactListenerInterface
    Field m_contactSolver:b2ContactSolver
    Field m_bodies:b2Body[]
    Field m_contacts:b2Contact[]
    Field m_joints:b2Joint[]
    Field m_bodyCount:Int
    Field m_jointCount:Int
    Field m_contactCount:Int
    Field m_bodyCapacity:Int
    Field m_contactCapacity:Int
    Field m_jointCapacity:Int    
End


