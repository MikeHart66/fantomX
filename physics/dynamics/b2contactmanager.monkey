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


'// Delegate of b2World.
#rem
'/**
'* @
'*/
#end
Class CMUpdatePairsCallback Extends UpdatePairsCallback
    Field cm:b2ContactManager
    Method New(cm:b2ContactManager)
        Self.cm = cm
    End
    Method Callback:Void(a:Object,b:Object)
        cm.AddPair(a,b)
    End
End

Class b2ContactManager
    

    Field pairsCallback:UpdatePairsCallback
    
    Method New()
        m_world = null
        m_contactCount = 0
        m_contactFilter = b2ContactFilter.b2_defaultFilter
        m_contactListener = b2ContactListener.b2_defaultListener
        m_contactFactory = New b2ContactFactory(m_allocator)
        m_broadPhase = New b2DynamicTreeBroadPhase()
        pairsCallback = New CMUpdatePairsCallback(Self)
    End
    
    '// a(This) callback from the broadphase when two AABB proxies begin
    '// to overlap. We create a b2Contact to manage the narrow phase.
    Method AddPair : void (proxyUserDataA: Object, proxyUserDataB: Object)
        'Print "Adding contact pair"
        Local fixtureA :b2Fixture = b2Fixture(proxyUserDataA)
        Local fixtureB :b2Fixture = b2Fixture(proxyUserDataB)
        Local bodyA :b2Body = fixtureA.GetBody()
        Local bodyB :b2Body = fixtureB.GetBody()
        '// Are the fixtures on the same body?
        If (bodyA = bodyB)
            'Print "Abort as same body"
            Return
        End
        '// Does a contact already exist?
        Local edge :b2ContactEdge = bodyB.GetContactList()
        While (edge)
            
            If (edge.other = bodyA)
                
                Local fA :b2Fixture = edge.contact.GetFixtureA()
                Local fB :b2Fixture = edge.contact.GetFixtureB()
                If (fA = fixtureA And fB = fixtureB) Or (fA = fixtureB And fB = fixtureA)
                    'Print "Abort as contact exists"
                    Return
                End
            End
            
            edge = edge.nextItem
        End
        '//Does a joint  collision? Is at least one body ?
        If (bodyB.ShouldCollide(bodyA) = False)
            'Print "Abort as shouldnt collide"
            Return
        End
        '// Check user filtering
        If (m_contactFilter.ShouldCollide(fixtureA, fixtureB) = False)
            'Print "Abort as filtered"
            Return
        End
        '// Call the factory.
        Local c :b2Contact = m_contactFactory.Create(fixtureA, fixtureB)
        '// Contact creation may swap shapes.
        fixtureA = c.GetFixtureA()
        fixtureB = c.GetFixtureB()
        bodyA = fixtureA.m_body
        bodyB = fixtureB.m_body
        '// Insert into the world.
        c.m_prev = null
        c.m_next = m_world.m_contactList
        If (m_world.m_contactList <> null)
            
            m_world.m_contactList.m_prev = c
        End
        
        m_world.m_contactList = c
        '// Connect to island graph.
        '// Connect to body A
        c.m_nodeA.contact = c
        c.m_nodeA.other = bodyB
        c.m_nodeA.prevItem = null
        c.m_nodeA.nextItem = bodyA.m_contactList
        If (bodyA.m_contactList <> null)
            
            bodyA.m_contactList.prevItem = c.m_nodeA
        End
        
        bodyA.m_contactList = c.m_nodeA
        '// Connect to body 2
        c.m_nodeB.contact = c
        c.m_nodeB.other = bodyA
        c.m_nodeB.prevItem = null
        c.m_nodeB.nextItem = bodyB.m_contactList
        If (bodyB.m_contactList <> null)
            
            bodyB.m_contactList.prevItem = c.m_nodeB
        End
        
        bodyB.m_contactList = c.m_nodeB
        m_world.m_contactCount += 1
        'Print "Contact Added"
        
        Return
    End
    
    Method FindNewContacts : void ()
        m_broadPhase.UpdatePairs(pairsCallback)
    End
    
    Global s_evalCP:b2ContactPoint = New b2ContactPoint()
    
    Method Destroy : void (c:b2Contact)
        Local fixtureA :b2Fixture = c.GetFixtureA()
        Local fixtureB :b2Fixture = c.GetFixtureB()
        Local bodyA :b2Body = fixtureA.GetBody()
        Local bodyB :b2Body = fixtureB.GetBody()
        If (c.IsTouching())
            
            m_contactListener.EndContact(c)
        End
        '// Remove from the world.
        If (c.m_prev)
            
            c.m_prev.m_next = c.m_next
        End
        If (c.m_next)
            
            c.m_next.m_prev = c.m_prev
        End
        If (c = m_world.m_contactList)
            
            m_world.m_contactList = c.m_next
        End
        '// Remove from body A
        If (c.m_nodeA.prevItem)
            
            c.m_nodeA.prevItem.nextItem = c.m_nodeA.nextItem
        End
        If (c.m_nodeA.nextItem)
            
            c.m_nodeA.nextItem.prevItem = c.m_nodeA.prevItem
        End
        If (c.m_nodeA = bodyA.m_contactList)
            
            bodyA.m_contactList = c.m_nodeA.nextItem
        End
        '// Remove from body 2
        If (c.m_nodeB.prevItem)
            
            c.m_nodeB.prevItem.nextItem = c.m_nodeB.nextItem
        End
        If (c.m_nodeB.nextItem)
            
            c.m_nodeB.nextItem.prevItem = c.m_nodeB.prevItem
        End
        If (c.m_nodeB = bodyB.m_contactList)
            
            bodyB.m_contactList = c.m_nodeB.nextItem
        End
        '// Call the factory.
        m_contactFactory.Destroy(c)
        m_world.m_contactCount -= 1
        
    End
    '// the(This) top level collision call for the time timeStep. Here
    '// all the narrow phase processed(collision) for the world
    '// contact list.
    Method Collide : void ()
        
        '// Update awake contacts.
        Local c :b2Contact = m_world.m_contactList
        While (c <> Null)
            
            Local fixtureA :b2Fixture = c.GetFixtureA()
            Local fixtureB :b2Fixture = c.GetFixtureB()
            Local bodyA :b2Body = fixtureA.GetBody()
            Local bodyB :b2Body = fixtureB.GetBody()
            Local cNuke :b2Contact
            
            If (bodyA.IsAwake() = False And bodyB.IsAwake() = False)
                
                c = c.GetNext()
                Continue
            End
            '// Is this contact flagged for filtering?
            If (c.m_flags & b2Contact.e_filterFlag)
                
                '// Should these bodies collide?
                If (bodyB.ShouldCollide(bodyA) = False)
                    
                    cNuke = c
                    c = cNuke.GetNext()
                    Destroy(cNuke)
                    Continue
                End
                '// Check user filtering.
                If (m_contactFilter.ShouldCollide(fixtureA, fixtureB) = False)
                    
                    cNuke = c
                    c = cNuke.GetNext()
                    Destroy(cNuke)
                    Continue
                End
                '// Clear the filtering flag
                c.m_flags &= ~b2Contact.e_filterFlag
            End
            Local proxyA : Object = fixtureA.m_proxy
            Local proxyB : Object = fixtureB.m_proxy
            Local overlap :Bool = m_broadPhase.TestOverlap(proxyA, proxyB)
            '// Here we destroy contacts that cease to overlap in the broadphase
            If ( overlap = False)
                
                cNuke = c
                c = cNuke.GetNext()
                Destroy(cNuke)
                Continue
            End
            c.Update(m_contactListener)
            c = c.GetNext()
        End
    End
    
    Field m_world:b2World
    
    
    Field m_broadPhase:IBroadPhase
    
    
    Field m_contactList:b2Contact
    
    
    Field m_contactCount:Int
    
    
    Field m_contactFilter:b2ContactFilter
    
    
    Field m_contactListener:b2ContactListenerInterface
    
    
    Field m_contactFactory:b2ContactFactory
    
    
    Field m_allocator: Object
    
    
End




