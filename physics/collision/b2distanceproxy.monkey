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
'* A distance used(proxy) by the GJK algorithm.
'* It encapsulates any shape.
'*/
#end
Class b2DistanceProxy
    Field m_vertices:b2Vec2[]
    Field m_count:Int
    Field m_radius:Float
        
    #rem
    '/**
    '* Initialize the proxy using the given shape. The shape
    '* must remain in scope while the in(proxy) use.
    '*/
    #end
    Method Set : void (shape:b2Shape)
        
        Select(shape.GetType())
            
            Case b2Shape.e_circleShape
                
                Local circle :b2CircleShape = b2CircleShape(shape)
                m_vertices = New b2Vec2[1]
                m_vertices[0] = circle.m_p
                m_count = 1
                m_radius = circle.m_radius
            Case b2Shape.e_polygonShape
                
                Local polygon :b2PolygonShape =  b2PolygonShape(shape)
                m_vertices = polygon.m_vertices
                m_count = polygon.m_vertexCount
                m_radius = polygon.m_radius
                Default
                b2Settings.B2Assert(False)
        End
    End
    #rem
    '/**
    '* Get the supporting vertex index in the given direction.
    '*/
    #end
    Method GetSupport : Float (d:b2Vec2)
        
        Local bestIndex :Int = 0
        Local bestValue :Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y
        
        For Local i:Int = 1 Until m_count
            Local value :Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y
            If (value > bestValue)
                
                bestIndex = i
                bestValue = value
            End
        End
        
        Return bestIndex
    End
    #rem
    '/**
    '* Get the supporting vertex in the given direction.
    '*/
    #end
    Method GetSupportVertex : b2Vec2 (d:b2Vec2)
        
        Local bestIndex :Int = 0
        Local bestValue :Float = m_vertices[0].x * d.x + m_vertices[0].y * d.y
        For Local i:Int = 1 Until m_count
            
            Local value :Float = m_vertices[i].x * d.x + m_vertices[i].y * d.y
            If (value > bestValue)
                
                bestIndex = i
                bestValue = value
            End
        End
        
        Return m_vertices[bestIndex]
    End
    #rem
    '/**
    '* Get the vertex count.
    '*/
    #end
    Method GetVertexCount : Int ()
        
        Return m_count
    End
    #rem
    '/**
    '* Get a vertex by index. Used by b2Distance.
    '*/
    #end
    Method GetVertex : b2Vec2 (index:Int)
        
        b2Settings.B2Assert(0 <= index And index < m_count)
        Return m_vertices[index]
    End
   
End
    
    
