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


'//typedef b2Contact* b2ContactCreateFcn(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator)
'//typedef void b2ContactDestroyFcn(b2Contact* contact, b2BlockAllocator* allocator)
#rem
'/**
'* The class manages contact between two shapes. A contact exists for each overlapping
'* AABB in the broad-phase (except if filtered). Therefore a contact object may exist
'* that has no contact points.
'*/
#end

Class ContactTypeFactory Abstract
    Method Create : b2Contact (allocator: Object) Abstract
    Method Destroy : void (contact:b2Contact, allocator: Object) Abstract
End

Class b2Contact
    Global s_input:b2TOIInput = New b2TOIInput()
    
    Field m_swapped:Bool = False
    
    Field m_flags:Int
    
    '// World pool and list pointers.
    Field m_prev:b2Contact
    Field m_next:b2Contact
    
    '// Nodes for connecting bodies.
    Field m_nodeA:b2ContactEdge = New b2ContactEdge()
    Field m_nodeB:b2ContactEdge = New b2ContactEdge()
    
    Field m_fixtureA:b2Fixture
    Field m_fixtureB:b2Fixture
    
    Field m_manifold:b2Manifold = New b2Manifold()
    Field m_oldManifold:b2Manifold = New b2Manifold()
    
    Field m_toi:Float
    
    #rem
    '/**
    '* Get the contact manifold. Do not modify the manifold unless you understand the
    '* internals of Box2D
    '*/
    #end
    Method GetManifold : b2Manifold ()
        
        Return m_manifold
    End
    #rem
    '/**
    '* Get the world manifold
    '*/
    #end
    Method GetWorldManifold : void (worldManifold:b2WorldManifold)
        
        Local bodyA :b2Body = m_fixtureA.GetBody()
        Local bodyB :b2Body = m_fixtureB.GetBody()
        Local shapeA :b2Shape = m_fixtureA.GetShape()
        Local shapeB :b2Shape = m_fixtureB.GetShape()
        worldManifold.Initialize(m_manifold, bodyA.GetTransform(), shapeA.m_radius, bodyB.GetTransform(), shapeB.m_radius)
    End
    #rem
    '/**
    '* Is this contact touching.
    '*/
    #end
    Method IsTouching : Bool ()
        
        Return (m_flags & e_touchingFlag) = e_touchingFlag
    End
    #rem
    '/**
    '* Does this contact generate TOI events for continuous simulation
    '*/
    #end
    Method IsContinuous : Bool ()
        
        Return (m_flags & e_continuousFlag) = e_continuousFlag
    End
    #rem
    '/**
    '* Change this to be a sensor or-non-sensor contact.
    '*/
    #end
    Method SetSensor : void (sensor:Bool)
        
        If (sensor)
            
            m_flags |= e_sensorFlag
        Else
            
            
            m_flags &= ~e_sensorFlag
        End
    End
    #rem
    '/**
    '* Is this contact a sensor?
    '*/
    #end
    Method IsSensor : Bool ()
        
        Return (m_flags & e_sensorFlag) = e_sensorFlag
    End
    #rem
    '/**
    '* Enable/disable this contact. This can be used inside the pre-solve
    '* contact listener. The only(contact) disabled for the current
    '* time timeStep (or sub-step in continuous collision).
    '*/
    #end
    Method SetEnabled : void (flag:Bool)
        
        If (flag)
            
            m_flags |= e_enabledFlag
        Else
            
            
            m_flags &= ~e_enabledFlag
        End
    End
    #rem
    '/**
    '* Has this contact been disabled?
    '* @return
    '*/
    #end
    Method IsEnabled : Bool ()
        
        Return (m_flags & e_enabledFlag) = e_enabledFlag
    End
    #rem
    '/**
    '* Get the nextItem contact in the worlds contact list.
    '*/
    #end
    Method GetNext : b2Contact ()
        
        Return m_next
    End
    #rem
    '/**
    '* Get the first fixture in this contact.
    '*/
    #end
    Method GetFixtureA : b2Fixture ()
        
        Return m_fixtureA
    End
    #rem
    '/**
    '* Get the second fixture in this contact.
    '*/
    #end
    Method GetFixtureB : b2Fixture ()
        
        Return m_fixtureB
    End
    #rem
    '/**
    '* Flag this contact for filtering. Filtering will occur the nextItem time timeStep.
    '*/
    #end
    Method FlagForFiltering : void ()
        
        m_flags |= e_filterFlag
    End
    '//--------------- Internals Below -------------------
    '// m_flags
    '// enum
    '// This contact should not participate in Solve
    '// The contact equivalent of sensors
    'static b2internal
    Const e_sensorFlag:Int		= $0001
    
    
    '// Generate TOI events.
    'static b2internal
    Const e_continuousFlag:Int	= $0002
    
    
    '// Used when crawling contact graph when forming islands.
    'static b2internal
    Const e_islandFlag:Int		= $0004
    
    
    '// Used in SolveTOI to indicate the cached toi still(value) valid.
    'static b2internal
    Const e_toiFlag:Int		= $0008
    
    
    '// Set when shapes are touching
    'static b2internal
    Const e_touchingFlag:Int	= $0010
    
    
    '// This contact can be disabled (by user)
    'static b2internal
    Const e_enabledFlag:Int	= $0020
    
    
    '// This contact needs filtering because a fixture filter was changed.
    'static b2internal
    Const e_filterFlag:Int		= $0040
    
    Method New()
        
        '// Real done(work) in Reset
    End
    '* @
    Method Reset : void (fixtureA:b2Fixture = null, fixtureB:b2Fixture = null)
        
        m_flags = e_enabledFlag
        If (Not(fixtureA) Or Not(fixtureB))
            
            m_fixtureA = null
            m_fixtureB = null
            Return
        End
        If (fixtureA.IsSensor() Or fixtureB.IsSensor())
            
            m_flags |= e_sensorFlag
        End
        Local bodyA :b2Body = fixtureA.GetBody()
        Local bodyB :b2Body = fixtureB.GetBody()
        If (bodyA.GetType() <> b2Body.b2_Body Or bodyA.IsBullet() Or bodyB.GetType() <> b2Body.b2_Body Or bodyB.IsBullet())
            
            m_flags |= e_continuousFlag
        End
        m_fixtureA = fixtureA
        m_fixtureB = fixtureB
        m_manifold.m_pointCount = 0
        m_prev = null
        m_next = null
        m_nodeA.contact = null
        m_nodeA.prevItem = null
        m_nodeA.nextItem = null
        m_nodeA.other = null
        m_nodeB.contact = null
        m_nodeB.prevItem = null
        m_nodeB.nextItem = null
        m_nodeB.other = null
    End
    
    Method Update : void (listener:b2ContactListenerInterface)
        
        '// Swap old & New manifold
        Local tManifold :b2Manifold = m_oldManifold
        m_oldManifold = m_manifold
        m_manifold = tManifold
        '// Re-enable this contact
        m_flags |= e_enabledFlag
        Local touching :Bool = False
        Local wasTouching :Bool = (m_flags & e_touchingFlag) = e_touchingFlag
        Local bodyA :b2Body = m_fixtureA.m_body
        Local bodyB :b2Body = m_fixtureB.m_body
        Local aabbOverlap :Bool = m_fixtureA.m_aabb.TestOverlap(m_fixtureB.m_aabb)
        '// Is this contat a sensor?
        If (m_flags  & e_sensorFlag)
            
            If (aabbOverlap)
                
                Local shapeA :b2Shape = m_fixtureA.GetShape()
                Local shapeB :b2Shape = m_fixtureB.GetShape()
                Local xfA :b2Transform = bodyA.GetTransform()
                Local xfB :b2Transform = bodyB.GetTransform()
                touching = b2Shape.TestOverlap(shapeA, xfA, shapeB, xfB)
            End
            '// Sensors dont generate manifolds
            m_manifold.m_pointCount = 0
        Else
            '// Slow contacts dont generate TOI events.
            If (bodyA.GetType() <> b2Body.b2_Body Or bodyA.IsBullet() Or bodyB.GetType() <> b2Body.b2_Body Or bodyB.IsBullet())
                
                m_flags |= e_continuousFlag
            Else
                
                
                m_flags &= ~e_continuousFlag
            End
            If (aabbOverlap)
                
                Evaluate()
                touching = m_manifold.m_pointCount > 0
                '// Match old contact ids to New contact ids and copy the
                '// stored impulses to warm start the solver.
                For Local i:Int = 0 Until m_manifold.m_pointCount
                    
                    Local mp2 :b2ManifoldPoint = m_manifold.m_points[i]
                    mp2.m_normalImpulse = 0.0
                    mp2.m_tangentImpulse = 0.0
                    Local id2 :b2ContactID = mp2.m_id
                    For Local j:Int = 0 Until m_oldManifold.m_pointCount
                        Local mp1 :b2ManifoldPoint = m_oldManifold.m_points[j]
        
                        If (mp1.m_id.Key = id2.Key)
                            mp2.m_normalImpulse = mp1.m_normalImpulse
                            mp2.m_tangentImpulse = mp1.m_tangentImpulse
                            Exit
                        End
        
                    End
                End
            Else
                m_manifold.m_pointCount = 0
            End
            
            If (touching <> wasTouching)
                bodyA.SetAwake(True)
                bodyB.SetAwake(True)
            End
        End
        
        If (touching)
            m_flags |= e_touchingFlag
        Else
            m_flags &= ~e_touchingFlag
        End
        
        If (wasTouching = False And touching = True)
            listener.BeginContact(Self)
        End
        
        If (wasTouching = True And touching = False)
            listener.EndContact(Self)
        End
        
        If ((m_flags & e_sensorFlag) = 0)
            listener.PreSolve(Self, m_oldManifold)
        End
    End
    '// ~b2Contact() {}
    Method Evaluate : void ()
    End
    
    Method ComputeTOI : Float (sweepA:b2Sweep, sweepB:b2Sweep)
        s_input.proxyA.Set(m_fixtureA.GetShape())
        s_input.proxyB.Set(m_fixtureB.GetShape())
        s_input.sweepA = sweepA
        s_input.sweepB = sweepB
        s_input.tolerance = b2Settings.b2_linearSlop
        Return b2TimeOfImpact.TimeOfImpact(s_input)
    End
    
    
End



