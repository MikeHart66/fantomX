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
'* This class manages creation and destruction of b2Contact objects.
'* @
'*/
#end
Class b2ContactFactory
    
    Method New(allocator: Object)
        m_allocator = allocator
        InitializeRegisters()
    End
    
    Method AddType : void (contactTypeFactory:ContactTypeFactory, type1:Int, type2:Int)
        
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type1 And type1 < b2Shape.e_shapeTypeCount)
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type2 And type2 < b2Shape.e_shapeTypeCount)
        m_registers.Get(type1).Get(type2).contactTypeFactory = contactTypeFactory
        m_registers.Get(type1).Get(type2).primary = True
        
        If (type1 <> type2)
            m_registers.Get(type2).Get(type1).contactTypeFactory = contactTypeFactory
            m_registers.Get(type2).Get(type1).primary = False
        End
    End
    
    Method InitializeRegisters : void ()
        
        m_registers = New FlashArray<FlashArray<b2ContactRegister> >(b2Shape.e_shapeTypeCount)
        For Local i:Int = 0 Until b2Shape.e_shapeTypeCount
            
            m_registers.Set( i,  New FlashArray<b2ContactRegister>(b2Shape.e_shapeTypeCount) )
            For Local j:Int = 0 Until b2Shape.e_shapeTypeCount
                
                m_registers.Get(i).Set( j,  New b2ContactRegister() )
            End
        End
        AddType(New CircleContactTypeFactory(), b2Shape.e_circleShape, b2Shape.e_circleShape)
        AddType(New PolyAndCircleContactTypeFactory(), b2Shape.e_polygonShape, b2Shape.e_circleShape)
        AddType(New PolygonContactTypeFactory(), b2Shape.e_polygonShape, b2Shape.e_polygonShape)
        AddType(New EdgeAndCircleContactTypeFactory(), b2Shape.e_edgeShape, b2Shape.e_circleShape)
        AddType(New PolyAndEdgeContactTypeFactory(), b2Shape.e_polygonShape, b2Shape.e_edgeShape)
    End
    
    Method Create : b2Contact (fixtureA:b2Fixture, fixtureB:b2Fixture)
        
        Local type1 :Int = fixtureA.GetType()
        Local type2 :Int = fixtureB.GetType()
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type1 And type1 < b2Shape.e_shapeTypeCount)
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type2 And type2 < b2Shape.e_shapeTypeCount)
        Local reg :b2ContactRegister = m_registers.Get(type1).Get(type2)
        Local c :b2Contact
        If (reg.pool)
            
            '// Pop a contact off the pool
            c = reg.pool
            reg.pool = c.m_next
            reg.poolCount -= 1
            If c.m_swapped
                c.Reset(fixtureB, fixtureA)
            Else
                c.Reset(fixtureA, fixtureB)
            End
            Return c
        End
        Local contactTypeFactory :ContactTypeFactory = reg.contactTypeFactory
        If (contactTypeFactory <> null)
            
            If (reg.primary)
                c = contactTypeFactory.Create(m_allocator)
                c.Reset(fixtureA, fixtureB)
                c.m_swapped = False
                Return c
            Else
                c = contactTypeFactory.Create(m_allocator)
                c.Reset(fixtureB, fixtureA)
                c.m_swapped = True
                Return c
            End
            
        Else
            Return null
        End
    End
    
    Method Destroy : void (contact:b2Contact)
        
        If (contact.m_manifold.m_pointCount > 0)
            
            contact.m_fixtureA.m_body.SetAwake(True)
            contact.m_fixtureB.m_body.SetAwake(True)
        End
        Local type1 :Int = contact.m_fixtureA.GetType()
        Local type2 :Int = contact.m_fixtureB.GetType()
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type1 And type1 < b2Shape.e_shapeTypeCount)
        '//b2Settings.B2Assert(b2Shape.e_unknownShape < type2 And type2 < b2Shape.e_shapeTypeCount)
        Local reg:b2ContactRegister
        
        If contact.m_swapped
            reg = m_registers.Get(type2).Get(type1)
        Else
            reg = m_registers.Get(type1).Get(type2)
        End
        
        If (True)
            
            reg.poolCount += 1
            contact.m_next = reg.pool
            reg.pool = contact
        End
        Local contactTypeFactory:ContactTypeFactory = reg.contactTypeFactory
        contactTypeFactory.Destroy(contact, m_allocator)
    End
    Field m_registers:FlashArray<FlashArray<b2ContactRegister> >
    
    
    Field m_allocator: Object
    
    
End




