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

Class PolygonContactTypeFactory Extends ContactTypeFactory
    Method Create : b2Contact (allocator: Object)
        
        '//void* mem = allocator->Allocate(sizeof(b2PolyContact))
        Return New b2PolygonContact()
    End
    
    Method Destroy : void (contact:b2Contact, allocator: Object)
        
        '//((b2PolyContact*)contact)->~b2PolyContact()
        '//allocator->Free(contact, sizeof(b2PolyContact))
    End
End
Class b2PolygonContact Extends b2Contact
    
    Method New()
        Super.New()
    End
    Method Reset : void (fixtureA:b2Fixture, fixtureB:b2Fixture)
        
        Super.Reset(fixtureA, fixtureB)
        '//b2Settings.B2Assert(m_shape1.m_type = b2Shape.e_polygonShape)
        '//b2Settings.B2Assert(m_shape2.m_type = b2Shape.e_polygonShape)
    End
    
    '//~b2PolyContact() {}
    Method Evaluate : void ()
        
        Local bA :b2Body = m_fixtureA.GetBody()
        Local bB :b2Body = m_fixtureB.GetBody()
        b2Collision.CollidePolygons(m_manifold,
        b2PolygonShape(m_fixtureA.GetShape()), bA.m_xf,
        b2PolygonShape(m_fixtureB.GetShape()), bB.m_xf)
    End
End


