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
'* @
'*/
#end
Class b2ContactSolver
    
    Field m_step:b2TimeStep = New b2TimeStep()
    Field m_allocator: Object
    Field m_constraints:b2ContactConstraint[]
    Field m_constraintCount:Int
    Field constraintCapacity:Int = 1000
    
    Method New()
        '// fill vector to hold enough constraints
        m_constraints = New b2ContactConstraint[constraintCapacity]
        
        For Local i:Int = 0 Until constraintCapacity
            m_constraints[i] =  New b2ContactConstraint()
        End
            
    End
    
    Global s_worldManifold:b2WorldManifold = New b2WorldManifold()
    Method Initialize : void (timeStep:b2TimeStep, contacts:b2Contact[], contactCount:Int, allocator: Object)
        
        Local contact :b2Contact
       
        m_step.Set(timeStep)
        m_allocator = allocator
        
        Local i :Int
        Local tVec :b2Vec2
        Local tMat :b2Mat22
        
        m_constraintCount = contactCount
        
        '// fill vector to hold enough constraints
        If m_constraintCount > constraintCapacity
            m_constraints = m_constraints.Resize(m_constraintCount)
            For Local i:Int = constraintCapacity Until m_constraintCount
                m_constraints[i] = New b2ContactConstraint()
            End
            constraintCapacity = m_constraintCount
        End
        
        For Local i:Int = 0 Until contactCount
            contact = contacts[i]
            Local fixtureA :b2Fixture = contact.m_fixtureA
            Local fixtureB :b2Fixture = contact.m_fixtureB
            Local shapeA :b2Shape = fixtureA.m_shape
            Local shapeB :b2Shape = fixtureB.m_shape
            Local radiusA :Float = shapeA.m_radius
            Local radiusB :Float = shapeB.m_radius
            Local bodyA :b2Body = fixtureA.m_body
            Local bodyB :b2Body = fixtureB.m_body
            Local manifold :b2Manifold = contact.GetManifold()
            Local friction :Float = b2Settings.B2MixFriction(fixtureA.GetFriction(), fixtureB.GetFriction())
            Local restitution :Float = b2Settings.B2MixRestitution(fixtureA.GetRestitution(), fixtureB.GetRestitution())
            '//var vA:b2Vec2 = bodyA.m_linearVelocity.Copy()
            Local vAX :Float = bodyA.m_linearVelocity.x
            Local vAY :Float = bodyA.m_linearVelocity.y
            '//var vB:b2Vec2 = bodyB.m_linearVelocity.Copy()
            Local vBX :Float = bodyB.m_linearVelocity.x
            Local vBY :Float = bodyB.m_linearVelocity.y
            Local wA :Float = bodyA.m_angularVelocity
            Local wB :Float = bodyB.m_angularVelocity
#If CONFIG = "debug"
            b2Settings.B2Assert(manifold.m_pointCount > 0)
#End
            s_worldManifold.Initialize(manifold, bodyA.m_xf, radiusA, bodyB.m_xf, radiusB)
            Local normalX :Float = s_worldManifold.m_normal.x
            Local normalY :Float = s_worldManifold.m_normal.y
            Local cc :b2ContactConstraint = m_constraints[i] 
            cc.bodyA = bodyA
            '//p
            cc.bodyB = bodyB
            '//p
            cc.manifold = manifold
            '//p
            '//c.normal = normal
            cc.normal.x = normalX
            cc.normal.y = normalY
            cc.pointCount = manifold.m_pointCount
            cc.friction = friction
            cc.restitution = restitution
            cc.localPlaneNormal.x = manifold.m_localPlaneNormal.x
            cc.localPlaneNormal.y = manifold.m_localPlaneNormal.y
            cc.localPoint.x = manifold.m_localPoint.x
            cc.localPoint.y = manifold.m_localPoint.y
            cc.radius = radiusA + radiusB
            cc.type = manifold.m_type
           
            For Local k:Int = 0 Until cc.pointCount
                Local cp :b2ManifoldPoint = manifold.m_points[k]
                Local ccp :b2ContactConstraintPoint = cc.points[k]
                ccp.normalImpulse = cp.m_normalImpulse
                ccp.tangentImpulse = cp.m_tangentImpulse
                ccp.localPoint.x = cp.m_localPoint.x
                ccp.localPoint.y = cp.m_localPoint.y
                ccp.rA.x = s_worldManifold.m_points[k].x - bodyA.m_sweep.c.x
                Local rAX :Float = ccp.rA.x
                ccp.rA.y = s_worldManifold.m_points[k].y - bodyA.m_sweep.c.y
                Local rAY :Float = ccp.rA.y
                ccp.rB.x = s_worldManifold.m_points[k].x - bodyB.m_sweep.c.x
                Local rBX :Float = ccp.rB.x
                ccp.rB.y = s_worldManifold.m_points[k].y - bodyB.m_sweep.c.y
                Local rBY :Float = ccp.rB.y
                Local rnA :Float = rAX * normalY - rAY * normalX
                '//b2Math.b2Cross(r1, normal)
                Local rnB :Float = rBX * normalY - rBY * normalX
                '//b2Math.b2Cross(r2, normal)
                rnA *= rnA
                rnB *= rnB
                Local kNormal :Float = bodyA.m_invMass + bodyB.m_invMass + bodyA.m_invI * rnA + bodyB.m_invI * rnB
                '//b2Settings.B2Assert(kNormal > Constants.EPSILON)
                ccp.normalMass = 1.0 / kNormal
                Local kEqualized :Float = bodyA.m_mass * bodyA.m_invMass + bodyB.m_mass * bodyB.m_invMass
                kEqualized += bodyA.m_mass * bodyA.m_invI * rnA + bodyB.m_mass * bodyB.m_invI * rnB
                '//b2Assert(kEqualized > Constants.EPSILON)
                ccp.equalizedMass = 1.0 / kEqualized
                '//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0)
                Local tangentX :Float = normalY
                Local tangentY :Float = -normalX
                '//var rtA:Float = b2Math.b2Cross(rA, tangent)
                Local rtA :Float = rAX*tangentY - rAY*tangentX
                '//var rtB:Float = b2Math.b2Cross(rB, tangent)
                Local rtB :Float = rBX*tangentY - rBY*tangentX
                rtA *= rtA
                rtB *= rtB
                Local kTangent :Float = bodyA.m_invMass + bodyB.m_invMass + bodyA.m_invI * rtA + bodyB.m_invI * rtB
                '//b2Settings.B2Assert(kTangent > Constants.EPSILON)
                ccp.tangentMass = 1.0 /  kTangent
                '// Setup a velocity bias for restitution.
                ccp.velocityBias = 0.0
                '//b2Dot(c.normal, vB + b2Cross(wB, rB) - vA - b2Cross(wA, rA))
                Local tX :Float = vBX + (wB*-rBY) - vAX - (wA*-rAY)
                Local tY :Float = vBY + (wB*rBX) - vAY - (wA*rAX)
                '//var vRel:Float = b2Dot(cc.normal, t)
                Local vRel :Float = cc.normal.x*tX + cc.normal.y*tY
                If (vRel < -b2Settings.b2_velocityThreshold)
                    ccp.velocityBias += -cc.restitution * vRel
                End
            End
            
            '// If we have two points, then prepare the block solver.
            If (cc.pointCount = 2)
                Local ccp1 :b2ContactConstraintPoint = cc.points[0]
                Local ccp2 :b2ContactConstraintPoint = cc.points[1]
                Local invMassA :Float = bodyA.m_invMass
                Local invIA :Float = bodyA.m_invI
                Local invMassB :Float = bodyB.m_invMass
                Local invIB :Float = bodyB.m_invI
                '//var rn1A:Float = b2Cross(ccp1.rA, normal)
                '//var rn1B:Float = b2Cross(ccp1.rB, normal)
                '//var rn2A:Float = b2Cross(ccp2.rA, normal)
                '//var rn2B:Float = b2Cross(ccp2.rB, normal)
                Local rn1A :Float = ccp1.rA.x * normalY - ccp1.rA.y * normalX
                Local rn1B :Float = ccp1.rB.x * normalY - ccp1.rB.y * normalX
                Local rn2A :Float = ccp2.rA.x * normalY - ccp2.rA.y * normalX
                Local rn2B :Float = ccp2.rB.x * normalY - ccp2.rB.y * normalX
                Local k11 :Float = invMassA + invMassB + invIA * rn1A * rn1A + invIB * rn1B * rn1B
                Local k22 :Float = invMassA + invMassB + invIA * rn2A * rn2A + invIB * rn2B * rn2B
                Local k12 :Float = invMassA + invMassB + invIA * rn1A * rn2A + invIB * rn1B * rn2B
                '// Ensure a reasonable condition number.
                Local k_maxConditionNumber :Float = 100.0
                If ( k11 * k11 < k_maxConditionNumber * (k11 * k22 - k12 * k12))
                    '// safe(K) to invert.
                    cc.K.col1.x = k11
                    cc.K.col1.y = k12
                    cc.K.col2.x = k12
                    cc.K.col2.y = k22
                    cc.K.GetInverse(cc.normalMass)
                Else
                    '// The constraints are redundant, just use one.
                    '// TODO_ERIN use deepest?
                    cc.pointCount = 1
                End
            End
        End
        '//b2Settings.B2Assert(count = m_constraintCount)
    End
    
    '//~b2ContactSolver()
    Method InitVelocityConstraints : void (timeStep: b2TimeStep)
        
        Local tVec :b2Vec2
        Local tVec2 :b2Vec2
        Local tMat :b2Mat22
        '// Warm start.
        For Local i:Int = 0 Until m_constraintCount
            
            Local c :b2ContactConstraint = m_constraints[i]
            Local bodyA :b2Body = c.bodyA
            Local bodyB :b2Body = c.bodyB
            Local invMassA :Float = bodyA.m_invMass
            Local invIA :Float = bodyA.m_invI
            Local invMassB :Float = bodyB.m_invMass
            Local invIB :Float = bodyB.m_invI
            '//var normal:b2Vec2 = New b2Vec2(c.normal.x, c.normal.y)
            Local normalX :Float = c.normal.x
            Local normalY :Float = c.normal.y
            '//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0)
            Local tangentX :Float = normalY
            Local tangentY :Float = -normalX
            Local tX :Float
            Local j :Int
            Local tCount :Int
            If (timeStep.warmStarting)
                
                tCount = c.pointCount
                For Local j:Int = 0 Until tCount
                    
                    Local ccp :b2ContactConstraintPoint = c.points[j]
                    ccp.normalImpulse *= timeStep.dtRatio
                    ccp.tangentImpulse *= timeStep.dtRatio
                    '//b2Vec2 P = ccp->normalImpulse * normal + ccp->tangentImpulse * tangent
                    Local PX :Float = ccp.normalImpulse * normalX + ccp.tangentImpulse * tangentX
                    Local PY :Float = ccp.normalImpulse * normalY + ccp.tangentImpulse * tangentY
                    '//bodyA.m_angularVelocity -= invIA * b2Math.b2CrossVV(rA, P)
                    bodyA.m_angularVelocity -= invIA * (ccp.rA.x * PY - ccp.rA.y * PX)
                    '//bodyA.m_linearVelocity.Subtract( b2Math.MulFV(invMassA, P) )
                    bodyA.m_linearVelocity.x -= invMassA * PX
                    bodyA.m_linearVelocity.y -= invMassA * PY
                    '//bodyB.m_angularVelocity += invIB * b2Math.b2CrossVV(rB, P)
                    bodyB.m_angularVelocity += invIB * (ccp.rB.x * PY - ccp.rB.y * PX)
                    '//bodyB.m_linearVelocity.Add( b2Math.MulFV(invMassB, P) )
                    bodyB.m_linearVelocity.x += invMassB * PX
                    bodyB.m_linearVelocity.y += invMassB * PY
                End
                
            Else
                
                
                tCount = c.pointCount
                For Local j:Int = 0 Until tCount
                    
                    Local ccp2 :b2ContactConstraintPoint = c.points[j]
                    ccp2.normalImpulse = 0.0
                    ccp2.tangentImpulse = 0.0
                End
            End
        End
    End
    
    Method SolveVelocityConstraints : void ()
        
        Local j :Int
        Local ccp :b2ContactConstraintPoint
        Local rAX :Float
        Local rAY :Float
        Local rBX :Float
        Local rBY :Float
        Local dvX :Float
        Local dvY :Float
        Local vn :Float
        Local vt :Float
        Local lambda :Float
        Local maxFriction :Float
        Local newImpulse :Float
        Local PX :Float
        Local PY :Float
        Local dX :Float
        Local dY :Float
        Local P1X :Float
        Local P1Y :Float
        Local P2X :Float
        Local P2Y :Float
        Local tMat :b2Mat22
        Local tVec :b2Vec2
        For Local i:Int = 0 Until m_constraintCount
            
            Local c :b2ContactConstraint = m_constraints[i]
            Local bodyA :b2Body = c.bodyA
            Local bodyB :b2Body = c.bodyB
            Local wA :Float = bodyA.m_angularVelocity
            Local wB :Float = bodyB.m_angularVelocity
            Local vA :b2Vec2 = bodyA.m_linearVelocity
            Local vB :b2Vec2 = bodyB.m_linearVelocity
            Local invMassA :Float = bodyA.m_invMass
            Local invIA :Float = bodyA.m_invI
            Local invMassB :Float = bodyB.m_invMass
            Local invIB :Float = bodyB.m_invI
            '//var normal:b2Vec2 = New b2Vec2(c.normal.x, c.normal.y)
            Local normalX :Float = c.normal.x
            Local normalY :Float = c.normal.y
            '//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0)
            Local tangentX :Float = normalY
            Local tangentY :Float = -normalX
            Local friction :Float = c.friction
            Local tX :Float
            '//b2Settings.B2Assert(c.pointCount = 1 Or c.pointCount = 2)
            '// Solve the tangent constraints
            For Local j:Int = 0 Until c.pointCount
                
                ccp = c.points[j]
                '// Relative velocity at contact
                '//b2Vec2 dv = vB + b2Cross(wB, ccp->rB) - vA - b2Cross(wA, ccp->rA)
                dvX = vB.x - wB * ccp.rB.y - vA.x + wA * ccp.rA.y
                dvY = vB.y + wB * ccp.rB.x - vA.y - wA * ccp.rA.x
                '// Compute tangent force
                vt = dvX * tangentX + dvY * tangentY
                lambda = ccp.tangentMass * -vt
                '// b2Clamp the accumulated force
                maxFriction = friction * ccp.normalImpulse
                newImpulse = ccp.tangentImpulse + lambda
                If (newImpulse < -maxFriction)
                    newImpulse = -maxFriction
                ElseIf(newImpulse > maxFriction)
                    newImpulse = maxFriction
                End
                'newImpulse = b2Math.Clamp(ccp.tangentImpulse + lambda, -maxFriction, maxFriction)
                lambda = newImpulse - ccp.tangentImpulse
                '// Apply contact impulse
                PX = lambda * tangentX
                PY = lambda * tangentY
                vA.x -= invMassA * PX
                vA.y -= invMassA * PY
                wA -= invIA * (ccp.rA.x * PY - ccp.rA.y * PX)
                vB.x += invMassB * PX
                vB.y += invMassB * PY
                wB += invIB * (ccp.rB.x * PY - ccp.rB.y * PX)
                ccp.tangentImpulse = newImpulse
            End
            '// Solve the normal constraints
            Local tCount :Int = c.pointCount
            If (c.pointCount = 1)
                
                ccp = c.points[0]
                Local ccpRa:b2Vec2 = ccp.rA
                Local ccpRb:b2Vec2 = ccp.rB
                
                '// Relative velocity at contact
                '//b2Vec2 dv = vB + b2Cross(wB, ccp->rB) - vA - b2Cross(wA, ccp->rA)
                dvX = vB.x + (wB * - ccpRb.y) - vA.x - (wA * - ccpRa.y)
                dvY = vB.y + (wB * ccpRb.x) - vA.y - (wA * ccpRa.x)
                '// Compute normal impulse
                '//var vn:Float = b2Math.b2Dot(dv, normal)
                vn = dvX * normalX + dvY * normalY
                lambda = -ccp.normalMass * (vn - ccp.velocityBias)
                '// b2Clamp the accumulated impulse
                '//newImpulse = b2Math.b2Max(ccp.normalImpulse + lambda, 0.0)
                newImpulse = ccp.normalImpulse + lambda
                If( newImpulse < 0.0  )
                    newImpulse = 0.0
                End
                
                lambda = newImpulse - ccp.normalImpulse
                '// Apply contact impulse
                '//b2Vec2 P = lambda * normal
                PX = lambda * normalX
                PY = lambda * normalY
                '//vA.Subtract( b2Math.MulFV( invMassA, P ) )
                vA.x -= invMassA * PX
                vA.y -= invMassA * PY
                wA -= invIA * (ccpRa.x * PY - ccpRa.y * PX)
                '//invIA * b2Math.b2CrossVV(ccp.rA, P)
                '//vB.Add( b2Math.MulFV( invMass2, P ) )
                vB.x += invMassB * PX
                vB.y += invMassB * PY
                wB += invIB * (ccpRb.x * PY - ccpRb.y * PX)
                '//invIB * b2Math.b2CrossVV(ccp.rB, P)
                ccp.normalImpulse = newImpulse
            Else
                
                
                '// Block solver developed in collaboration with Dirk Gregorius (back in 01/07 on Box2D_Lite).
                '// Build the mini LCP for this contact patch
                '//
                '// vn = A * x + b, vn >= 0, , vn >= 0, x >= 0 and vn_i * x_i = 0 with i = 1..2
                '//
                '// A = J * W * JT and J = ( -n, -r1 x n, n, r2 x n )
                '// b = vn_0 - velocityBias
                '//
                '// The solved(system) using the "Total enumeration method" (s. Murty). The complementary constraint vn_i * x_i
                '// implies that we must have in any solution either vn_i = 0 or x_i = 0.0 So for the 2D contact problem the cases
                '// vn1 = 0 and vn2 = 0, x1 = 0 and x2 = 0, x1 = 0 and vn2 = 0, x2 = 0 and vn1 = 0 need to be tested. The first valid
                '// solution that satisfies the chosen(problem).
                '//
                '// In order to account of the accumulated impulse a (because of the iterative nature of the solver which only requires
                '// that the accumulated clamped(impulse) and not the incremental impulse) we change the impulse variable (x_i).
                '//
                '// Substitute:
                '//
                '// x = x - a
                '//
                '// Plug into above equation:
                '//
                '// vn = A * x + b
                '//    = A * (x - a) + b
                '//    = A * x + b - A * a
                '//    = A * x + b
                '// b = b - A * a
                Local cp1:b2ContactConstraintPoint = c.points[0]
                Local cp1rA:b2Vec2 = cp1.rA
                Local cp1rB:b2Vec2 = cp1.rB
                
                Local cp2:b2ContactConstraintPoint = c.points[1]
                Local cp2rA:b2Vec2 = cp2.rA
                Local cp2rB:b2Vec2 = cp2.rB
                
                Local aX :Float = cp1.normalImpulse
                Local aY :Float = cp2.normalImpulse
                '//b2Settings.B2Assert( aX >= 0.0f And aY >= 0.0f )
                '// Relative velocity at contact
                '//var dv1:b2Vec2 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA)
                Local dv1X:Float = vB.x - wB * cp1rB.y - vA.x + wA * cp1rA.y
                Local dv1Y:Float = vB.y + wB * cp1rB.x - vA.y - wA * cp1rA.x
                '//var dv2:b2Vec2 = vB + b2Cross(wB, cpB.r2) - vA - b2Cross(wA, cp2.rA)
                Local dv2X:Float = vB.x - wB * cp2rB.y - vA.x + wA * cp2rA.y
                Local dv2Y:Float = vB.y + wB * cp2rB.x - vA.y - wA * cp2rA.x
                '// Compute normal velocity
                '//var vn1:Float = b2Dot(dv1, normal)
                Local vn1 :Float = dv1X * normalX + dv1Y * normalY
                '//var vn2:Float = b2Dot(dv2, normal)
                Local vn2 :Float = dv2X * normalX + dv2Y * normalY
                Local bX :Float = vn1 - cp1.velocityBias
                Local bY :Float = vn2 - cp2.velocityBias
                '//b -= b2Mul(c.K,a)
                tMat = c.K
                bX -= tMat.col1.x * aX + tMat.col2.x * aY
                bY -= tMat.col1.y * aX + tMat.col2.y * aY
                Local k_errorTol :Float  = 0.001
                While( True )
                    '//
                    '// Case 1: vn = 0
                    '//
                    '// 0 = A * x + b
                    '//
                    '// Solve for x:
                    '//
                    '// x = -inv(A) * b
                    '//
                    '//var x:b2Vec2 = - b2Mul(c->normalMass, b)
                    tMat = c.normalMass
                    Local xX :Float = - (tMat.col1.x * bX + tMat.col2.x * bY)
                    Local xY :Float = - (tMat.col1.y * bX + tMat.col2.y * bY)
                    If (xX >= 0.0 And xY >= 0.0)
                        
                        '// Resubstitute for the incremental impulse
                        '//d = x - a
                        dX = xX - aX
                        dY = xY - aY
                        '//Aply incremental impulse
                        '//P1 = d.x * normal
                        P1X = dX * normalX
                        P1Y = dX * normalY
                        '//P2 = d.y * normal
                        P2X = dY * normalX
                        P2Y = dY * normalY
                        '//vA -= invMass1 * (P1 + P2)
                        vA.x -= invMassA * (P1X + P2X)
                        vA.y -= invMassA * (P1Y + P2Y)
                        '//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2))
                        wA -= invIA * (cp1rA.x * P1Y - cp1rA.y * P1X + cp2rA.x * P2Y - cp2rA.y * P2X)
                        '//vB += invMassB * (P1 + P2)
                        vB.x += invMassB * (P1X + P2X)
                        vB.y += invMassB * (P1Y + P2Y)
                        '//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2))
                        wB += invIB * (cp1rB.x * P1Y - cp1rB.y * P1X + cp2rB.x * P2Y - cp2rB.y * P2X)
                        '// Accumulate
                        cp1.normalImpulse = xX
                        cp2.normalImpulse = xY
                        '//#if B2_DEBUG_SOLVER = 1
                        '//					// Post conditions
                        '//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA)
                        '//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y
                        '//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x
                        '//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA)
                        '//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y
                        '//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x
                        '//					// Compute normal velocity
                        '//					//vn1 = b2Dot(dv1, normal)
                        '//					vn1 = dv1X * normalX + dv1Y * normalY
                        '//					//vn2 = b2Dot(dv2, normal)
                        '//					vn2 = dv2X * normalX + dv2Y * normalY
                        '//
                        '//					//b2Settings.B2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol)
                        '//					//b2Settings.B2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol)
                        '//#endif
                        Exit
                    End
                    '//
                    '// Case 2: vn1 = 0  and x2 = 0
                    '//
                    '//   0 = a11 * x1 + a12 * 0 + b1
                    '// vn2 = a21 * x1 + a22 * 0 + b2
                    '//
                    xX = - cp1.normalMass * bX
                    xY = 0.0
                    vn1 = 0.0
                    vn2 = c.K.col1.y * xX + bY
                    If (xX >= 0.0 And vn2 >= 0.0)
                        
                        '// Resubstitute for the incremental impulse
                        '//d = x - a
                        dX = xX - aX
                        dY = xY - aY
                        '//Aply incremental impulse
                        '//P1 = d.x * normal
                        P1X = dX * normalX
                        P1Y = dX * normalY
                        '//P2 = d.y * normal
                        P2X = dY * normalX
                        P2Y = dY * normalY
                        '//vA -= invMassA * (P1 + P2)
                        vA.x -= invMassA * (P1X + P2X)
                        vA.y -= invMassA * (P1Y + P2Y)
                        '//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2))
                        wA -= invIA * (cp1rA.x * P1Y - cp1rA.y * P1X + cp2rA.x * P2Y - cp2rA.y * P2X)
                        '//vB += invMassB * (P1 + P2)
                        vB.x += invMassB * (P1X + P2X)
                        vB.y += invMassB * (P1Y + P2Y)
                        '//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2))
                        wB += invIB * (cp1rB.x * P1Y - cp1rB.y * P1X + cp2rB.x * P2Y - cp2rB.y * P2X)
                        '// Accumulate
                        cp1.normalImpulse = xX
                        cp2.normalImpulse = xY
                        '//#if B2_DEBUG_SOLVER = 1
                        '//					// Post conditions
                        '//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA)
                        '//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y
                        '//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x
                        '//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA)
                        '//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y
                        '//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x
                        '//					// Compute normal velocity
                        '//					//vn1 = b2Dot(dv1, normal)
                        '//					vn1 = dv1X * normalX + dv1Y * normalY
                        '//					//vn2 = b2Dot(dv2, normal)
                        '//					vn2 = dv2X * normalX + dv2Y * normalY
                        '//
                        '//					//b2Settings.B2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol)
                        '//					//b2Settings.B2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol)
                        '//#endif
                        Exit
                    End
                    '//
                    '// Case 3: wB = 0 and x1 = 0
                    '//
                    '// vn1 = a11 * 0 + a12 * x2 + b1
                    '//   0 = a21 * 0 + a22 * x2 + b2
                    '//
                    xX = 0.0
                    xY = -cp2.normalMass * bY
                    vn1 = c.K.col2.x * xY + bX
                    vn2 = 0.0
                    If (xY >= 0.0 And vn1 >= 0.0)
                        
                        '// Resubstitute for the incremental impulse
                        '//d = x - a
                        dX = xX - aX
                        dY = xY - aY
                        '//Aply incremental impulse
                        '//P1 = d.x * normal
                        P1X = dX * normalX
                        P1Y = dX * normalY
                        '//P2 = d.y * normal
                        P2X = dY * normalX
                        P2Y = dY * normalY
                        '//vA -= invMassA * (P1 + P2)
                        vA.x -= invMassA * (P1X + P2X)
                        vA.y -= invMassA * (P1Y + P2Y)
                        '//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2))
                        wA -= invIA * (cp1rA.x * P1Y - cp1rA.y * P1X + cp2rA.x * P2Y - cp2rA.y * P2X)
                        '//vB += invMassB * (P1 + P2)
                        vB.x += invMassB * (P1X + P2X)
                        vB.y += invMassB * (P1Y + P2Y)
                        '//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2))
                        wB += invIB * (cp1rB.x * P1Y - cp1rB.y * P1X + cp2rB.x * P2Y - cp2rB.y * P2X)
                        '// Accumulate
                        cp1.normalImpulse = xX
                        cp2.normalImpulse = xY
                        '//#if B2_DEBUG_SOLVER = 1
                        '//					// Post conditions
                        '//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA)
                        '//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y
                        '//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x
                        '//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA)
                        '//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y
                        '//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x
                        '//					// Compute normal velocity
                        '//					//vn1 = b2Dot(dv1, normal)
                        '//					vn1 = dv1X * normalX + dv1Y * normalY
                        '//					//vn2 = b2Dot(dv2, normal)
                        '//					vn2 = dv2X * normalX + dv2Y * normalY
                        '//
                        '//					//b2Settings.B2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol)
                        '//					//b2Settings.B2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol)
                        '//#endif
                        Exit
                    End
                    '//
                    '// Case 4: x1 = 0 and x2 = 0
                    '//
                    '// vn1 = b1
                    '// vn2 = b2
                    xX = 0.0
                    xY = 0.0
                    vn1 = bX
                    vn2 = bY
                    If (vn1 >= 0.0 And vn2 >= 0.0 )
                        
                        '// Resubstitute for the incremental impulse
                        '//d = x - a
                        dX = xX - aX
                        dY = xY - aY
                        '//Aply incremental impulse
                        '//P1 = d.x * normal
                        P1X = dX * normalX
                        P1Y = dX * normalY
                        '//P2 = d.y * normal
                        P2X = dY * normalX
                        P2Y = dY * normalY
                        '//vA -= invMassA * (P1 + P2)
                        vA.x -= invMassA * (P1X + P2X)
                        vA.y -= invMassA * (P1Y + P2Y)
                        '//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2))
                        wA -= invIA * (cp1rA.x * P1Y - cp1rA.y * P1X + cp2rA.x * P2Y - cp2rA.y * P2X)
                        '//vB += invMassB * (P1 + P2)
                        vB.x += invMassB * (P1X + P2X)
                        vB.y += invMassB * (P1Y + P2Y)
                        '//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2))
                        wB += invIB * (cp1rB.x * P1Y - cp1rB.y * P1X + cp2rB.x * P2Y - cp2rB.y * P2X)
                        '// Accumulate
                        cp1.normalImpulse = xX
                        cp2.normalImpulse = xY
                        '//#if B2_DEBUG_SOLVER = 1
                        '//					// Post conditions
                        '//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA)
                        '//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y
                        '//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x
                        '//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA)
                        '//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y
                        '//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x
                        '//					// Compute normal velocity
                        '//					//vn1 = b2Dot(dv1, normal)
                        '//					vn1 = dv1X * normalX + dv1Y * normalY
                        '//					//vn2 = b2Dot(dv2, normal)
                        '//					vn2 = dv2X * normalX + dv2Y * normalY
                        '//
                        '//					//b2Settings.B2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol)
                        '//					//b2Settings.B2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol)
                        '//#endif
                        Exit
                    End
                    '// No solution, give up. hit(This) sometimes, but it doesnt seem to matter.
                    Exit
                End
            End
            '// b2Vec2s in AS3 are copied by reference. The originals are
            '// references to the same things here and no(there) need to
            '// copy them back, unlike in C++ land where b2Vec2s are
            '// copied by value.
            #rem
            '/*bodyA->m_linearVelocity = vA
            'bodyB->m_linearVelocity = vB
            '*/
            #end
            bodyA.m_angularVelocity = wA
            bodyB.m_angularVelocity = wB
        End
    End
    
    
    
    Method FinalizeVelocityConstraints : void ()
        
        For Local i:Int = 0 Until m_constraintCount
            
            Local c :b2ContactConstraint = m_constraints[i]
            Local m :b2Manifold = c.manifold
            
            For Local j:Int = 0 Until c.pointCount
                Local point1 :b2ManifoldPoint = m.m_points[j]
                Local point2 :b2ContactConstraintPoint = c.points[j]
                point1.m_normalImpulse = point2.normalImpulse
                point1.m_tangentImpulse = point2.tangentImpulse
            End
        End
    End
    '//#if 1
    '// Sequential solver
    '//	 Method SolvePositionConstraints : Bool (baumgarte:Float){
    '//		var minSeparation:Float = 0.0
    '//
    '//		var tMat:b2Mat22
    '//		var tVec:b2Vec2
    '//
    '//		For Local i:Int = 0 Until m_constraintCount
    '//		{
    '//			var c:b2ContactConstraint = m_constraints[i]
    '//			var bodyA:b2Body = c.bodyA
    '//			var bodyB:b2Body = c.bodyB
    '//			var bA_sweep_c:b2Vec2 = bodyA.m_sweep.c
    '//			var bA_sweep_a:Float = bodyA.m_sweep.a
    '//			var bB_sweep_c:b2Vec2 = bodyB.m_sweep.c
    '//			var bB_sweep_a:Float = bodyB.m_sweep.a
    '//
    '//			var invMassa:Float = bodyA.m_mass * bodyA.m_invMass
    '//			var invIa:Float = bodyA.m_mass * bodyA.m_invI
    '//			var invMassb:Float = bodyB.m_mass * bodyB.m_invMass
    '//			var invIb:Float = bodyB.m_mass * bodyB.m_invI
    '//			//var normal:b2Vec2 = New b2Vec2(c.normal.x, c.normal.y)
    '//			var normalX:Float = c.normal.x
    '//			var normalY:Float = c.normal.y
    '//
    '//			// Solver normal constraints
    '//			var tCount:Int = c.pointCount
    '//			For Local j:Int = 0 Until tCount
    '//			{
    '//				var ccp:b2ContactConstraintPoint = c.points.Get( j )
    '//
    '//				//r1 = b2Mul(bodyA->m_xf.R, ccp->localAnchor1 - bodyA->GetLocalCenter())
    '//				tMat = bodyA.m_xf.R
    '//				tVec = bodyA.m_sweep.localCenter
    '//				var r1X:Float = ccp.localAnchor1.x - tVec.x
    '//				var r1Y:Float = ccp.localAnchor1.y - tVec.y
    '//				tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y)
    '//				r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y)
    '//				r1X = tX
    '//
    '//				//r2 = b2Mul(bodyB->m_xf.R, ccp->localAnchor2 - bodyB->GetLocalCenter())
    '//				tMat = bodyB.m_xf.R
    '//				tVec = bodyB.m_sweep.localCenter
    '//				var r2X:Float = ccp.localAnchor2.x - tVec.x
    '//				var r2Y:Float = ccp.localAnchor2.y - tVec.y
    '//				var tX:Float =  (tMat.col1.x * r2X + tMat.col2.x * r2Y)
    '//				r2Y = 			 (tMat.col1.y * r2X + tMat.col2.y * r2Y)
    '//				r2X = tX
    '//
    '//				//b2Vec2 p1 = bodyA->m_sweep.c + r1
    '//				var p1X:Float = b1_sweep_c.x + r1X
    '//				var p1Y:Float = b1_sweep_c.y + r1Y
    '//
    '//				//b2Vec2 p2 = bodyB->m_sweep.c + r2
    '//				var p2X:Float = b2_sweep_c.x + r2X
    '//				var p2Y:Float = b2_sweep_c.y + r2Y
    '//
    '//				//var dp:b2Vec2 = b2Math.SubtractVV(p2, p1)
    '//				var dpX:Float = p2X - p1X
    '//				var dpY:Float = p2Y - p1Y
    '//
    '//				// Approximate the current separation.
    '//				//var separation:Float = b2Math.b2Dot(dp, normal) + ccp.separation
    '//				var separation:Float = (dpX*normalX + dpY*normalY) + ccp.separation
    '//
    '//				// Track max constraint error.
    '//				minSeparation = b2Math.b2Min(minSeparation, separation)
    '//
    '//				// Prevent large corrections and allow slop.
    '//				var C:Float =  b2Math.b2Clamp(baumgarte * (separation + b2Settings.b2_linearSlop), -b2Settings.b2_maxLinearCorrection, 0.0)
    '//
    '//				// Compute normal impulse
    '//				var dImpulse:Float = -ccp.equalizedMass * C
    '//
    '//				//var P:b2Vec2 = b2Math.MulFV( dImpulse, normal )
    '//				var PX:Float = dImpulse * normalX
    '//				var PY:Float = dImpulse * normalY
    '//
    '//				//bodyA.m_position.Subtract( b2Math.MulFV( invMass1, impulse ) )
    '//				b1_sweep_c.x -= invMass1 * PX
    '//				b1_sweep_c.y -= invMass1 * PY
    '//				b1_sweep_a -= invI1 * (r1X * PY - r1Y * PX)//b2Math.b2CrossVV(r1, P)
    '//				bodyA.m_sweep.a = b1_sweep_a
    '//				bodyA.SynchronizeTransform()
    '//
    '//				//bodyB.m_position.Add( b2Math.MulFV( invMass2, P ) )
    '//				b2_sweep_c.x += invMass2 * PX
    '//				b2_sweep_c.y += invMass2 * PY
    '//				b2_sweep_a += invI2 * (r2X * PY - r2Y * PX)//b2Math.b2CrossVV(r2, P)
    '//				bodyB.m_sweep.a = b2_sweep_a
    '//				bodyB.SynchronizeTransform()
    '//			}
    '//			// Update body rotations
    '//			//bodyA.m_sweep.a = b1_sweep_a
    '//			//bodyB.m_sweep.a = b2_sweep_a
    '//		}
    '//
    '//		// We cant expect minSpeparation >= -b2_linearSlop because we dont
    '//		// push the separation above -b2_linearSlop.
    '//		return minSeparation >= -1.5 * b2Settings.b2_linearSlop
    '//	}
    '//#else
    '// Sequential solver.
    Global s_psm:b2PositionSolverManifold = New b2PositionSolverManifold()
    Method SolvePositionConstraints : Bool (baumgarte:Float)
        
        Local minSeparation :Float = 0.0
        For Local i:Int = 0 Until m_constraintCount
            
            Local c :b2ContactConstraint = m_constraints[i]
            Local bodyA :b2Body = c.bodyA
            Local bodyB :b2Body = c.bodyB
            Local invMassA :Float = bodyA.m_mass * bodyA.m_invMass
            Local invIA :Float = bodyA.m_mass * bodyA.m_invI
            Local invMassB :Float = bodyB.m_mass * bodyB.m_invMass
            Local invIB :Float = bodyB.m_mass * bodyB.m_invI
            s_psm.Initialize(c)
            Local normal :b2Vec2 = s_psm.m_normal
            
            Local ba_sweep:b2Sweep = bodyA.m_sweep
            Local ba_sweepc:b2Vec2 = ba_sweep.c
            Local ba_xf:b2Transform = bodyA.m_xf
            Local ba_xfPos:b2Vec2 = ba_xf.position
            Local ba_tMat:b2Mat22 = ba_xf.R
            Local ba_tMat_col1:b2Vec2 = ba_tMat.col1
            Local ba_tMat_col2:b2Vec2 = ba_tMat.col2
            Local ba_tVec:b2Vec2 = ba_sweep.localCenter
            
            Local bb_sweep:b2Sweep = bodyB.m_sweep
            Local bb_sweepc:b2Vec2 = bb_sweep.c
            Local bb_xf:b2Transform = bodyB.m_xf
            Local bb_xfPos:b2Vec2 = bb_xf.position
            Local bb_tMat:b2Mat22 = bb_xf.R
            Local bb_tMat_col1:b2Vec2 = bb_tMat.col1
            Local bb_tMat_col2:b2Vec2 = bb_tMat.col2
            Local bb_tVec:b2Vec2 = bb_sweep.localCenter
                    
            '// Solve normal constraints
            For Local j:Int = 0 Until c.pointCount
                
                Local ccp :b2ContactConstraintPoint = c.points[j]
                Local point :b2Vec2 = s_psm.m_points[j]
                Local separation :Float = s_psm.m_separations[j]
                Local rAX :Float = point.x - ba_sweepc.x
                Local rAY :Float = point.y - ba_sweepc.y
                Local rBX :Float = point.x - bb_sweepc.x
                Local rBY :Float = point.y - bb_sweepc.y
                '// Track max constraint error.
                If( minSeparation < separation )
                    minSeparation = minSeparation
                Else
                    minSeparation = separation
                End
                '// Prevent large corrections and allow slop.
                
                Local C:Float = baumgarte * (separation + b2Settings.b2_linearSlop)
                
                If C < -b2Settings.b2_maxLinearCorrection
                    C = -b2Settings.b2_maxLinearCorrection
                ElseIf C > 0.0
                    C = 0.0
                End
                '// Compute normal impulse
                Local impulse :Float = -ccp.equalizedMass * C
                Local PX :Float = impulse * normal.x
                Local PY :Float = impulse * normal.y
                
                '//bodyA.m_sweep.c -= invMassA * P
                ba_sweepc.x -= invMassA * PX
                ba_sweepc.y -= invMassA * PY
                '//bodyA.m_sweep.a -= invIA * b2Cross(rA, P)
                ba_sweep.a -= invIA * (rAX * PY - rAY * PX)
                
                'bodyA.SynchronizeTransform()
                '**** THE FOLLOWING IS THE ABOVE LINE MANUALLY INLINED!
                'ba_tMat.Set(ba_sweep.a)
                Local c :Float = Cosr(ba_sweep.a)
                Local s :Float = Sinr(ba_sweep.a)
                ba_tMat_col1.x = c
                ba_tMat_col2.x = -s
                ba_tMat_col1.y = s
                ba_tMat_col2.y = c
                
                ba_xfPos.x = ba_sweepc.x - (ba_tMat_col1.x * ba_tVec.x + ba_tMat_col2.x * ba_tVec.y)
                ba_xfPos.y = ba_sweepc.y - (ba_tMat_col1.y * ba_tVec.x + ba_tMat_col2.y * ba_tVec.y)
                
                '//bodyB.m_sweep.c += invMassB * P
                bb_sweepc.x += invMassB * PX
                bb_sweepc.y += invMassB * PY
                 '//bodyB.m_sweep.a += invIB * b2Cross(rB, P)
                bb_sweep.a += invIB * (rBX * PY - rBY * PX)
                
                'bodyB.SynchronizeTransform()
                '**** THE FOLLOWING IS THE ABOVE LINE MANUALLY INLINED!
                'bb_tMat.Set(bb_sweep.a)
                c = Cosr(bb_sweep.a)
                s = Sinr(bb_sweep.a)
                bb_tMat_col1.x = c
                bb_tMat_col2.x = -s
                bb_tMat_col1.y = s
                bb_tMat_col2.y = c
                
                bb_xfPos.x = bb_sweepc.x - (bb_tMat_col1.x * bb_tVec.x + bb_tMat_col2.x * bb_tVec.y)
                bb_xfPos.y = bb_sweepc.y - (bb_tMat_col1.y * bb_tVec.x + bb_tMat_col2.y * bb_tVec.y)
                
            End
        End
        '// We cant expect minSpeparation >= -b2_linearSlop because we dont
        '// push the separation above -b2_linearSlop.
        Return minSeparation > -1.5 * b2Settings.b2_linearSlop
    End
End




