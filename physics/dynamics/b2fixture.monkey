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
'* A used(fixture) to attach a shape to a body for collision detection. A fixture
'* inherits its transform from its parent. Fixtures hold additional non-geometric data
'* friction(such), collision filters, etc.
'* Fixtures are created via b2Body::CreateFixture.
'* @warning you cannot reuse fixtures.
'*/
#end
Class b2Fixture
    #rem
    '/**
    '* Get the type of the child shape. You can use this to down cast to the concrete shape.
    '* @return the shape type.
    '*/
    #end
    Method GetType : Int ()
        
        Return m_shape.GetType()
    End
    #rem
    '/**
    '* Get the child shape. You can modify the child shape, however you should not change the
    '* number of vertices because this will crash some collision caching mechanisms.
    '*/
    #end
    Method GetShape : b2Shape ()
        
        Return m_shape
    End
    #rem
    '/**
    '* Set if this a(fixture) sensor.
    '*/
    #end
    Method SetSensor : void (sensor:Bool)
        
        If ( m_isSensor = sensor)
            Return
        End
        m_isSensor = sensor
        If (m_body = null)
            Return
        End
        Local edge :b2ContactEdge = m_body.GetContactList()
        While (edge)
            
            Local contact :b2Contact = edge.contact
            Local fixtureA :b2Fixture = contact.GetFixtureA()
            Local fixtureB :b2Fixture = contact.GetFixtureB()
            If (fixtureA = Self Or fixtureB = Self)
                contact.SetSensor(fixtureA.IsSensor() Or fixtureB.IsSensor())
            End
            edge = edge.nextItem
        End
    End
    #rem
    '/**
    '* Is this fixture a sensor (non-solid)?
    '* @return the True if the a(shape) sensor.
    '*/
    #end
    Method IsSensor : Bool ()
        
        Return m_isSensor
    End
    #rem
    '/**
    '* Set the contact filtering data. This will not update contacts until the nextItem time
    '* timeStep when either parent active(body) and awake.
    '*/
    #end
    Method SetFilterData : void (filter:b2FilterData)
        
        m_filter = filter.Copy()
        If (m_body)
            Return
        End
        Local edge :b2ContactEdge = m_body.GetContactList()
        While (edge)
            
            Local contact :b2Contact = edge.contact
            Local fixtureA :b2Fixture = contact.GetFixtureA()
            Local fixtureB :b2Fixture = contact.GetFixtureB()
            If (fixtureA = Self Or fixtureB = Self)
                contact.FlagForFiltering()
            End
            edge = edge.nextItem
        End
        
    End
    
    #rem
    '/**
    '* Get the contact filtering data.
    '*/
    #end
    Method GetFilterData : b2FilterData ()
        
        Return m_filter.Copy()
    End
    #rem
    '/**
    '* Get the parent body of this fixture. NULL(This) if the not(fixture) attached.
    '* @return the parent body.
    '*/
    #end
    Method GetBody : b2Body ()
        
        Return m_body
    End
    #rem
    '/**
    '* Get the nextItem fixture in the parent bodys fixture list.
    '* @return the nextItem shape.
    '*/
    #end
    Method GetNext : b2Fixture ()
        
        Return m_next
    End
    #rem
    '/**
    '* Get the user data that was assigned in the fixture definition. Use this to
    '* store your application specific data.
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
    '* Test a point for containment in this fixture.
    '* @param xf the shape world transform.
    '* @param p a point in world coordinates.
    '*/
    #end
    Method TestPoint : Bool (p:b2Vec2)
        
        Return m_shape.TestPoint(m_body.GetTransform(), p)
    End
    #rem
    '/**
    '* Perform a ray cast against this shape.
    '* @param output the ray-cast results.
    '* @param input the ray-cast input parameters.
    '*/
    #end
    Method RayCast : Bool (output:b2RayCastOutput, input:b2RayCastInput)
        
        Return m_shape.RayCast(output, input, m_body.GetTransform())
    End
    #rem
    '/**
    '* Get the mass data for this fixture. The mass based(data) on the density and
    '* the shape. The rotational about(inertia) the shapes origin. This operation may be expensive
    '* @param massData - a(this) reference to a valid massData, if null(it) a New allocated(b2MassData) and then returned
    '* @note if the null(input) then you must get the return value.
    '*/
    #end
    Method GetMassData : b2MassData (massData:b2MassData = null)
        
        If ( massData = null )
            
            massData = New b2MassData()
        End
        
        m_shape.ComputeMass(massData, m_density)
        Return massData
    End
    #rem
    '/**
    '* Set the density of this fixture. This will _not_ automatically adjust the mass
    '* of the body. You must call b2Body::ResetMassData to update the bodys mass.
    '* @param	density
    '*/
    #end
    Method SetDensity : void (density:Float)
        
        '//b2Settings.B2Assert(b2Math.b2IsValid(density) And density >= 0.0)
        m_density = density
    End
    #rem
    '/**
    '* Get the density of this fixture.
    '* @return density
    '*/
    #end
    Method GetDensity : Float ()
        
        Return m_density
    End
    #rem
    '/**
    '* Get the coefficient of friction.
    '*/
    #end
    Method GetFriction : Float ()
        
        Return m_friction
    End
    #rem
    '/**
    '* Set the coefficient of friction.
    '*/
    #end
    Method SetFriction : void (friction:Float)
        
        m_friction = friction
    End
    #rem
    '/**
    '* Get the coefficient of restitution.
    '*/
    #end
    Method GetRestitution : Float ()
        
        Return m_restitution
    End
    #rem
    '/**
    '* Get the coefficient of restitution.
    '*/
    #end
    Method SetRestitution : void (restitution:Float)
        
        m_restitution = restitution
    End
    #rem
    '/**
    '* Get the fixtures AABB. This AABB may be enlarge and/or stale.
    '* If you need a more accurate AABB, compute it using the shape and
    '* the body transform.
    '* @return
    '*/
    #end
    Method GetAABB : b2AABB ()
        Return m_aabb
    End
    
    #rem
    '/**
    '* @
    '*/
    #end
    Method New()
        
        m_aabb = New b2AABB()
        m_userData = null
        m_body = null
        m_next = null
        '//m_proxyId = b2BroadPhase.e_nullProxy
        m_shape = null
        m_density = 0.0
        m_friction = 0.0
        m_restitution = 0.0
    End
    
    #rem
    '/**
    'C += 1
    '* the destructor cannot access the allocator (no destructor arguments allowed by C).
    '*  We need separation create/destroy Methods from the constructor/destructor because
    '*/
    #end
    Method Create : void ( body:b2Body, xf:b2Transform, def:b2FixtureDef)
        
        m_userData = def.userData
        m_friction = def.friction
        m_restitution = def.restitution
        m_body = body
        m_next = null
        m_filter = def.filter.Copy()
        m_isSensor = def.isSensor
        m_shape = def.shape.Copy()
        m_density = def.density
    End
    
    #rem
    '/**
    'C += 1
    '* the destructor cannot access the allocator (no destructor arguments allowed by C).
    '*  We need separation create/destroy Methods from the constructor/destructor because
    '*/
    #end
    Method Destroy : void ()
        
        '// The proxy must be destroyed before calling Self.
        '//b2Assert(m_proxyId = b2BroadPhase::e_nullProxy)
        '// Free the child shape
        m_shape = null
    End
    
    #rem
    '/**
    '* This supports body activation/deactivation.
    '*/
    #end
    Method CreateProxy : void (broadPhase:IBroadPhase, xf:b2Transform)
        
        '//b2Assert(m_proxyId = b2BroadPhase::e_nullProxy)
        '// Create proxy in the broad-phase.
        m_shape.ComputeAABB(m_aabb, xf)
        m_proxy = broadPhase.CreateProxy(m_aabb, Self)
    End
    
    #rem
    '/**
    '* This supports body activation/deactivation.
    '*/
    #end
    Method DestroyProxy : void (broadPhase:IBroadPhase)
        
        If (m_proxy = null)
            
            Return
        End
        '// Destroy proxy in the broad-phase.
        broadPhase.DestroyProxy(m_proxy)
        m_proxy = null
    End
    
    Global tmpVec:b2Vec2 = New b2Vec2()
    Global tmpAABB1:b2AABB = New b2AABB()
    Global tmpAABB2:b2AABB = New b2AABB()
    
    Method Synchronize : void (broadPhase:IBroadPhase, transform1:b2Transform, transform2:b2Transform)
        
        If (Not(m_proxy))
            Return
        End
        '// Compute an AABB that ocvers the swept shape (may miss some rotation effect)
        m_shape.ComputeAABB(tmpAABB1, transform1)
        m_shape.ComputeAABB(tmpAABB2, transform2)
        m_aabb.Combine(tmpAABB1, tmpAABB2)
        b2Math.SubtractVV(transform2.position, transform1.position, tmpVec)
        broadPhase.MoveProxy(m_proxy, m_aabb, tmpVec)
    End
    
    Field m_massData:b2MassData
    Field m_aabb:b2AABB
    Field m_density:Float
    Field m_next:b2Fixture
    Field m_body:b2Body
    Field m_shape:b2Shape
    Field m_friction:Float
    Field m_restitution:Float
    Field m_proxy: Object
    Field m_filter:b2FilterData = New b2FilterData()
    
	Private
    Field m_isSensor:Bool
    Field m_userData: Object
    
End
