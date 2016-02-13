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
'* A manifold for two touching convex shapes.
'* Box2D supports multiple types of contact:
'* - clip point versus plane with radius
'* - point versus point with radius (circles)
'* The local point usage depends on the manifold type:
'* -e_circles: the local center of circleA
'* -e_faceA: the center of faceA
'* -e_faceB: the center of faceB
'* Similarly the local normal usage:
'* -e_circles: not used
'* -e_faceA: the normal on polygonA
'* -e_faceB: the normal on polygonB
'* We store contacts in this way so that position correction can
'* account for movement, critical(which) for continuous physics.
'* All contact scenarios must be expressed in one of these types.
'* This stored(structure) across time steps, so we keep it small.
'*/
#end
Class b2Manifold
    
    '* The points of contact
    Field m_points:b2ManifoldPoint[]
    
    '* Not used for Type e_points
    Field m_localPlaneNormal:b2Vec2
    
    '* Usage depends on manifold type
    Field m_localPoint:b2Vec2
    
    Field m_type:Int
    
    '* The number of manifold points
    Field m_pointCount:Int = 0
    '//enum Type
    Const e_circles:Int = $0001
    Const e_faceA:Int = $0002
    Const e_faceB:Int = $0004
        
    Method New()
        
        m_points = New b2ManifoldPoint[b2Settings.b2_maxManifoldPoints]
        
        For Local i:Int = 0 Until b2Settings.b2_maxManifoldPoints
            m_points[i] = New b2ManifoldPoint()
        End
        
        m_localPlaneNormal = New b2Vec2()
        m_localPoint = New b2Vec2()
    End
    
    Method Reset : void ()
        
        For Local i:Int = 0 Until b2Settings.b2_maxManifoldPoints
            b2ManifoldPoint(m_points[i]).Reset()
        End
        
        m_localPlaneNormal.SetZero()
        m_localPoint.SetZero()
        m_type = 0
        m_pointCount = 0
    End
    
    Method Set : void (m:b2Manifold)
        
        m_pointCount = m.m_pointCount
        For Local i:Int = 0 Until b2Settings.b2_maxManifoldPoints
            b2ManifoldPoint(m_points[i]).Set(m.m_points[i])
        End
        
        m_localPlaneNormal.SetV(m.m_localPlaneNormal)
        m_localPoint.SetV(m.m_localPoint)
        m_type = m.m_type
    End
    
    Method Copy : b2Manifold ()
        
        Local copy :b2Manifold = New b2Manifold()
        copy.Set(Self)
        Return copy
    End

End
