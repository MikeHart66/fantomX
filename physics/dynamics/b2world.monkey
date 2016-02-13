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
'* The world class manages all physics entities,  simulation,
'* and asynchronous queries.
'*/
#end

Class InnerRayCastCallback Abstract
    Method Callback : Float (fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Float) Abstract
End

Class InnerRayCastOneCallback Extends InnerRayCastCallback
	'modified by skn3 to make ray picking work properly
    Field result:b2Fixture
	Field bestFraction:Float = 1.0
    
    Method Callback:Float(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Float)
		'need to keep track of the "best" fraction so we dont fail at picking
		If fraction <= bestFraction
			bestFraction = fraction
			result = fixture
		EndIf
		Return bestFraction
    End
End

Class InnerRayCastAllCallback Extends InnerRayCastCallback
    Field result:FlashArray<b2Fixture> = New FlashArray<b2Fixture>()
    
    Method Callback : Float (fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Float)
        result.Set( result.Length,  fixture )
        Return 1
    End
End


Class WorldRayCastCallback Extends RayCastCallback
    
    Field broadPhase:IBroadPhase
    Field callback:InnerRayCastCallback
    Field output:b2RayCastOutput = New b2RayCastOutput
    Field point1:b2Vec2
    Field point2:b2Vec2
    
    Method New( broadPhase:IBroadPhase, point1:b2Vec2, point2:b2Vec2, callback:InnerRayCastCallback )
        Self.broadPhase = broadPhase
        Self.callback = callback
        Self.point1 = point1
        Self.point2 = point2
    End
    
    Method Callback:Float(proxy: Object, input:b2RayCastInput)
        Local userData : Object = broadPhase.GetUserData(proxy)
        Local fixture :b2Fixture = b2Fixture(userData)
        Local hit :Bool = fixture.RayCast(output, input)
        
        If (hit)
            Local fraction :Float = output.fraction
            Local point :b2Vec2 = New b2Vec2((1.0 - fraction) * point1.x + fraction * point2.x,
            (1.0 - fraction) * point1.y + fraction * point2.y)
            Return callback.Callback(fixture, point, output.normal, fraction)
        End
        
        Return input.maxFraction
    End
End

Class QueryFixtureCallback Abstract
    Method Callback:Bool(fixture:b2Fixture) Abstract
End

Class WorldQueryCallback Extends QueryCallback Abstract
    
    Field broadPhase:IBroadPhase
    Field callback:QueryFixtureCallback
    
    Method New(broadPhase:IBroadPhase, callback:QueryFixtureCallback)
        Self.broadPhase = broadPhase
        Self.callback = callback
    End
    
    Method Callback:Bool(a:Object) Abstract
    
End

Class WorldQueryAABBCallback Extends WorldQueryCallback
    
    Method New(broadPhase:IBroadPhase, callback:QueryFixtureCallback)
        Super.New(broadPhase, callback)
    End
    
    Method Callback:Bool(a:Object)
        Return callback.Callback(b2Fixture(broadPhase.GetUserData(a)))
    End
End

Class WorldQueryShapeCallback Extends WorldQueryCallback
    
    Field shape:b2Shape
    Field transform:b2Transform
    
    Method New(broadPhase:IBroadPhase, callback:QueryFixtureCallback, shape:b2Shape, transform:b2Transform)
        Super.New( broadPhase, callback )
        Self.shape = shape
        Self.transform = transform
    End
    
    Method Callback:Bool(a:Object)
        Local fixture :b2Fixture = b2Fixture(broadPhase.GetUserData(a))
        If(b2Shape.TestOverlap(shape, transform, fixture.GetShape(), fixture.GetBody().GetTransform()))
            Return callback.Callback(fixture)
        End
        Return True
    End
End


Class WorldQueryPointCallback Extends WorldQueryCallback
    
    Field p:b2Vec2
    
    Method New(broadPhase:IBroadPhase, callback:QueryFixtureCallback, p:b2Vec2)
        Super.New( broadPhase, callback )
        Self.p = p
    End
    
    Method Callback:Bool(a:Object)
        Local fixture :b2Fixture = b2Fixture(broadPhase.GetUserData(a))
        If(fixture.TestPoint(p))
            Return callback.Callback(fixture)
        End
        Return True
    End
End

Class b2World
    Field m_flags:Int
    Field m_contactManager:b2ContactManager = New b2ContactManager()
    
    '// These two are stored purely for efficiency purposes, they dont maintain
    '// any data outside of a call to TimeStep
    Field m_contactSolver:b2ContactSolver = New b2ContactSolver()
    Field m_island:b2Island = New b2Island()
    Field m_bodyList:b2Body
    Field m_jointList:b2Joint
    Field m_contactList:b2Contact
    Field m_bodyCount:Int
    Field m_contactCount:Int
    Field m_jointCount:Int
    Field m_controllerList:b2Controller
    Field m_controllerCount:Int
    Field m_gravity:b2Vec2
    Field m_allowSleep:Bool
    Field m_groundBody:b2Body
    Field m_destructionListener:b2DestructionListener
    Field m_debugDraw:b2DebugDraw
    
    '// used(This) to compute the time timeStep ratio to support a variable time timeStep.
    Field m_inv_dt0:Float
    
    '// for(This)
    'debugging the solver.
    Global m_warmStarting:Bool
    '// for(This)
    'debugging the solver.
    Global m_continuousPhysics:Bool
    '// m_flags
    Const e_newFixture:Int = $0001
    Const e_locked:Int = $0002

    '// Construct a world object.
    #rem
    '/**
    '* @param gravity the world gravity vector.
    '* @param doSleep improve performance by not simulating inactive bodies.
    '*/
    #end
    Method New(gravity:b2Vec2, doSleep:Bool)
        m_destructionListener = null
        m_debugDraw = null
        m_bodyList = null
        m_contactList = null
        m_jointList = null
        m_controllerList = null
        m_bodyCount = 0
        m_contactCount = 0
        m_jointCount = 0
        m_controllerCount = 0
        m_warmStarting = True
        m_continuousPhysics = True
        m_allowSleep = doSleep
        m_gravity = gravity
        m_inv_dt0 = 0.0
        m_contactManager.m_world = Self
        Local bd :b2BodyDef = New b2BodyDef()
        m_groundBody = CreateBody(bd)
    End
    #rem
    '/**
    '* Destruct the world. All physics entities are destroyed and all heap released(memory).
    '*/
    #end
    '//~b2World()
    #rem
    '/**
    '* Register a destruction listener.
    '*/
    #end
    Method SetDestructionListener : void (listener:b2DestructionListener)
        
        m_destructionListener = listener
    End
    #rem
    '/**
    '* Register a contact filter to provide specific control over collision.
    '* Otherwise the default used(filter) (b2_defaultFilter).
    '*/
    #end
    Method SetContactFilter : void (filter:b2ContactFilter)
        
        m_contactManager.m_contactFilter = filter
    End
    #rem
    '/**
    '* Register a contact event listener
    '*/
    #end
    Method SetContactListener : void (listener:b2ContactListenerInterface)
        
        m_contactManager.m_contactListener = listener
    End
    #rem
    '/**
    '* Register a routine for debug drawing. The debug draw Methods are called
    '* inside the b2World::Step method, so make sure your ready(renderer) to
    '* consume draw commands when you call Step().
    '*/
    #end
    Method SetDebugDraw : void (debugDraw:b2DebugDraw)
        
        m_debugDraw = debugDraw
    End
    #rem
    '/**
    '* Use the given a(object) broadphase.
    '* The old broadphase will not be cleanly emptied.
    '* @warning not(It) recommended you call this except immediately after constructing the world.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method SetBroadPhase : void (broadPhase:IBroadPhase)
        
        Local oldBroadPhase :IBroadPhase = m_contactManager.m_broadPhase
        m_contactManager.m_broadPhase = broadPhase
        Local b:b2Body = m_bodyList
        
        While( b <> Null )
            Local f:b2Fixture = b.m_fixtureList
            While ( f <> Null )
                f.m_proxy = broadPhase.CreateProxy(oldBroadPhase.GetFatAABB(f.m_proxy), f)
                f = f.m_next
            End
            b = b.m_next
        End
    End
    #rem
    '/**
    '* Perform validation of internal data structures.
    '*/
    #end
    Method Validate : void ()
        
        m_contactManager.m_broadPhase.Validate()
    End
    #rem
    '/**
    '* Get the number of broad-phase proxies.
    '*/
    #end
    Method GetProxyCount : Int ()
        
        Return m_contactManager.m_broadPhase.GetProxyCount()
    End
    #rem
    '/**
    '* Create a rigid body given a definition. No reference to the definition
    '* is retained.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method CreateBody : b2Body (def:b2BodyDef)
        '//b2Settings.B2Assert(m_lock = False)
        If (IsLocked() = True)
            
            Return null
        End
        '//void* mem = m_blockAllocator.Allocate(sizeof(b2Body))
        Local b :b2Body = New b2Body(def, Self)
        '// Add to world doubly linked list.
        b.m_prev = null
        b.m_next = m_bodyList
        If (m_bodyList)
            
            m_bodyList.m_prev = b
        End
        
        m_bodyList = b
        m_bodyCount += 1
        
        Return b
    End
    #rem
    '/**
    '* Destroy a rigid body given a definition. No reference to the definition
    '* is retained. This locked(Method) during callbacks.
    '* @warning This automatically deletes all associated shapes and joints.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method DestroyBody : void (b:b2Body)
        '//b2Settings.B2Assert(m_bodyCount > 0)
        '//b2Settings.B2Assert(m_lock = False)
        If (IsLocked() = True)
            
            Return
        End
        '// Delete the attached joints.
        Local jn :b2JointEdge = b.m_jointList
        While (jn)
            
            Local jn0 :b2JointEdge = jn
            jn = jn.nextItem
            If (m_destructionListener)
                
                m_destructionListener.SayGoodbyeJoint(jn0.joint)
            End
            DestroyJoint(jn0.joint)
        End
        '// Detach controllers attached to this body
        Local coe :b2ControllerEdge = b.m_controllerList
        While (coe)
            
            Local coe0 :b2ControllerEdge = coe
            coe = coe.nextController
            coe0.controller.RemoveBody(b)
        End
        '// Delete the attached contacts.
        Local ce :b2ContactEdge = b.m_contactList
        While (ce)
            
            Local ce0 :b2ContactEdge = ce
            ce = ce.nextItem
            m_contactManager.Destroy(ce0.contact)
        End
        
        b.m_contactList = Null
        '// Delete the attached fixtures. This destroys broad-phase
        '// proxies.
        Local f :b2Fixture = b.m_fixtureList
        While (f)
            
            Local f0 :b2Fixture = f
            f = f.m_next
            If (m_destructionListener)
                
                m_destructionListener.SayGoodbyeFixture(f0)
            End
            f0.DestroyProxy(m_contactManager.m_broadPhase)
            f0.Destroy()
            '//f0->~b2Fixture()
            '//m_blockAllocator.Free(f0, sizeof(b2Fixture))
        End
        
        b.m_fixtureList = Null
        b.m_fixtureCount = 0
        '// Remove world body list.
        If (b.m_prev)
            
            b.m_prev.m_next = b.m_next
        End
        If (b.m_next)
            
            b.m_next.m_prev = b.m_prev
        End
        If (b = m_bodyList)
            
            m_bodyList = b.m_next
        End
        
        m_bodyCount -= 1
        '//b->~b2Body()
        '//m_blockAllocator.Free(b, sizeof(b2Body))
    End
    #rem
    '/**
    '* Create a joint to constrain bodies together. No reference to the definition
    '* is retained. This may cause the connected bodies to cease colliding.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method CreateJoint : b2Joint (def:b2JointDef)
        '//b2Settings.B2Assert(m_lock = False)
        Local j :b2Joint = b2Joint.Create(def, null)
        '// Connect to the world list.
        j.m_prev = null
        j.m_next = m_jointList
        If (m_jointList)
            
            m_jointList.m_prev = j
        End
        
        m_jointList = j
        m_jointCount += 1
        
        '// Connect to the bodies doubly linked lists.
        j.m_edgeA.joint = j
        j.m_edgeA.other = j.m_bodyB
        j.m_edgeA.prevItem = null
        j.m_edgeA.nextItem = j.m_bodyA.m_jointList
        If (j.m_bodyA.m_jointList)
            j.m_bodyA.m_jointList.prevItem = j.m_edgeA
        End
        j.m_bodyA.m_jointList = j.m_edgeA
        j.m_edgeB.joint = j
        j.m_edgeB.other = j.m_bodyA
        j.m_edgeB.prevItem = null
        j.m_edgeB.nextItem = j.m_bodyB.m_jointList
        If (j.m_bodyB.m_jointList)
            j.m_bodyB.m_jointList.prevItem = j.m_edgeB
        End
        j.m_bodyB.m_jointList = j.m_edgeB
        Local bodyA :b2Body = def.bodyA
        Local bodyB :b2Body = def.bodyB
        '// If the joint prevents collisions, then flag any contacts for filtering.
        If (def.collideConnected = False )
            
            Local edge :b2ContactEdge = bodyB.GetContactList()
            While (edge)
                
                If (edge.other = bodyA)
                    
                    '// Flag the contact for filtering at the nextItem time timeStep (where either
                    '// awake(body)).
                    edge.contact.FlagForFiltering()
                End
                edge = edge.nextItem
            End
        End
        '// Note: creating a joint doesnt wake the bodies.
        Return j
    End
    #rem
    '/**
    '* Destroy a joint. This may cause the connected bodies to begin colliding.
    '* @warning This locked(Method) during callbacks.
    '*/
    #end
    Method DestroyJoint : void (j:b2Joint)
        '//b2Settings.B2Assert(m_lock = False)
        Local collideConnected :Bool = j.m_collideConnected
        '// Remove from the doubly linked list.
        If (j.m_prev)
            
            j.m_prev.m_next = j.m_next
        End
        If (j.m_next)
            
            j.m_next.m_prev = j.m_prev
        End
        If (j = m_jointList)
            
            m_jointList = j.m_next
        End
        '// Disconnect from island graph.
        Local bodyA :b2Body = j.m_bodyA
        Local bodyB :b2Body = j.m_bodyB
        '// Wake up connected bodies.
        bodyA.SetAwake(True)
        bodyB.SetAwake(True)
        '// Remove from body 1.0
        If (j.m_edgeA.prevItem)
            
            j.m_edgeA.prevItem.nextItem = j.m_edgeA.nextItem
        End
        If (j.m_edgeA.nextItem)
            
            j.m_edgeA.nextItem.prevItem = j.m_edgeA.prevItem
        End
        If (j.m_edgeA = bodyA.m_jointList)
            
            bodyA.m_jointList = j.m_edgeA.nextItem
        End
        j.m_edgeA.prevItem = null
        j.m_edgeA.nextItem = null
        '// Remove from body 2
        If (j.m_edgeB.prevItem)
            
            j.m_edgeB.prevItem.nextItem = j.m_edgeB.nextItem
        End
        If (j.m_edgeB.nextItem)
            
            j.m_edgeB.nextItem.prevItem = j.m_edgeB.prevItem
        End
        If (j.m_edgeB = bodyB.m_jointList)
            
            bodyB.m_jointList = j.m_edgeB.nextItem
        End
        j.m_edgeB.prevItem = null
        j.m_edgeB.nextItem = null
        b2Joint.Destroy(j, null)
        '//b2Settings.B2Assert(m_jointCount > 0)
        m_jointCount -= 1
        
        '// If the joint prevents collisions, then flag any contacts for filtering.
        If (collideConnected = False)
            
            Local edge :b2ContactEdge = bodyB.GetContactList()
            While (edge)
                
                If (edge.other = bodyA)
                    
                    '// Flag the contact for filtering at the nextItem time timeStep (where either
                    '// awake(body)).
                    edge.contact.FlagForFiltering()
                End
                edge = edge.nextItem
            End
        End
    End
    #rem
    '/**
    '* Add a controller to the world list
    '*/
    #end
    Method AddController : b2Controller (c:b2Controller)
        
        c.m_next = m_controllerList
        c.m_prev = null
        m_controllerList = c
        c.m_world = Self
        m_controllerCount += 1
        
        Return c
    End
    Method RemoveController : void (c:b2Controller)
        
        '//TODO: Remove bodies from controller
        If (c.m_prev)
            c.m_prev.m_next = c.m_next
        End
        If (c.m_next)
            c.m_next.m_prev = c.m_prev
        End
        If (m_controllerList = c)
            m_controllerList = c.m_next
        End
        m_controllerCount -= 1
        
    End
    Method CreateController : b2Controller (controller:b2Controller)
        
        If (controller.m_world <> Self)
            Print("Controller can only be a member of one world")
        End
        controller.m_next = m_controllerList
        controller.m_prev = null
        If (m_controllerList)
            m_controllerList.m_prev = controller
        End
        m_controllerList = controller
        m_controllerCount += 1
        
        controller.m_world = Self
        Return controller
    End
    Method DestroyController : void (controller:b2Controller)
        
        '//b2Settings.B2Assert(m_controllerCount > 0)
        controller.Clear()
        If (controller.m_next)
            controller.m_next.m_prev = controller.m_prev
        End
        If (controller.m_prev)
            controller.m_prev.m_next = controller.m_next
        End
        If (controller = m_controllerList)
            m_controllerList = controller.m_next
        End
        
        m_controllerCount -= 1
        
    End
    #rem
    '/**
    '* Enable/disable warm starting. For testing.
    '*/
    #end
    Method SetWarmStarting : void (flag: Bool)
        m_warmStarting = flag
    End
    #rem
    '/**
    '* Enable/disable continuous physics. For testing.
    '*/
    #end
    Method SetContinuousPhysics : void (flag: Bool)
        m_continuousPhysics = flag
    End
    #rem
    '/**
    '* Get the number of bodies.
    '*/
    #end
    Method GetBodyCount : Int ()
        
        Return m_bodyCount
    End
    #rem
    '/**
    '* Get the number of joints.
    '*/
    #end
    Method GetJointCount : Int ()
        
        Return m_jointCount
    End
    #rem
    '/**
    '* Get the number of contacts (each may have 0 or more contact points).
    '*/
    #end
    Method GetContactCount : Int ()
        
        Return m_contactCount
    End
    #rem
    '/**
    '* Change the global gravity vector.
    '*/
    #end
    Method SetGravity : void (gravity: b2Vec2)
        
        m_gravity = gravity
    End
    #rem
    '/**
    '* Get the global gravity vector.
    '*/
    #end
    Method GetGravity : b2Vec2 ()
        
        Return m_gravity
    End
    #rem
    '/**
    '* The world provides a single static ground body with no collision shapes.
    '* You can use this to simplify the creation of joints and static shapes.
    '*/
    #end
    Method GetGroundBody : b2Body ()
        
        Return m_groundBody
    End
    Global s_timestep2:b2TimeStep = New b2TimeStep()
    #rem
    '/**
    '* Take a time timeStep. This performs collision detection, integration,
    '* and constraint solution.
    '* @param timeStep the amount of time to simulate, this should not vary.
    '* @param velocityIterations for the velocity constraint solver.
    '* @param positionIterations for the position constraint solver.
    '*/
    #end
    Method TimeStep : void (dt:Float, velocityIterations:Int, positionIterations:Int)
        
        If (m_flags & e_newFixture)
            
            m_contactManager.FindNewContacts()
            m_flags &= ~e_newFixture
        End
        m_flags |= e_locked
        Local timeStep :b2TimeStep = s_timestep2
        timeStep.dt = dt
        timeStep.velocityIterations = velocityIterations
        timeStep.positionIterations = positionIterations
        If (dt > 0.0)
            
            timeStep.inv_dt = 1.0 / dt
        Else
            
            
            timeStep.inv_dt = 0.0
        End
        timeStep.dtRatio = m_inv_dt0 * dt
        timeStep.warmStarting = m_warmStarting
        '// Update contacts.
        m_contactManager.Collide()
        '// Integrate velocities, solve velocity constraints, and integrate positions.
        If (timeStep.dt > 0.0)
            
            Solve(timeStep)
        End
        '// Handle TOI events.
        If (m_continuousPhysics And timeStep.dt > 0.0)
            
            SolveTOI(timeStep)
        End
        If (timeStep.dt > 0.0)
            
            m_inv_dt0 = timeStep.inv_dt
        End
        
        m_flags &= ~e_locked
    End
    #rem
    '/**
    '* Call this after you are done with time steps to clear the forces. You normally
    '* call this after each call to Step, unless you are performing sub-steps.
    '*/
    #end
    
    Method ClearForces : void ()
        
        Local body:b2Body = m_bodyList
        
        While ( body <> Null )
            body.m_force.SetZero()
            body.m_torque = 0.0
            body = body.m_next
        End
    End
    Global s_xf:b2Transform = New b2Transform()
    
    #rem
    '/**
    '* Query the world for all fixtures that potentially overlap the
    '* provided AABB.
    '* @param callback a user implemented callback class. It should match signature
    '* <code>Method Callback:Void(fixture:b2Fixture):Bool</code>
    '* Return True to continue to the nextItem fixture.
    '* @param aabb the query box.
    '*/
    #end
    
    Method QueryAABB : void (callback:QueryFixtureCallback, aabb:b2AABB)
        
        Local broadPhase:IBroadPhase = m_contactManager.m_broadPhase
        
        broadPhase.Query(New WorldQueryAABBCallback(broadPhase, callback), aabb)
    End
    #rem
    '/**
    '* Query the world for all fixtures that precisely overlap the
    '* provided transformed shape.
    '* @param callback a user implemented callback class. It should match signature
    '* <code>Method Callback:Void(fixture:b2Fixture):Bool</code>
    '* Return True to continue to the nextItem fixture.
    '* @asonly
    '*/
    #end
    Method QueryShape : void (callback:QueryFixtureCallback, shape:b2Shape, transform:b2Transform = null)
        
        If (transform = null)
            
            transform = New b2Transform()
            transform.SetIdentity()
        End
        
        Local broadPhase:IBroadPhase = m_contactManager.m_broadPhase
        Local aabb :b2AABB = New b2AABB()
        shape.ComputeAABB(aabb, transform)
        broadPhase.Query(New WorldQueryShapeCallback(broadPhase,callback,shape,transform), aabb)
    End
    #rem
    '/**
    '* Query the world for all fixtures that contain a point.
    '* @param callback a user implemented callback class. It should match signature
    '* <code>Method Callback:Void(fixture:b2Fixture):Bool</code>
    '* Return True to continue to the nextItem fixture.
    '* @asonly
    '*/
    #end
    
    Method QueryPoint : void (callback:QueryFixtureCallback, p:b2Vec2)
        
        Local broadPhase:IBroadPhase = m_contactManager.m_broadPhase
        '// Make a small box.
        Local aabb :b2AABB = New b2AABB()
        aabb.lowerBound.Set(p.x - b2Settings.b2_linearSlop, p.y - b2Settings.b2_linearSlop)
        aabb.upperBound.Set(p.x + b2Settings.b2_linearSlop, p.y + b2Settings.b2_linearSlop)
        broadPhase.Query(New WorldQueryPointCallback(broadPhase, callback, p), aabb)
    End
    #rem
    '/**
    '* Ray-cast the world for all fixtures in the path of the ray. Your callback
    '* Controls whether you get the closest point, any point, or n-points
    '* The ray-cast ignores shapes that contain the starting point
    '* @param callback A callback Method which must be of signature:
    '* <code>Method Callback:Void(fixture:b2Fixture,    // The fixture hit by the ray
    '* point:b2Vec2,         // The point of initial intersection
    '* normal:b2Vec2,        // The normal vector at the point of intersection
    '* fraction:Float       // The fractional length along the ray of the intersection
    '* ):Float
    '* </code>
    '* Callback should return the New length of the a(ray) fraction of the original length.
    '* By returning 0, you immediately terminate.
    '* By returning 1, you continue wiht the original ray.
    '* By returning the current fraction, you proceed to find the closest point.
    '* @param point1 the ray starting point
    '* @param point2 the ray ending point
    '*/
    #end
    
    Method RayCast : void (callback:InnerRayCastCallback, point1:b2Vec2, point2:b2Vec2)
        Local broadPhase:IBroadPhase = m_contactManager.m_broadPhase
        Local input :b2RayCastInput = New b2RayCastInput(point1, point2)
        broadPhase.RayCast(New WorldRayCastCallback(broadPhase, point1, point2, callback), input)
    End
    
    Method RayCastOne : b2Fixture (point1:b2Vec2, point2:b2Vec2)
        Local callback:InnerRayCastOneCallback = new InnerRayCastOneCallback()
        RayCast(callback, point1, point2)
        Return callback.result
    End
    
    Method RayCastAll : FlashArray<b2Fixture> (point1:b2Vec2, point2:b2Vec2)
        Local callback:InnerRayCastAllCallback = new InnerRayCastAllCallback()
        RayCast(callback, point1, point2)
        Return callback.result
    End
    
    #rem
    '/**
    '* Get the world body list. With the returned body, use b2Body::GetNext to get
    '* the nextItem body in the world list. A NULL body indicates the end of the list.
    '* @return the head of the world body list.
    '*/
    #end
    Method GetBodyList : b2Body ()
        
        Return m_bodyList
    End
    #rem
    '/**
    '* Get the world joint list. With the returned joint, use b2Joint::GetNext to get
    '* the nextItem joint in the world list. A NULL joint indicates the end of the list.
    '* @return the head of the world joint list.
    '*/
    #end
    Method GetJointList : b2Joint ()
        
        Return m_jointList
    End
    #rem
    '/**
    '* Get the world contact list. With the returned contact, use b2Contact::GetNext to get
    '* the nextItem contact in the world list. A NULL contact indicates the end of the list.
    '* @return the head of the world contact list.
    '* @warning contacts are
    '*/
    #end
    Method GetContactList : b2Contact ()
        
        Return m_contactList
    End
    #rem
    '/**
    '* Is the world locked (in the middle of a time timeStep).
    '*/
    #end
    Method IsLocked : Bool ()
        
        Return (m_flags & e_locked) > 0
    End
    '//--------------- Internals Below -------------------
    '// Internal yet  to make life easier.
    '// Find islands, integrate and solve constraints, solve position constraints
    Field stackCapacity:Int = 1000
    Field s_stack:b2Body[] = New b2Body[1000]
    
    
    Method Solve : void (timeStep:b2TimeStep)
        
        Local b :b2Body
        '// TimeStep all controllers
        Local controller:b2Controller= m_controllerList
        While( controller <> Null )
            controller.TimeStep(timeStep)
            controller=controller.m_next
        End
        '// Size the island for the worst case.
        Local island :b2Island = m_island
        island.Initialize(m_bodyCount, m_contactCount, m_jointCount, null, m_contactManager.m_contactListener, m_contactSolver)
        '// Clear all the island flags.
        b = m_bodyList
        While ( b <> Null )
            b.m_flags &= ~b2Body.e_islandFlag
            b = b.m_next
        End
        
        Local c:b2Contact = m_contactList
        While( c<>Null )
            c.m_flags &= ~b2Contact.e_islandFlag
            c = c.m_next
        End
        
        Local j:b2Joint = m_jointList
        While( j <> Null )
            j.m_islandFlag = False
            j = j.m_next
        End
        '// Build and simulate all awake islands.
        Local stackSize:Int = m_bodyCount
        If stackSize > stackCapacity
            s_stack = s_stack.Resize(stackSize)
            stackCapacity = stackSize
        End
        '//b2Body** stack = (b2Body**)m_stackAllocator.Allocate(stackSize * sizeof(b2Body*))
        Local stack:b2Body[] = s_stack
        Local seed:b2Body = m_bodyList
        Local seedStart := True
        While( seed <> Null)
            If (seed.m_flags & b2Body.e_islandFlag )
                seed = seed.m_next
                Continue
            End
            If (seed.m_flags & (b2Body.e_awakeFlag|b2Body.e_activeFlag) <> (b2Body.e_awakeFlag|b2Body.e_activeFlag) )'  .IsAwake() = False Or seed.IsActive() = False)
                seed = seed.m_next
                Continue
            End
            '// The seed can be  or kinematic.
            If (seed.m_type = b2Body.b2_staticBody)
                seed = seed.m_next
                Continue
            End
            '// Reset island and stack.
            island.Clear()
            Local stackCount:Int = 0
            stack[stackCount] = seed
            stackCount += 1
            seed.m_flags |= b2Body.e_islandFlag
            
            '// Perform a depth first search (DFS) on the constraint graph.
            While (stackCount > 0)
                '// Grab the nextItem body off the stack and add it to the island.
                stackCount -= 1
                b = stack[stackCount]
                '//b2Assert(b.IsActive() = True)
                island.AddBody(b)
                '// Make sure the awake(body).
                If (Not (b.m_flags & b2Body.e_awakeFlag))
                    b.SetAwake(True)
                End
                '// To keep small(islands) as possible, we dont
                '// propagate islands across static bodies.
                If (b.m_type = b2Body.b2_staticBody)
                    Continue
                End
                Local other :b2Body
                '// Search all contacts connected to this body.
                Local ce:b2ContactEdge = b.m_contactList
                While( ce <> Null )
                    '// Has this contact already been added to an island?
                    If (ce.contact.m_flags & b2Contact.e_islandFlag)
                        ce = ce.nextItem
                        Continue
                    End
                    '// Is this contact solid and touching?
                    If( ce.contact.m_flags & (b2Contact.e_enabledFlag|b2Contact.e_touchingFlag) <> 
                        (b2Contact.e_enabledFlag|b2Contact.e_touchingFlag) Or
                        ce.contact.m_flags & b2Contact.e_sensorFlag ) 
                    'If (ce.contact.m_flags & b2Contact.e_sensorFlag = True Or
                    '    ce.contact.m_flags & b2Contact.e_enabledFlag = False Or
                    '    ce.contact.m_flags & b2Contact.e_touchingFlag = False)
                        ce = ce.nextItem
                        Continue
                    End
                    island.AddContact(ce.contact)
                    ce.contact.m_flags |= b2Contact.e_islandFlag
                    '//var other:b2Body = ce.other
                    other = ce.other
                    '// Was the other body already added to this island?
                    If (other.m_flags & b2Body.e_islandFlag)
                        ce = ce.nextItem
                        Continue
                    End
                    '//b2Settings.B2Assert(stackCount < stackSize)
                    stack[stackCount] = other
                    stackCount += 1
                    other.m_flags |= b2Body.e_islandFlag
                    ce = ce.nextItem
                End
                '// Search all joints connect to this body.
                Local jn:b2JointEdge = b.m_jointList
                While( jn <> Null )
                    If (jn.joint.m_islandFlag = True)
                        jn = jn.nextItem
                        Continue
                    End
                    other = jn.other
                    '// Dont simulate joints connected to inactive bodies.
                    If (Not (other.m_flags & b2Body.e_activeFlag))
                        jn = jn.nextItem
                        Continue
                    End
                    island.AddJoint(jn.joint)
                    jn.joint.m_islandFlag = True
                    If (other.m_flags & b2Body.e_islandFlag)
                        jn = jn.nextItem
                        Continue
                    End
                    '//b2Settings.B2Assert(stackCount < stackSize)
                    stack[stackCount] = other
                    stackCount += 1
                    other.m_flags |= b2Body.e_islandFlag
                    jn = jn.nextItem
                End
            End
            
            island.Solve(timeStep, m_gravity, m_allowSleep)
            
            '// Post solve cleanup.
            For Local i:Int = 0 Until island.m_bodyCount
                '// Allow static bodies to participate in other islands.
                b = island.m_bodies[i]
                If (b.m_type = b2Body.b2_staticBody)                    
                    b.m_flags &= ~b2Body.e_islandFlag
                End
            End
            
            seed = seed.m_next
        End
        
        '//m_stackAllocator.Free(stack)
        For Local i:Int = 0 Until stack.Length
            If( stack[i] = Null )
                Exit
            End
            stack[i] = Null
        End
        
        '// Synchronize fixutres, check for out of range bodies.
        b = m_bodyList
        While( b <> Null )
            If (b.m_flags & (b2Body.e_awakeFlag|b2Body.e_activeFlag) <> (b2Body.e_awakeFlag|b2Body.e_activeFlag))
                b = b.m_next
                Continue
            End
            If (b.m_type = b2Body.b2_staticBody)
                b = b.m_next
                Continue
            End
            '// Update fixtures (for broad-phase).
            b.SynchronizeFixtures()
            b = b.m_next
        End
        '// Look for New contacts.
        m_contactManager.FindNewContacts()
    End
   
    Global s_backupA:b2Sweep = New b2Sweep()
    Global s_backupB:b2Sweep = New b2Sweep()
    Global s_timestep:b2TimeStep = New b2TimeStep()
    Global s_queue:b2Body[] = New b2Body[256] 'Reasonable start?
   
    '// Find TOI contacts and solve them.
    Method SolveTOI : void (timeStep:b2TimeStep)
        Local b :b2Body
        Local fA :b2Fixture
        Local fB :b2Fixture
        Local bA :b2Body
        Local bB :b2Body
        Local cEdge :b2ContactEdge
        Local j :b2Joint
        '// Reserve an island and a queue for TOI island solution.
        Local island :b2Island = m_island
        island.Initialize(m_bodyCount, b2Settings.b2_maxTOIContactsPerIsland, b2Settings.b2_maxTOIJointsPerIsland, null, m_contactManager.m_contactListener, m_contactSolver)
        '//Simple one pass queue
        '//Relies on the fact that were only making one pass
        '//through and each body can only be pushed/popped one.
        '//To push:
        '//queueSize += 1
        '//  queue.Set( queueStart+queueSize,  newElement )
        '//To pop:
        '//queueStart += 1
        '//  poppedElement = queue.Get(queueStart)
        '//  --queueSize
        If m_bodyCount > s_queue.Length
            s_queue = s_queue.Resize(m_bodyCount)
        End
        Local queue:b2Body[] = s_queue
        b = m_bodyList
        While( b <> Null )
            b.m_flags &= ~b2Body.e_islandFlag
            b.m_sweep.t0 = 0.0
            b = b.m_next
        End
        Local c :b2Contact
        c = m_contactList
        While( c <> Null )
            '// Invalidate TOI
            c.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag)
            c = c.m_next
        End
        j = m_jointList
        While( j <> Null )
            j.m_islandFlag = False
            j = j.m_next
        End
        
        '// Find TOI events and solve them.
        While(True)
            '// Find the first TOI.
            Local minContact :b2Contact = null
            Local minTOI :Float = 1.0
            c = m_contactList
            While( c <> Null )
                '// Can this contact generate a solid TOI contact?
                If( c.m_flags & (b2Contact.e_enabledFlag|b2Contact.e_continuousFlag) <> 
                    (b2Contact.e_enabledFlag|b2Contact.e_continuousFlag) Or 
                    c.m_flags & b2Contact.e_sensorFlag)
                    c = c.m_next
                    Continue
                End
      
                '// TODO_ERIN keep a counter on the contact, only respond to M TOIs per contact.
                Local toi :Float = 1.0
      
                If( c.m_flags & b2Contact.e_toiFlag)
                    '// This contact has a valid cached TOI.
                    toi = c.m_toi
                Else
                    '// Compute the TOI for this contact.
                    fA = c.m_fixtureA
                    fB = c.m_fixtureB
                    bA = fA.m_body
                    bB = fB.m_body
      
                    If ((bA.m_type <> b2Body.b2_Body Or Not(bA.m_flags&b2Body.e_awakeFlag)) And
                        (bB.m_type <> b2Body.b2_Body Or Not(bA.m_flags&b2Body.e_awakeFlag)))
                        c = c.m_next
                        Continue
                    End
                    '// Put the sweeps onto the same time interval.
                    Local t0 :Float = bA.m_sweep.t0
                    
                    If (bA.m_sweep.t0 < bB.m_sweep.t0)
                        t0 = bB.m_sweep.t0
                        bA.m_sweep.Advance(t0)
                    ElseIf (bB.m_sweep.t0 < bA.m_sweep.t0)
                        t0 = bA.m_sweep.t0
                        bB.m_sweep.Advance(t0)
                    End
                    '//b2Settings.B2Assert(t0 < 1.0f)
                    '// Compute the time of impact.
                    toi = c.ComputeTOI(bA.m_sweep, bB.m_sweep)
#If CONFIG = "debug"
                    b2Settings.B2Assert(0.0 <= toi And toi <= 1.0)
#End
                    '// If the in(TOI) range ...
                    If (toi > 0.0 And toi < 1.0)
                        '// Interpolate on the actual range.
                        '//toi = b2Math.Min((1.0 - toi) * t0 + toi, 1.0)
                        toi = (1.0 - toi) * t0 + toi
                        If (toi > 1)
                            toi = 1
                        End
                    End

                    c.m_toi = toi
                    c.m_flags |= b2Contact.e_toiFlag
                End

                If (Constants.EPSILON < toi And toi < minTOI)
                    '// the(This) minimum TOI found so far.
                    minContact = c
                    minTOI = toi
                End
                c = c.m_next
            End

            If (minContact = null Or 1.0 - 100.0 * Constants.EPSILON < minTOI)
                '// No more TOI events. Done!
                Exit
            End

            '// Advance the bodies to the TOI.
            fA = minContact.m_fixtureA
            fB = minContact.m_fixtureB
            bA = fA.m_body
            bB = fB.m_body
            s_backupA.Set(bA.m_sweep)
            s_backupB.Set(bB.m_sweep)
            bA.Advance(minTOI)
            bB.Advance(minTOI)
            '// The TOI contact likely has some New contact points.
            minContact.Update(m_contactManager.m_contactListener)
            minContact.m_flags &= ~b2Contact.e_toiFlag

            '// Is the contact solid?
            If (minContact.m_flags & b2Contact.e_sensorFlag Or
                Not(minContact.m_flags & b2Contact.e_enabledFlag))
                
                '// Restore the sweeps
                bA.m_sweep.Set(s_backupA)
                bB.m_sweep.Set(s_backupB)
                bA.SynchronizeTransform()
                bB.SynchronizeTransform()
                Continue
            End
            
            '// Did numerical issues prevent;,ontact pointjrom being generated
            If (Not(minContact.m_flags & b2Contact.e_touchingFlag))
                '// Give up on this TOI
                Continue
            End
            
            '// Build the TOI island. We need a  seed.
            Local seed :b2Body = bA
            
            If (seed.m_type <> b2Body.b2_Body)
                seed = bB
            End
            
            '// Reset island and queue.
            island.Clear()
            
            Local other :b2Body
            Local queueStart :Int = 0
            '//start index for queue
            Local queueSize :Int = 0
            '//elements in queue
            queue[queueStart + queueSize] =  seed
            queueSize += 1
            seed.m_flags |= b2Body.e_islandFlag
            
            '// Perform a breadth first search (BFS) on the contact graph.
            While (queueSize > 0)
                '// Grab the nextItem body off the stack and add it to the island.
                b = queue[queueStart]
                queueStart += 1
                queueSize -= 1
                
                island.AddBody(b)
            
                '// Make sure the awake(body).
                If (Not(b.m_flags & b2Body.e_awakeFlag))
                    b.SetAwake(True)
                End
                
                '// To keep small(islands) as possible, we dont
                '// propagate islands across static or kinematic bodies.
                If (b.m_type <> b2Body.b2_Body)
                    Continue
                End
                
                '// Search all contacts connected to this body.
                cEdge = b.m_contactList
                While( cEdge <> Null )
                    '// Does the TOI island still have space for contacts?
                    If (island.m_contactCount = island.m_contactCapacity)
                        Exit
                    End
                    '// Has this contact already been added to an island?
                    If (cEdge.contact.m_flags & b2Contact.e_islandFlag)
                        cEdge = cEdge.nextItem
                        Continue
                    End
                    
                    '// Skip sperate, sensor, or disabled contacts.
                    If (cEdge.contact.m_flags & (b2Contact.e_enabledFlag|b2Contact.e_touchingFlag) <> 
                        (b2Contact.e_enabledFlag|b2Contact.e_touchingFlag) Or
                        cEdge.contact.m_flags & b2Contact.e_sensorFlag)
                        cEdge = cEdge.nextItem
                        Continue
                    End
                    
                    island.AddContact(cEdge.contact)
                    cEdge.contact.m_flags |= b2Contact.e_islandFlag
                    
                    '// Update other body.
                    other = cEdge.other
                    
                    '// Was the other body already added to this island?
                    If (other.m_flags & b2Body.e_islandFlag)
                        cEdge = cEdge.nextItem
                        Continue
                    End
                    
                    '// Synchronize the connected body.
                    If (other.m_type <> b2Body.b2_staticBody)
                        other.Advance(minTOI)
                        other.SetAwake(True)
                    End
                    
                    '//b2Settings.B2Assert(queueStart + queueSize < queueCapacity)
                    queue[queueStart + queueSize] = other
                    queueSize += 1
                    other.m_flags |= b2Body.e_islandFlag
                    cEdge = cEdge.nextItem
                End
                
                Local jEdge:b2JointEdge = b.m_jointList
                While( jEdge <> Null )
                    If (island.m_jointCount = island.m_jointCapacity)
                        jEdge = jEdge.nextItem
                        Continue
                    End
                    If (jEdge.joint.m_islandFlag = True)
                        jEdge = jEdge.nextItem
                        Continue
                    End
                
                    other = jEdge.other
                    If (other.IsActive() = False)
                        jEdge = jEdge.nextItem
                        Continue
                    End
                    island.AddJoint(jEdge.joint)
                    jEdge.joint.m_islandFlag = True
                    If (other.m_flags & b2Body.e_islandFlag)
                        jEdge = jEdge.nextItem
                        Continue
                    End
                
                    '// Synchronize the connected body.
                    If (other.m_type <> b2Body.b2_staticBody)
                        other.Advance(minTOI)
                        other.SetAwake(True)
                    End
                    '//b2Settings.B2Assert(queueStart + queueSize < queueCapacity)
                    queue[queueStart + queueSize] = other
                    queueSize += 1
                    other.m_flags |= b2Body.e_islandFlag
                    jEdge = jEdge.nextItem
                End
            End
            
            Local subStep :b2TimeStep = s_timestep
            subStep.warmStarting = False
            subStep.dt = (1.0 - minTOI) * timeStep.dt
            subStep.inv_dt = 1.0 / subStep.dt
            subStep.dtRatio = 0.0
            subStep.velocityIterations = timeStep.velocityIterations
            subStep.positionIterations = timeStep.positionIterations
            island.SolveTOI(subStep)
            
            '// Post solve cleanup.
            For Local i:Int = 0 Until island.m_bodyCount
                '// Allow bodies to participate in future TOI islands.
                b = island.m_bodies[i]
                b.m_flags &= ~b2Body.e_islandFlag
            
                If (Not (b.m_flags & b2Body.e_awakeFlag) )
                    Continue
                End
                
                If (b.m_type <> b2Body.b2_Body)
                    Continue
                End
                
                '// Update fixtures (for broad-phase).
                b.SynchronizeFixtures()
                '// Invalidate all contact TOIs associated with this body. Some of these
                '// may not be in the island because they were not touching.
                cEdge = b.m_contactList
                
                While( cEdge <> Null )
                    cEdge.contact.m_flags &= ~b2Contact.e_toiFlag
                    cEdge = cEdge.nextItem
                End
            End
            
            For Local i:Int = 0 Until island.m_contactCount
                '// Allow contacts to participate in future TOI islands.
                c = island.m_contacts[i]
                c.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag)
            End
            
            For Local i:Int = 0 Until island.m_jointCount
                '// Allow joints to participate in future TOI islands
                j = island.m_joints[i]
                j.m_islandFlag = False
            End
            
            '// Commit fixture proxy movements to the broad-phase so that New contacts are created.
            '// Also, some contacts can be destroyed.
            m_contactManager.FindNewContacts()
        End
        '//m_stackAllocator.Free(queue)
    End
    
    Global s_jointColor:b2Color = New b2Color(0.5, 0.8, 0.8)
    '//
    Method DrawJoint : void (joint:b2Joint)
        Local b1 :b2Body = joint.GetBodyA()
        Local b2 :b2Body = joint.GetBodyB()
        Local xf1 :b2Transform = b1.m_xf
        Local xf2 :b2Transform = b2.m_xf
        Local x1 :b2Vec2 = xf1.position
        Local x2 :b2Vec2 = xf2.position
        Local p1 :b2Vec2 = New b2Vec2()
        joint.GetAnchorA(p1)
        Local p2 :b2Vec2 = New b2Vec2()
        joint.GetAnchorB(p2)
        '//b2Color color(0.5f, 0.8f, 0.8f)
        Local color :b2Color = s_jointColor
        Select (joint.m_type)
            
            Case b2Joint.e_distanceJoint
                m_debugDraw.DrawSegment(p1, p2, color)
            Case b2Joint.e_pulleyJoint
                
                Local pulley :b2PulleyJoint = b2PulleyJoint((joint))
                Local s1 :b2Vec2 = New b2Vec2()
                pulley.GetGroundAnchorA(s1)
                Local s2 :b2Vec2 = New b2Vec2()
                pulley.GetGroundAnchorB(s2)
                m_debugDraw.DrawSegment(s1, p1, color)
                m_debugDraw.DrawSegment(s2, p2, color)
                m_debugDraw.DrawSegment(s1, s2, color)
                
            Case b2Joint.e_mouseJoint
                m_debugDraw.DrawSegment(p1, p2, color)
                Default
                If (b1 <> m_groundBody)
                    m_debugDraw.DrawSegment(x1, p1, color)
                End
                m_debugDraw.DrawSegment(p1, p2, color)
                If (b2 <> m_groundBody)
                    m_debugDraw.DrawSegment(x2, p2, color)
                End
        End
    End
    
    Method DrawBody:Void(body:b2Body, color:b2Color)
        Local f:b2Fixture = body.GetFixtureList()
        While (f <> Null)
            DrawShape(f.GetShape(), body.m_xf, color)
            f = f.m_next
        End
    End
    
    Method DrawShape : void (shape:b2Shape, xf:b2Transform, color:b2Color)
        Select (shape.m_type)
            
            Case b2Shape.e_circleShape
                Local circle :b2CircleShape = b2CircleShape((shape))
                Local center :b2Vec2 = New b2Vec2()
                b2Math.MulX(xf, circle.m_p, center)
                Local radius :Float = circle.m_radius
                Local axis :b2Vec2 = xf.R.col1
                m_debugDraw.DrawSolidCircle(center, radius, axis, color)
            
            Case b2Shape.e_polygonShape
                Local i:Int
                Local poly :b2PolygonShape = b2PolygonShape((shape))
                Local vertexCount:Int = poly.GetVertexCount()
                Local localVertices:b2Vec2[] = poly.GetVertices()
                Local vertices:b2Vec2[] = New b2Vec2[vertexCount]
                
                For Local i:Int = 0 Until vertexCount
                    vertices[i] = New b2Vec2()
                    b2Math.MulX(xf, localVertices[i],vertices[i])
                End
                m_debugDraw.DrawSolidPolygon(vertices, vertexCount, color)
            
            Case b2Shape.e_edgeShape
                Local edge : b2EdgeShape = b2EdgeShape(shape)
                Local e1:b2Vec2 = New b2Vec2()
                Local e2:b2Vec2 = New b2Vec2()
                b2Math.MulX(xf, edge.GetVertex1(),e1)
                b2Math.MulX(xf, edge.GetVertex2(),e2)
                m_debugDraw.DrawSegment(e1, e2, color)
        End
    End
        
    #rem
    '/**
    '* Call this to draw shapes and other debug draw data.
    '*/
    #end
    Method DrawDebugData : void ()
        If (m_debugDraw = null)
            
            Return
        End
        m_debugDraw.Clear()
        Local flags :Int = m_debugDraw.GetFlags()
        Local i :Int
        Local b :b2Body
        Local f :b2Fixture
        Local s :b2Shape
        Local j :b2Joint
        Local bp :IBroadPhase
        Local invQ :b2Vec2 = New b2Vec2
        Local x1 :b2Vec2 = New b2Vec2
        Local x2 :b2Vec2 = New b2Vec2
        Local xf :b2Transform
        Local b1 :b2AABB = New b2AABB()
        Local b2 :b2AABB = New b2AABB()
        Local vs :b2Vec2[] = [New b2Vec2(), New b2Vec2(), New b2Vec2(), New b2Vec2()]
        '// Store color here and reuse, to reduce allocations
        Local color :b2Color = New b2Color(0.0, 0.0, 0.0)
        If (flags & b2DebugDraw.e_shapeBit)
            
            b = m_bodyList
            While( b <> Null )
                
                xf = b.m_xf
                
                f = b.GetFixtureList()
                While ( f <> Null )
                    s = f.GetShape()
                    If (b.IsActive() = False)
                        
                        color.Set(0.5, 0.5, 0.3)
                        DrawShape(s, xf, color)
                    Else  If (b.GetType() = b2Body.b2_staticBody)
                        
                        
                        color.Set(0.5, 0.9, 0.5)
                        DrawShape(s, xf, color)
                    Else  If (b.GetType() = b2Body.b2_kinematicBody)
                        
                        
                        color.Set(0.5, 0.5, 0.9)
                        DrawShape(s, xf, color)
                    Else  If (b.IsAwake() = False)
                        
                        
                        color.Set(0.6, 0.6, 0.6)
                        DrawShape(s, xf, color)
                    Else
                        
                        
                        color.Set(0.9, 0.7, 0.7)
                        DrawShape(s, xf, color)
                    End
                    f = f.m_next
                End
                b = b.m_next
            End
        End
        If (flags & b2DebugDraw.e_jointBit)
            
            j = m_jointList
            While ( j <> Null )
                DrawJoint(j)
                j = j.m_next
            End
        End
        If (flags & b2DebugDraw.e_controllerBit)
            
            Local c:b2Controller = m_controllerList
            While ( c <> Null )
                c.Draw(m_debugDraw)
                c = c.m_next
            End
        End
        If (flags & b2DebugDraw.e_pairBit)
            
            color.Set(0.3, 0.9, 0.9)
            Local contact:b2Contact = m_contactList
            While ( contact <> Null )
                If b2PolyAndCircleContact(contact)
                    Local fixtureA :b2Fixture = contact.GetFixtureA()
                    Local fixtureB :b2Fixture = contact.GetFixtureB()
                    Local cA:b2Vec2 = New b2Vec2()
                    fixtureA.GetAABB().GetCenter(cA)
                    Local cB:b2Vec2 = New b2Vec2()
                    fixtureB.GetAABB().GetCenter(cB)
                    m_debugDraw.DrawSegment(cA, cB, color)
                End
                contact = contact.GetNext()
            End
        End
        If (flags & b2DebugDraw.e_aabbBit)
            
            bp = m_contactManager.m_broadPhase
            vs = [New b2Vec2(),New b2Vec2(),New b2Vec2(),New b2Vec2()]
            b = m_bodyList
            While ( b <> Null )
                If (b.IsActive() = False)
                    b = b.GetNext()
                    Continue
                End
                
                f = b.GetFixtureList()
                While ( f <> Null )
                    Local aabb :b2AABB = bp.GetFatAABB(f.m_proxy)
                    vs[0].Set(aabb.lowerBound.x, aabb.lowerBound.y)
                    vs[1].Set(aabb.upperBound.x, aabb.lowerBound.y)
                    vs[2].Set(aabb.upperBound.x, aabb.upperBound.y)
                    vs[3].Set(aabb.lowerBound.x, aabb.upperBound.y)
                    m_debugDraw.DrawPolygon(vs, 4, color)
                    f = f.GetNext()
                End
                b = b.GetNext()
            End
        End
        If (flags & b2DebugDraw.e_centerOfMassBit)
            
            b = m_bodyList
            While( b <> Null )
                xf = s_xf
                xf.R = b.m_xf.R
                xf.position = b.GetWorldCenter()
                m_debugDraw.DrawTransform(xf)
                b = b.m_next
            End
        End
    End
End
    
    
        
        
        
        
        
        
        
