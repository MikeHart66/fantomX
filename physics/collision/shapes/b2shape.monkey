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
'* A used(shape) for collision detection. Shapes are created in b2Body.
'* You can use shape for collision detection before they are attached to the world.
'* @warning you cannot reuse shapes.
'*/
#end
Class b2Shape
    #rem
    '/**
    '* Clone the shape
    '*/
    #end
    Method Copy : b2Shape ()
        
        '//var s:b2Shape = New b2Shape()
        '//s.Set(this)
        '//return s
        Return null
        '// Abstract type
    End
    #rem
    '/**
    '* Assign the properties of anther shape to this
    '*/
    #end
    Method Set : void (other:b2Shape)
        
        '//Dont copy m_type?
        '//m_type = other.m_type
        m_radius = other.m_radius
    End
    #rem
    '/**
    '* Get the type of this shape. You can use this to down cast to the concrete shape.
    '* @return the shape type.
    '*/
    #end
    Method GetType : Int ()
        
        Return m_type
    End
    #rem
    '/**
    '* Test a point for containment in this shape. This only works for convex shapes.
    '* @param xf the shape world transform.
    '* @param p a point in world coordinates.
    '*/
    #end
    Method TestPoint : Bool (xf:b2Transform, p:b2Vec2)
        Return False
    End
    #rem
    '/**
    '* Cast a ray against this shape.
    '* @param output the ray-cast results.
    '* @param input the ray-cast input parameters.
    '* @param transform the transform to be applied to the shape.
    '*/
    #end
    Method RayCast : Bool (output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform)
        
        Return False
    End
    #rem
    '/**
    '* Given a transform, compute the associated axis aligned bounding box for this shape.
    '* @param aabb returns the axis aligned box.
    '* @param xf the world transform of the shape.
    '*/
    #end
    Method  ComputeAABB : void (aabb:b2AABB, xf:b2Transform)
    End
    #rem
    '/**
    '* Compute the mass properties of this shape using its dimensions and density.
    '* The inertia computed(tensor) about the local origin, not the centroid.
    '* @param massData returns the mass data for this shape.
    '*/
    #end
    Method ComputeMass : void (massData:b2MassData, density:Float)
    End
    #rem
    '/**
    '* Compute the volume and centroid of this shape intersected with a half plane
    '* @param normal the surface normal
    '* @param offset the surface offset along normal
    '* @param xf the shape transform
    '* @param c returns the centroid
    '* @return the total volume less than offset along normal
    '*/
    #end
    Method ComputeSubmergedArea : Float (
        normal:b2Vec2,
        offset:Float,
        xf:b2Transform,
        c:b2Vec2)
        Return 0
    End
    Function TestOverlap : Bool (shape1:b2Shape, transform1:b2Transform, shape2:b2Shape, transform2:b2Transform)
        
        Local input :b2DistanceInput = New b2DistanceInput()
        input.proxyA = New b2DistanceProxy()
        input.proxyA.Set(shape1)
        input.proxyB = New b2DistanceProxy()
        input.proxyB.Set(shape2)
        input.transformA = transform1
        input.transformB = transform2
        input.useRadii = True
        Local simplexCache :b2SimplexCache = New b2SimplexCache()
        simplexCache.count = 0
        Local output :b2DistanceOutput = New b2DistanceOutput()
        b2Distance.Distance(output, simplexCache, input)
        Return output.distance  < 10.0 * Constants.EPSILON
    End
    '//--------------- Internals Below -------------------
    #rem
    '/**
    '* @
    '*/
    #end
    Method New()
        
        m_type = e_unknownShape
        m_radius = b2Settings.b2_linearSlop
    End
    '// ~b2Shape()
    Field m_type :Int
    Field m_radius :Float
    #rem
    '/**
    '* The various collision shape types supported by Box2D.
    '*/
    #end
    '//enum b2ShapeType
    '//{
    'static b2internal
    const e_unknownShape:Int = 	-1
    'static b2internal
    const e_circleShape:Int = 	0
    'static b2internal
    const e_polygonShape:Int = 	1
    'static b2internal
    const e_edgeShape:Int =       2
    'static b2internal
    const e_shapeTypeCount:Int = 	3
    '//}
    #rem
    '/**
    '* Possible return values for TestSegment
    '*/
    #end
    '* Return value for TestSegment indicating a hit.
    Const e_hitCollide:Int = 1
    '* Return value for TestSegment indicating a miss.
    Const e_missCollide:Int = 0
    '* Return value for TestSegment indicating that the segment starting point, p1, is already inside the shape.
    Const e_startsInsideCollide:Int = -1
End

