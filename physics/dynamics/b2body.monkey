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
'* A rigid body.
'*/
#end

Class BreakableTester Abstract
    Method IsBreakable:Bool(f:b2Fixture) Abstract
End


Class b2Body
    Global tmpVec1:b2Vec2 = New b2Vec2()
    Global tmpVec2:b2Vec2 = New b2Vec2()
        
    Method ConnectEdges : Float (s1: b2EdgeShape, s2: b2EdgeShape, angle1:Float)
        
        Local angle2 :Float = ATan2r(s2.GetDirectionVector().y, s2.GetDirectionVector().x)
        Local coreOffset :Float = Tanr((angle2 - angle1) * 0.5)
        Local core : b2Vec2 = b2Math.MulFV(coreOffset, s2.GetDirectionVector())
        b2Math.SubtractVV(core, s2.GetNormalVector(),core)
        core = b2Math.MulFV(b2Settings.b2_toiSlop, core)
        b2Math.AddVV(core, s2.GetVertex1(),core)
        Local cornerDir:b2Vec2 = New b2Vec2()
        b2Math.AddVV(s1.GetDirectionVector(), s2.GetDirectionVector(),cornerDir)
        cornerDir.Normalize()
        Local convex : Bool = b2Math.Dot(s1.GetDirectionVector(), s2.GetNormalVector()) > 0.0
        s1.SetNextEdge(s2, core, cornerDir, convex)
        s2.SetPrevEdge(s1, core, cornerDir, convex)
        Return angle2
    End
    #rem
    '/**
    '* Creates a fixture and attach it to this body. Use this Method if you need
    '* to set some fixture parameters, like friction. Otherwise you can create the
    '* fixture directly from a shape.
    '* If the non(density)-zero, this Method automatically updates the mass of the body.
    '* Contacts are not created until the nextItem time timeStep.
    '* @param fixtureDef the fixture definition.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method CreateFixture : b2Fixture (def:b2FixtureDef)
        
        '//b2Settings.B2Assert(m_world.IsLocked() = False)
        If (m_world.IsLocked() = True)
            
            Return null
        End
        '// TODO: Decide on a better place to initialize edgeShapes. (b2Shape::Create() cant
        '//       return more than one shape to add to parent body... maybe it should add
        '//       shapes directly to the body instead of returning them?)
        #rem
        '/*
        'if (def.type = b2Shape.e_edgeShape)
        '
        'Local edgeDef : b2EdgeChainDef = b2EdgeChainDef(def)
        'Local v1 : b2Vec2
        'Local v2 : b2Vec2
        'Local i : Int
        'if (edgeDef.isALoop)
        '
        'v1 = edgeDef.vertices.Get(edgeDef.vertexCount-1)
        'i = 0
        'Else
        '
        '
        'v1 = edgeDef.vertices.Get(0)
        'i = 1
        'End
        'Local s0 : b2EdgeShape = null
        'Local s1 : b2EdgeShape = null
        'Local s2 : b2EdgeShape = null
        'Local angle :Float = 0.0
        'i += 1
        'for (
        'i < edgeDef.vertexCount
        'i)
        '
        'v2 = edgeDef.vertices.Get(i)
        '//void* mem = m_world->m_blockAllocator.Allocate(sizeof(b2EdgeShape))
        's2 = New b2EdgeShape(v1, v2, def)
        's2.m_next = m_shapeList
        'm_shapeList = s2
        'm_shapeCount += 1
        's2.m_body = Self
        's2.CreateProxy(m_world.m_broadPhase, m_xf)
        's2.UpdateSweepRadius(m_sweep.localCenter)
        'if (s1 = null)
        '
        's0 = s2
        'angle = ATan2r(s2.GetDirectionVector().y, s2.GetDirectionVector().x)
        'Else
        '
        '
        'angle = ConnectEdges(s1, s2, angle)
        'End
        '
        's1 = s2
        'v1 = v2
        'End
        '
        'if (edgeDef.isALoop)
        'ConnectEdges(s1, s0, angle)
        'End
        'return s0
        'End
        '*/
        '
        '
        #end
        Local fixture :b2Fixture = New b2Fixture()
        fixture.Create(Self, m_xf, def)
        If ( m_flags & e_activeFlag )
            
            Local broadPhase :IBroadPhase = m_world.m_contactManager.m_broadPhase
            fixture.CreateProxy(broadPhase, m_xf)
        End
        fixture.m_next = m_fixtureList
        m_fixtureList = fixture
        m_fixtureCount += 1
        
        fixture.m_body = Self
        '// Adjust mass properties if needed
        If (fixture.m_density > 0.0)
            
            ResetMassData()
        End
        '// Let the world know we have a New fixture. This will cause New contacts to be created
        '// at the beginning of the nextItem time timeStep.
        m_world.m_flags |= b2World.e_newFixture
        Return fixture
    End
    #rem
    '/**
    '* Creates a fixture from a shape and attach it to this body.
    '* a(This) convenience Method. Use b2FixtureDef if you need to set parameters
    '* like friction, restitution, user data, or filtering.
    '* This Method automatically updates the mass of the body.
    '* @param shape the shape to be cloned.
    '* @param density the shape density (set to zero for static bodies).
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method CreateFixture2 : b2Fixture (shape:b2Shape, density:Float=0.0)
        
        Local def :b2FixtureDef = New b2FixtureDef()
        def.shape = shape
        def.density = density
        Return CreateFixture(def)
    End
    #rem
    '/**
    '* Destroy a fixture. This removes the fixture from the broad-phase and
    '* destroys all contacts associated with this fixture. This will
    '* automatically adjust the mass of the body if the and(body) the
    '* fixture has positive density.
    '* All fixtures attached to a body are implicitly destroyed when the destroyed(body).
    '* @param fixture the fixture to be removed.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method DestroyFixture : void (fixture:b2Fixture)
        
        '//b2Settings.B2Assert(m_world.IsLocked() = False)
        If (m_world.IsLocked() = True)
            
            Return
        End
        '//b2Settings.B2Assert(m_fixtureCount > 0)
        '//b2Fixture** node = &m_fixtureList
        Local node :b2Fixture = m_fixtureList
        Local ppF :b2Fixture = null
        '// Fix pointer-pointer stuff
        Local found :Bool = False
        While (node <> null)
            
            If (node = fixture)
                
                If (ppF)
                    ppF.m_next = fixture.m_next
                Else
                    
                    m_fixtureList = fixture.m_next
                End
                '//node = fixture.m_next
                found = True
                Exit
            End
            ppF = node
            node = node.m_next
        End
        '// You tried to remove a shape not(that) attached to this body.
        '//b2Settings.B2Assert(found)
        '// Destroy any contacts associated with the fixture.
        Local edge :b2ContactEdge = m_contactList
        While (edge)
            
            Local c :b2Contact = edge.contact
            edge = edge.nextItem
            Local fixtureA :b2Fixture = c.GetFixtureA()
            Local fixtureB :b2Fixture = c.GetFixtureB()
            If (fixture = fixtureA Or fixture = fixtureB)
                
                '// This destros the contact and removes it from
                '// this bodys contact list
                m_world.m_contactManager.Destroy(c)
            End
        End
        If ( m_flags & e_activeFlag )
            
            Local broadPhase :IBroadPhase = m_world.m_contactManager.m_broadPhase
            fixture.DestroyProxy(broadPhase)
        Else
            
            
            '//b2Assert(fixture->m_proxyId = b2BroadPhase::e_nullProxy)
        End
        fixture.Destroy()
        fixture.m_body = null
        fixture.m_next = null
        m_fixtureCount -= 1
        
        '// Reset the mass data.
        ResetMassData()
    End
    #rem
    '/**
    '* Set the position of the bodys origin and rotation (radians).
    '* This  Exits any contacts and wakes the other bodies.
    '* @param position the New world position of the bodys origin (not necessarily
    '* the center of mass).
    '* @param angle the New world rotation angle of the body in radians.
    '*/
    #end
    Method SetPositionAndAngle : void (position:b2Vec2, angle:Float)
        Local f :b2Fixture
        '//b2Settings.B2Assert(m_world.IsLocked() = False)
        If (m_world.IsLocked() = True)
            
            Return
        End
        m_xf.R.Set(angle)
        m_xf.position.SetV(position)
        '//m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter)
        '//b2MulMV(m_xf.R, m_sweep.localCenter)
        Local tMat :b2Mat22 = m_xf.R
        Local tVec :b2Vec2 = m_sweep.localCenter
        '// (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        m_sweep.c.x = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        '// (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        m_sweep.c.y = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//return T.position + b2Mul(T.R, v)
        m_sweep.c.x += m_xf.position.x
        m_sweep.c.y += m_xf.position.y
        '//m_sweep.c0 = m_sweep.c
        m_sweep.c0.SetV(m_sweep.c)
        m_sweep.a0 = angle
        m_sweep.a = angle
        Local broadPhase :IBroadPhase = m_world.m_contactManager.m_broadPhase
        f = m_fixtureList
        While( f<>null )
            f.Synchronize(broadPhase, m_xf, m_xf)
            f = f.m_next
        End
        
        m_world.m_contactManager.FindNewContacts()
    End
    #rem
    '/**
    '* Set the position of the bodys origin and rotation (radians).
    '* This  Exits any contacts and wakes the other bodies.
    '* Note less(this) efficient than the other overload - you should use that
    '* if the available(angle).
    '* @param xf the transform of position and angle to set the bdoy to.
    '*/
    #end
    Method SetTransform : void (xf:b2Transform)
        
        SetPositionAndAngle(xf.position, xf.GetAngle())
    End
    #rem
    '/**
    '* Get the body transform for the bodys origin.
    '* @return the world transform of the bodys origin.
    '*/
    #end
    Method GetTransform : b2Transform ()
        
        Return m_xf
    End
    #rem
    '/**
    '* Get the world body origin position.
    '* @return the world position of the bodys origin.
    '*/
    #end
    Method GetPosition : b2Vec2 ()
        
        Return m_xf.position
    End
    #rem
    '/**
    '* Setthe world body origin position.
    '* @param position the New position of the body
    '*/
    #end
    Method SetPosition : void (position:b2Vec2)
        
        SetPositionAndAngle(position, GetAngle())
    End
    #rem
    '/**
    '* Get the angle in radians.
    '* @return the current world rotation angle in radians.
    '*/
    #end
    Method GetAngle : Float ()
        
        Return m_sweep.a
    End
    #rem
    '/**
    '* Set the world body angle
    '* @param angle the New angle of the body.
    '*/
    #end
    Method SetAngle : void (angle:Float)
        
        SetPositionAndAngle(GetPosition(), angle)
    End
    #rem
    '/**
    '* Get the world position of the center of mass.
    '*/
    #end
    Method GetWorldCenter : b2Vec2 ()
        
        Return m_sweep.c
    End
    #rem
    '/**
    '* Get the local position of the center of mass.
    '*/
    #end
    Method GetLocalCenter : b2Vec2 ()
        
        Return m_sweep.localCenter
    End
    #rem
    '/**
    '* Set the linear velocity of the center of mass.
    '* @param v the New linear velocity of the center of mass.
    '*/
    #end
    Method SetLinearVelocity : void (v:b2Vec2)
        
        If ( m_type = b2_staticBody )
            
            Return
        End
        
        m_linearVelocity.SetV(v)
    End
    #rem
    '/**
    '* Get the linear velocity of the center of mass.
    '* @return the linear velocity of the center of mass.
    '*/
    #end
    Method GetLinearVelocity : b2Vec2 ()
        
        Return m_linearVelocity
    End
    #rem
    '/**
    '* Set the angular velocity.
    '* @param omega the New angular velocity in radians/second.
    '*/
    #end
    Method SetAngularVelocity : void (omega:Float)
        
        If ( m_type = b2_staticBody )
            
            Return
        End
        
        m_angularVelocity = omega
    End
    #rem
    '/**
    '* Get the angular velocity.
    '* @return the angular velocity in radians/second.
    '*/
    #end
    Method GetAngularVelocity : Float ()
        
        Return m_angularVelocity
    End
    #rem
    '/**
    '* Get the definition containing the body properties.
    '* @asonly
    '*/
    #end
    Method GetDefinition : b2BodyDef ()
        
        Local bd :b2BodyDef = New b2BodyDef()
        bd.type = GetType()
        bd.allowSleep = (m_flags & e_allowSleepFlag) = e_allowSleepFlag
        bd.angle = GetAngle()
        bd.angularDamping = m_angularDamping
        bd.angularVelocity = m_angularVelocity
        bd.fixedRotation = (m_flags & e_fixedRotationFlag) = e_fixedRotationFlag
        bd.bullet = (m_flags & e_bulletFlag) = e_bulletFlag
        bd.awake = (m_flags & e_awakeFlag) = e_awakeFlag
        bd.linearDamping = m_linearDamping
        bd.linearVelocity.SetV(GetLinearVelocity())
        bd.position = GetPosition()
        bd.userData = GetUserData()
        Return bd
    End
    #rem
    '/**
    '* Apply a force at a world point. If the not(force)
    '* applied at the center of mass, it will generate a torque and
    '* affect the angular velocity. This wakes up the body.
    '* @param force the world force vector, usually in Newtons (N).
    '* @param point the world position of the point of application.
    '*/
    #end
    Method ApplyForce : void (force:b2Vec2, point:b2Vec2)
        
        If (m_type <> b2_Body)
            
            Return
        End
        If (IsAwake() = False)
            
            SetAwake(True)
        End
        '//m_force += force
        m_force.x += force.x
        m_force.y += force.y
        '//m_torque += b2Cross(point - m_sweep.c, force)
        m_torque += ((point.x - m_sweep.c.x) * force.y - (point.y - m_sweep.c.y) * force.x)
    End
    #rem
    '/**
    '* Apply a torque. This affects the angular velocity
    '* without affecting the linear velocity of the center of mass.
    '* This wakes up the body.
    '* @param torque about the z-axis (out of the screen), usually in N-m.
    '*/
    #end
    Method ApplyTorque : void (torque:Float)
        
        If (m_type <> b2_Body)
            
            Return
        End
        If (IsAwake() = False)
            
            SetAwake(True)
        End
        
        m_torque += torque
    End
    #rem
    '/**
    '* Apply an impulse at a point. This immediately modifies the velocity.
    '* It also modifies the angular velocity if the point of application
    '* is not at the center of mass. This wakes up the body.
    '* @param impulse the world impulse vector, usually in N-seconds or kg-m/s.
    '* @param point the world position of the point of application.
    '*/
    #end
    Method ApplyImpulse : void (impulse:b2Vec2, point:b2Vec2)
        
        If (m_type <> b2_Body)
            
            Return
        End
        If (IsAwake() = False)
            
            SetAwake(True)
        End
        
        '//m_linearVelocity += m_invMass * impulse
        m_linearVelocity.x += m_invMass * impulse.x
        m_linearVelocity.y += m_invMass * impulse.y
        '//m_angularVelocity += m_invI * b2Cross(point - m_sweep.c, impulse)
        m_angularVelocity += m_invI * ((point.x - m_sweep.c.x) * impulse.y - (point.y - m_sweep.c.y) * impulse.x)
    End
    #rem
    '/**
    '* Splits a body into two, preserving  properties
    '* @param	callback Called once per fixture, return True to move this fixture to the New body
    '* <code>Method Callback:Void(fixture:b2Fixture):Bool</code>
    '* @return The newly created bodies
    '* @asonly
    '*/
    #end
    Method Split : b2Body (breakableTester:BreakableTester)
        
        Local linearVelocity :b2Vec2 = GetLinearVelocity().Copy()
        
        '//Reset mass will alter this
        Local angularVelocity :Float = GetAngularVelocity()
        Local center :b2Vec2 = GetWorldCenter()
        Local body1 :b2Body = Self
        Local body2 :b2Body = m_world.CreateBody(GetDefinition())
        Local prevItem :b2Fixture
        Local f:b2Fixture = body1.m_fixtureList
        While ( f <> Null )
            
            If (breakableTester.IsBreakable(f))
                
                Local nextItem :b2Fixture = f.m_next
                '// Remove fixture
                If (prevItem)
                    
                    prevItem.m_next = nextItem
                Else
                    
                    
                    body1.m_fixtureList = nextItem
                End
                
                body1.m_fixtureCount -= 1
                
                '// Add fixture
                f.m_next = body2.m_fixtureList
                body2.m_fixtureList = f
                body2.m_fixtureCount += 1
                
                f.m_body = body2
                f = nextItem
            Else
                
                
                prevItem = f
                f = f.m_next
            End
        End
        body1.ResetMassData()
        body2.ResetMassData()
        '// Compute consistent velocites for New bodies based on cached velocity
        Local center1 :b2Vec2 = body1.GetWorldCenter()
        Local center2 :b2Vec2 = body2.GetWorldCenter()
        
        b2Math.SubtractVV(center1, center, tmpVec1)
        b2Math.CrossFV(angularVelocity,tmpVec1,tmpVec2)
        b2Math.AddVV(linearVelocity,tmpVec2,tmpVec1)
        body1.SetLinearVelocity(tmpVec1)
        
        b2Math.SubtractVV(center2, center, tmpVec1)
        b2Math.CrossFV(angularVelocity,tmpVec1,tmpVec2)
        b2Math.AddVV(linearVelocity,tmpVec2,tmpVec1)
        body2.SetLinearVelocity(tmpVec1)
       
        body1.SetAngularVelocity(angularVelocity)
        body2.SetAngularVelocity(angularVelocity)
        body1.SynchronizeFixtures()
        body2.SynchronizeFixtures()
        Return body2
    End
    #rem
    '/**
    '* Merges another body into Self. Only fixtures, mass and velocity are effected,
    '* Other properties are ignored
    '* @asonly
    '*/
    #end
    Method Merge : void (other:b2Body)
        
        Local f :b2Fixture = other.m_fixtureList
        
        While ( f <> Null )
            
            Local nextItem :b2Fixture = f.m_next
            '// Remove fixture
            other.m_fixtureCount -= 1
            
            '// Add fixture
            f.m_next = m_fixtureList
            m_fixtureList = f
            m_fixtureCount += 1
            
            f.m_body = other
            f = nextItem
        End
        
        Self.m_fixtureCount = 0
        '// Recalculate velocities
        Local body1 :b2Body = Self
        Local body2 :b2Body = other
        '// Compute consistent velocites for New bodies based on cached velocity
        Local center1 :b2Vec2 = body1.GetWorldCenter()
        Local center2 :b2Vec2 = body2.GetWorldCenter()
        Local velocity1 :b2Vec2 = body1.GetLinearVelocity().Copy()
        Local velocity2 :b2Vec2 = body2.GetLinearVelocity().Copy()
        Local angular1 :Float = body1.GetAngularVelocity()
        Local angular :Float = body2.GetAngularVelocity()
        '// TODO
        body1.ResetMassData()
        SynchronizeFixtures()
    End
    #rem
    '/**
    '* Get the total mass of the body.
    '* @return the mass, usually in kilograms (kg).
    '*/
    #end
    Method GetMass : Float ()
        
        Return m_mass
    End
    #rem
    '/**
    '* Get the central rotational inertia of the body.
    '* @return the rotational inertia, usually in kg-m^2.0
    '*/
    #end
    Method GetInertia : Float ()
        
        Return m_I
    End
    #rem
    '/**
    '* Get the mass data of the body. The rotational relative(inertial) to the center of mass.
    '*/
    #end
    Method GetMassData : void (data:b2MassData)
        
        data.mass = m_mass
        data.I = m_I
        data.center.SetV(m_sweep.localCenter)
    End
    #rem
    '/**
    '* Set the mass properties to  the mass properties of the fixtures
    '* Note that this changes the center of mass position.
    '* Note that creating or destroying fixtures can also alter the mass.
    '* This Method has no effect if the body isnt .
    '* @warning The supplied rotational inertia should be relative to the center of mass
    '* @param	data the mass properties.
    '*/
    #end
    Method SetMassData : void (massData:b2MassData)
        
#If CONFIG = "debug"
        b2Settings.B2Assert(m_world.IsLocked() = False)
#End
        If (m_world.IsLocked() = True)
            
            Return
        End
        If (m_type <> b2_Body)
            
            Return
        End
        m_invMass = 0.0
        m_I = 0.0
        m_invI = 0.0
        m_mass = massData.mass
        '// Compute the center of mass.
        If (m_mass <= 0.0)
            
            m_mass = 1.0
        End
        
        m_invMass = 1.0 / m_mass
        If (massData.I > 0.0 And (m_flags & e_fixedRotationFlag) = 0)
            
            '// Center the inertia about the center of mass
            m_I = massData.I - m_mass * (massData.center.x * massData.center.x + massData.center.y * massData.center.y)
            m_invI = 1.0 / m_I
        End
        '// Move center of mass
        Local oldCenter:b2Vec2 = m_sweep.c.Copy()
        m_sweep.localCenter.SetV(massData.center)
        b2Math.MulX(m_xf, m_sweep.localCenter,tmpVec1)
        m_sweep.c0.SetV(tmpVec1)
        m_sweep.c.SetV(m_sweep.c0)
        '// Update center of mass velocity
        '//m_linearVelocity += b2Cross(m_angularVelocity, m_sweep.c - oldCenter)
        m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - oldCenter.y)
        m_linearVelocity.y += m_angularVelocity * +(m_sweep.c.x - oldCenter.x)
    End
    #rem
    '/**
    '* This resets the mass properties to the sum of the mass properties of the fixtures.
    '* This normally does not need to be called unless you called SetMassData to
    '* the mass and later you want to reset the mass.
    '*/
    #end
    Method ResetMassData : void ()
        
        '// Compute mass data from shapes. Each shape has its own density
        m_mass = 0.0
        m_invMass = 0.0
        m_I = 0.0
        m_invI = 0.0
        m_sweep.localCenter.SetZero()
        '// Static and kinematic bodies have zero mass.
        If (m_type = b2_staticBody Or m_type = b2_kinematicBody)
            Return
        End
        
        '//b2Assert(m_type = b2_Body)
        '// Accumulate mass over all fixtures.
        Local center :b2Vec2 = b2Vec2.Make(0, 0)
        Local f:b2Fixture = m_fixtureList
        While ( f <> Null )
            If (f.m_density = 0.0)
                f = f.m_next
                Continue
            End
            Local massData :b2MassData = f.GetMassData()
            m_mass += massData.mass
            center.x += massData.center.x * massData.mass
            center.y += massData.center.y * massData.mass
            m_I += massData.I
            f = f.m_next
        End
        
        '// Compute the center of mass.
        If (m_mass > 0.0)
            m_invMass = 1.0 / m_mass
            center.x *= m_invMass
            center.y *= m_invMass
        Else
            '// Force all  bodies to have a positive mass.
            m_mass = 1.0
            m_invMass = 1.0
        End
        
        If (m_I > 0.0 And (m_flags & e_fixedRotationFlag) = 0)
            '// Center the inertia about the center of mass
            m_I -= m_mass * (center.x * center.x + center.y * center.y)
            m_I *= m_inertiaScale
#If CONFIG = "debug"
            b2Settings.B2Assert(m_I > 0)
#End
            m_invI = 1.0 / m_I
        Else
            m_I = 0.0
            m_invI = 0.0
        End
        
        '// Move center of mass
        Local oldCenter :b2Vec2 = m_sweep.c.Copy()
        m_sweep.localCenter.SetV(center)
        b2Math.MulX(m_xf, m_sweep.localCenter,m_sweep.c0)
        m_sweep.c.SetV(m_sweep.c0)
        '// Update center of mass velocity
        '//m_linearVelocity += b2Cross(m_angularVelocity, m_sweep.c - oldCenter)
        m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - oldCenter.y)
        m_linearVelocity.y += m_angularVelocity * +(m_sweep.c.x - oldCenter.x)
    End
    
    #rem
    '/**
    '* Get the world coordinates of a point given the local coordinates.
    '* @param localPoint a point on the body measured relative the the bodys origin.
    '* @return the same point expressed in world coordinates.
    '*/
    #end
    Method GetWorldPoint:Void (localPoint:b2Vec2, out:b2Vec2)
        Local A :b2Mat22 = m_xf.R
        Local tmp:Float = localPoint.x
        out.Set(A.col1.x * tmp + A.col2.x * localPoint.y,
            A.col1.y * tmp + A.col2.y * localPoint.y)
        out.x += m_xf.position.x
        out.y += m_xf.position.y
    End
    
    #rem
    '/**
    '* Get the world coordinates of a vector given the local coordinates.
    '* @param localVector a vector fixed in the body.
    '* @return the same vector expressed in world coordinates.
    '*/
    #end
    Method GetWorldVector:Void (localVector:b2Vec2, out:b2Vec2)
        b2Math.MulMV(m_xf.R, localVector, out)
    End
    
    #rem
    '/**
    '* Gets a local point relative to the bodys origin given a world point.
    '* @param a point in world coordinates.
    '* @return the corresponding local point relative to the bodys origin.
    '*/
    #end
    Method GetLocalPoint:Void (worldPoint:b2Vec2, out:b2Vec2)
        b2Math.MulXT(m_xf, worldPoint, out)
    End
    
    Method GetLocalPointR:b2Vec2 (worldPoint:b2Vec2)  'MikeHart 20151030
        Local out:b2Vec2  'MikeHart 20151030
        b2Math.MulXT(m_xf, worldPoint, out)  'MikeHart 20151030
        Return out  'MikeHart 20151030
    End
    
    #rem
    '/**
    '* Gets a local vector given a world vector.
    '* @param a vector in world coordinates.
    '* @return the corresponding local vector.
    '*/
    #end
    Method GetLocalVector:Void (worldVector:b2Vec2, out:b2Vec2)
        b2Math.MulTMV(m_xf.R, worldVector, out)
    End
    
    #rem
    '/**
    '* Get the world linear velocity of a world point attached to this body.
    '* @param a point in world coordinates.
    '* @return the world velocity of a point.
    '*/
    #end
    Method GetLinearVelocityFromWorldPoint:Void (worldPoint:b2Vec2, out:b2Vec2)
        '//return          m_linearVelocity   + b2Cross(m_angularVelocity,   worldPoint   - m_sweep.c)
        out.Set(m_linearVelocity.x -         m_angularVelocity * (worldPoint.y - m_sweep.c.y),
        m_linearVelocity.y +         m_angularVelocity * (worldPoint.x - m_sweep.c.x))
    End
    #rem
    '/**
    '* Get the world velocity of a local point.
    '* @param a point in local coordinates.
    '* @return the world velocity of a point.
    '*/
    #end
    Method GetLinearVelocityFromLocalPoint : b2Vec2 (localPoint:b2Vec2)
        
        '//return GetLinearVelocityFromWorldPoint(GetWorldPoint(localPoint))
        Local A :b2Mat22 = m_xf.R
        Local worldPoint :b2Vec2 = New b2Vec2(A.col1.x * localPoint.x + A.col2.x * localPoint.y,
        A.col1.y * localPoint.x + A.col2.y * localPoint.y)
        worldPoint.x += m_xf.position.x
        worldPoint.y += m_xf.position.y
        Return New b2Vec2(m_linearVelocity.x -         m_angularVelocity * (worldPoint.y - m_sweep.c.y),
        m_linearVelocity.y +         m_angularVelocity * (worldPoint.x - m_sweep.c.x))
    End
    #rem
    '/**
    '* Get the linear damping of the body.
    '*/
    #end
    Method GetLinearDamping : Float ()
        
        Return m_linearDamping
    End
    #rem
    '/**
    '* Set the linear damping of the body.
    '*/
    #end
    Method SetLinearDamping : void (linearDamping:Float)
        
        m_linearDamping = linearDamping
    End
    #rem
    '/**
    '* Get the angular damping of the body
    '*/
    #end
    Method GetAngularDamping : Float ()
        
        Return m_angularDamping
    End
    #rem
    '/**
    '* Set the angular damping of the body.
    '*/
    #end
    Method SetAngularDamping : void (angularDamping:Float)
        
        m_angularDamping = angularDamping
    End
    #rem
    '/**
    '* Set the type of this body. This may alter the mass and velocity
    '* @param	type - enum a(stored) static member of b2Body
    '*/
    #end
    Method SetType : void ( type:Int )
        
        If ( m_type = type )
            
            Return
        End
        m_type = type
        ResetMassData()
        If ( m_type = b2_staticBody )
            
            m_linearVelocity.SetZero()
            m_angularVelocity = 0.0
        End
        SetAwake(True)
        m_force.SetZero()
        m_torque = 0.0
        '// Since the body type changed, we need to flag contacts for filtering.
        Local ce:b2ContactEdge = m_contactList
        While ( ce <> Null )
            ce.contact.FlagForFiltering()
            ce = ce.nextItem
        End
    End
    #rem
    '/**
    '* Get the type of this body.
    '* @return type a(enum) uint
    '*/
    #end
    Method GetType : Int ()
        
        Return m_type
    End
    #rem
    '/**
    '* Should this body be treated like a bullet for continuous collision detection?
    '*/
    #end
    Method SetBullet : void (flag:Bool)
        
        If (flag)
            
            m_flags |= e_bulletFlag
        Else
            
            
            m_flags &= ~e_bulletFlag
        End
    End
    #rem
    '/**
    '* Is this body treated like a bullet for continuous collision detection?
    '*/
    #end
    Method IsBullet : Bool ()
        
        Return (m_flags & e_bulletFlag) = e_bulletFlag
    End
    #rem
    '/**
    '* Is this body allowed to sleep
    '* @param	flag
    '*/
    #end
    Method SetSleepingAllowed : void (flag:Bool)
        
        If (flag)
            
            m_flags |= e_allowSleepFlag
        Else
            
            
            m_flags &= ~e_allowSleepFlag
            SetAwake(True)
        End
    End
    #rem
    '/**
    '* Set the sleep state of the body. A sleeping body has vety low CPU cost.
    '* @param	flag - set to True to put body to sleep, False to wake it
    '*/
    #end
    Method SetAwake : void (flag:Bool)
        
        If (flag)
            
            m_flags |= e_awakeFlag
            m_sleepTime = 0.0
        Else
            
            
            m_flags &= ~e_awakeFlag
            m_sleepTime = 0.0
            m_linearVelocity.SetZero()
            m_angularVelocity = 0.0
            m_force.SetZero()
            m_torque = 0.0
        End
    End
    #rem
    '/**
    '* Get the sleeping state of this body.
    '* @return True if sleeping(body)
    '*/
    #end
    Method IsAwake : Bool ()
        
        Return (m_flags & e_awakeFlag) = e_awakeFlag
    End
    #rem
    '/**
    '* Set this body to have fixed rotation. This causes the mass to be reset.
    '* @param	fixed - True means no rotation
    '*/
    #end
    Method SetFixedRotation : void (fixed:Bool)
        
        If(fixed)
            
            m_flags |= e_fixedRotationFlag
        Else
            
            
            m_flags &= ~e_fixedRotationFlag
        End
        ResetMassData()
    End
    #rem
    '/**
    '* Does this body have fixed rotation?
    '* @return True means fixed rotation
    '*/
    #end
    Method IsFixedRotation : Bool ()
        
        Return (m_flags & e_fixedRotationFlag)=e_fixedRotationFlag
    End
    #rem
    '/** Set the active state of the body. An inactive not(body)
    '* simulated and cannot be collided with or woken up.
    '* If you pass a flag of True, all fixtures will be added to the
    '* broad-phase.
    '* If you pass a flag of False, all fixtures will be removed from
    '* the broad-phase and all contacts will be destroyed.
    '* Fixtures and joints are otherwise unaffected. You may continue
    '* to create/destroy fixtures and joints on inactive bodies.
    '* Fixtures on an inactive body are implicitly inactive and will
    '* not participate in collisions, ray-casts, or queries.
    '* Joints connected to an inactive body are implicitly inactive.
    '* An inactive still(body) owned by a b2World object and remains
    '* in the body list.
    '*/
    #end
    Method SetActive : void ( flag:Bool )
        
        If (flag = IsActive())
            
            Return
        End
        Local broadPhase :IBroadPhase
        Local f :b2Fixture
        If (flag)
            
            m_flags |= e_activeFlag
            '// Create all proxies.
            broadPhase = m_world.m_contactManager.m_broadPhase
            f = m_fixtureList
            While ( f <> Null )
                f.CreateProxy(broadPhase, m_xf)
                f = f.m_next
            End
            
            '// Contacts are created the nextItem time timeStep.
        Else
            
            
            m_flags &= ~e_activeFlag
            '// Destroy all proxies.
            broadPhase = m_world.m_contactManager.m_broadPhase
            f = m_fixtureList
            While ( f <> Null )
                f.DestroyProxy(broadPhase)
                f = f.m_next
            End
            '// Destroy the attached contacts.
            Local ce :b2ContactEdge = m_contactList
            While (ce)
                
                Local ce0 :b2ContactEdge = ce
                ce = ce.nextItem
                m_world.m_contactManager.Destroy(ce0.contact)
            End
            
            m_contactList = null
        End
    End
    #rem
    '/**
    '* Get the active state of the body.
    '* @return True if active.
    '*/
    #end
    Method IsActive : Bool ()
        
        Return (m_flags & e_activeFlag) = e_activeFlag
    End
    #rem
    '/**
    '* Is this body allowed to sleep?
    '*/
    #end
    Method IsSleepingAllowed : Bool ()
        
        Return(m_flags & e_allowSleepFlag) = e_allowSleepFlag
    End
    #rem
    '/**
    '* Get the list of all fixtures attached to this body.
    '*/
    #end
    Method GetFixtureList : b2Fixture ()
        
        Return m_fixtureList
    End
    #rem
    '/**
    '* Get the list of all joints attached to this body.
    '*/
    #end
    Method GetJointList : b2JointEdge ()
        
        Return m_jointList
    End
    #rem
    '/**
    '* Get the list of all controllers attached to this body.
    '*/
    #end
    Method GetControllerList : b2ControllerEdge ()
        
        Return m_controllerList
    End
    #rem
    '/**
    '* Get a list of all contacts attached to this body.
    '*/
    #end
    Method GetContactList : b2ContactEdge ()
        
        Return m_contactList
    End
    #rem
    '/**
    '* Get the nextItem body in the worlds body list.
    '*/
    #end
    Method GetNext : b2Body ()
        
        Return m_next
    End
    #rem
    '/**
    '* Get the user data pointer that was provided in the body definition.
    '*/
    #end
    Method GetUserData : Object ()
        
        Return m_userData
    End
    #rem
    '/**
    '* Set the user data. Use this to store your application specific data.
    '*/
    #end
    Method SetUserData : void (data: Object)
        
        m_userData = data
    End
    #rem
    '/**
    '* Get the parent world of this body.
    '*/
    #end
    Method GetWorld : b2World ()
        
        Return m_world
    End
    '//--------------- Internals Below -------------------
    '// Constructor
    #rem
    '/**
    '* @
    '*/
    #end
    Method New(bd:b2BodyDef, world:b2World)
        
        '//b2Settings.B2Assert(world.IsLocked() = False)
        '//b2Settings.B2Assert(bd.position.IsValid())
        '//b2Settings.B2Assert(bd.linearVelocity.IsValid())
        '//b2Settings.B2Assert(b2Math.b2IsValid(bd.angle))
        '//b2Settings.B2Assert(b2Math.b2IsValid(bd.angularVelocity))
        '//b2Settings.B2Assert(b2Math.b2IsValid(bd.inertiaScale) And bd.inertiaScale >= 0.0)
        '//b2Settings.B2Assert(b2Math.b2IsValid(bd.angularDamping) And bd.angularDamping >= 0.0)
        '//b2Settings.B2Assert(b2Math.b2IsValid(bd.linearDamping) And bd.linearDamping >= 0.0)
        m_flags = 0
        If (bd.bullet )
            
            m_flags |= e_bulletFlag
        End
        
        If (bd.fixedRotation)
            
            m_flags |= e_fixedRotationFlag
        End
        
        If (bd.allowSleep)
            
            m_flags |= e_allowSleepFlag
        End
        
        If (bd.awake)
            
            m_flags |= e_awakeFlag
        End
        
        If (bd.active)
            
            m_flags |= e_activeFlag
        End
        m_world = world
        m_xf.position.SetV(bd.position)
        m_xf.R.Set(bd.angle)
        m_sweep.localCenter.SetZero()
        m_sweep.t0 = 1.0
        m_sweep.a0 = bd.angle
        m_sweep.a = bd.angle
        '//m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter)
        '//b2MulMV(m_xf.R, m_sweep.localCenter)
        Local tMat :b2Mat22 = m_xf.R
        Local tVec :b2Vec2 = m_sweep.localCenter
        '// (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        m_sweep.c.x = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        '// (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        m_sweep.c.y = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        '//return T.position + b2Mul(T.R, v)
        m_sweep.c.x += m_xf.position.x
        m_sweep.c.y += m_xf.position.y
        '//m_sweep.c0 = m_sweep.c
        m_sweep.c0.SetV(m_sweep.c)
        m_jointList = null
        m_controllerList = null
        m_contactList = null
        m_controllerCount = 0
        m_prev = null
        m_next = null
        m_linearVelocity.SetV(bd.linearVelocity)
        m_angularVelocity = bd.angularVelocity
        m_linearDamping = bd.linearDamping
        m_angularDamping = bd.angularDamping
        m_force.Set(0.0, 0.0)
        m_torque = 0.0
        m_sleepTime = 0.0
        m_type = bd.type
        If (m_type = b2_Body)
            
            m_mass = 1.0
            m_invMass = 1.0
        Else
            
            
            m_mass = 0.0
            m_invMass = 0.0
        End
        m_I = 0.0
        m_invI = 0.0
        m_inertiaScale = bd.inertiaScale
        m_userData = bd.userData
        m_fixtureList = null
        m_fixtureCount = 0
    End
    '// Destructor
    '//~b2Body()
    '//
    Global s_xf1:b2Transform = New b2Transform()
    '//
    Method SynchronizeFixtures : void ()
        Local xf1 :b2Transform = s_xf1
        xf1.R.Set(m_sweep.a0)
        '//xf1.position = m_sweep.c0 - b2Mul(xf1.R, m_sweep.localCenter)
        Local tMat :b2Mat22 = xf1.R
        Local tVec :b2Vec2 = m_sweep.localCenter
        xf1.position.x = m_sweep.c0.x - (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        xf1.position.y = m_sweep.c0.y - (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
        Local f :b2Fixture
        Local broadPhase :IBroadPhase = m_world.m_contactManager.m_broadPhase
        f = m_fixtureList
        While ( f <> Null )
            f.Synchronize(broadPhase, xf1, m_xf)
            f = f.m_next
        End
    End
    
    Method SynchronizeTransform : void ()
        '//m_xf.position = m_sweep.c - b2Mul(m_xf.R, m_sweep.localCenter)
        Local tMat :b2Mat22 = m_xf.R
        tMat.Set(m_sweep.a)
        
        Local tVec :b2Vec2 = m_sweep.localCenter
        m_xf.position.x = m_sweep.c.x - (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
        m_xf.position.y = m_sweep.c.y - (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
    End
    
    '// used(This) to prevent connected bodies from colliding.
    '// It may lie, depending on the collideConnected flag.
    Method ShouldCollide : Bool (other:b2Body)
        '// At least one body should be
        If (m_type <> b2_Body And other.m_type <> b2_Body )
            
            Return False
        End
        
        '// Does a joint prevent collision?
        Local jn:b2JointEdge = m_jointList
        While ( jn <> Null )
            If (jn.other = other And jn.joint.m_collideConnected = False)
                Return False
            End
            jn = jn.nextItem
        End
        Return True
    End
    
    Method Advance : void (t:Float)
        
        '// Advance to the New safe time.
        m_sweep.Advance(t)
        m_sweep.c.SetV(m_sweep.c0)
        m_sweep.a = m_sweep.a0
        SynchronizeTransform()
    End
    
    Field m_flags :Int
    Field m_type :Int
    Field m_islandIndex :Int
    Field m_xf :b2Transform = New b2Transform()
    '// the body origin transform
    Field m_sweep :b2Sweep = New b2Sweep()
    '// the swept motion for CCD
    Field m_linearVelocity :b2Vec2 = New b2Vec2()
    Field m_angularVelocity :Float
    Field m_force :b2Vec2 = New b2Vec2()
    Field m_torque :Float
    Field m_world :b2World
    Field m_prev :b2Body
    Field m_next :b2Body
    Field m_fixtureList :b2Fixture
    Field m_fixtureCount :Int
    Field m_controllerList :b2ControllerEdge
    Field m_controllerCount :Int
    Field m_jointList :b2JointEdge
    Field m_contactList :b2ContactEdge
    Field m_mass :Float, m_invMass:Float
    Field m_I :Float, m_invI:Float
    Field m_inertiaScale :Float
    Field m_linearDamping :Float
    Field m_angularDamping :Float
    Field m_sleepTime :Float
    Field m_userData : Object
    '// m_flags
    '//enum
    '//{
    'static b2internal
    Const e_islandFlag:Int = $0001
    'static b2internal
    Const e_awakeFlag:Int = $0002
    'static b2internal
    Const e_allowSleepFlag:Int = $0004
    'static b2internal
    Const e_bulletFlag:Int = $0008
    'static b2internal
    Const e_fixedRotationFlag:Int = $0010
    'static b2internal
    Const e_activeFlag:Int = $0020
    '//}
    '// m_type
    '//enum
    '//{
    '/// The body type.
    '/// static: zero mass, zero velocity, may be manually moved
    '/// kinematic: zero mass, non-zero velocity set by user, moved by solver
    '/// : positive mass, non-zero velocity determined by forces, moved by solver
    Const b2_staticBody:Int = 0
    Const b2_kinematicBody:Int = 1
    Const b2_Body:Int = 2
    '//}
End






