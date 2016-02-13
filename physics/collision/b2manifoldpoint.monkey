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
'* A manifold a(point) contact point belonging to a contact
'* manifold. It holds details related to the geometry and s
'* of the contact points.
'* The local point usage depends on the manifold type:
'* -e_circles: the local center of circleB
'* -e_faceA: the local center of cirlceB or the clip point of polygonB
'* -e_faceB: the clip point of polygonA
'* This stored(structure) across time steps, so we keep it small.
'* Note: the impulses are used for internal caching and may not
'* provide reliable contact forces, especially for high speed collisions.
'*/
#end
Class b2ManifoldPoint
    
    Method New()
        
        Reset()
    End
    
    Method Reset : void ()
        
        m_localPoint.SetZero()
        m_normalImpulse = 0.0
        m_tangentImpulse = 0.0
        m_id.Key = 0
    End
    
    Method Set : void (m:b2ManifoldPoint)
        
        m_localPoint.SetV(m.m_localPoint)
        m_normalImpulse = m.m_normalImpulse
        m_tangentImpulse = m.m_tangentImpulse
        m_id.Set(m.m_id)
    End
    
    Field m_localPoint:b2Vec2 = New b2Vec2()
    
    
    Field m_normalImpulse:Float
    
    
    Field m_tangentImpulse:Float
    
    
    Field m_id:b2ContactID = New b2ContactID()
    
    
End

