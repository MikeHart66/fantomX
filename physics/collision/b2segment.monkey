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
'* A line in space between two given vertices.
'*/
#end
Class b2Segment
    #rem
    '/**
    '* Ray cast against this segment with another segment
    '* @param xf the shape world transform.
    '* @param lambda returns the hit fraction. You can use this to compute the contact point
    '* p = (1 - lambda) * segment.p1 + lambda * segment.p2.0
    '* @param normal returns the normal at the contact point. If no(there) intersection, the normal
    '* is not set.
    '* @param segment defines the begin and end point of the ray cast.
    '* @param maxLambda a number typically in the range [0,1].
    '* @return True if there was an intersection.
    '* @see Box2D.Collision.Shapes.b2Shape#TestSegment
    '*/
    #end
    '// Collision Detection in Interactive 3D Environments by Gino van den Bergen
    '// From Section 3.4.1
    '// x = mu1 * p1 + mu2 * p2
    '// mu1 + mu2 = 1 And mu1 >= 0 And mu2 >= 0
    '// mu1 = 1 - mu2
    '// x = (1 - mu2) * p1 + mu2 * p2
    '//   = p1 + mu2 * (p2 - p1)
    '// x = s + a * r (s := start, r := end - start)
    '// s + a * r = p1 + mu2 * d (d := p2 - p1)
    '// -a * r + mu2 * d = b (b := s - p1)
    '// [-r d] * [a; mu2] = b
    '// Cramers rule:
    '// denom = det.Get(-r d)
    '// a = det.Get(b d) / denom
    '// mu2 = det.Get(-r b) / denom
    Method TestSegment : Bool (lambda:FlashArray<FloatObject>,'// float pointer
        normal:b2Vec2,'// pointer
        segment:b2Segment,
        maxLambda:Float)
        
        '//b2Vec2 s = segment.p1
        Local s :b2Vec2 = segment.p1
        '//b2Vec2 r = segment.p2 - s
        Local rX :Float = segment.p2.x - s.x
        Local rY :Float = segment.p2.y - s.y
        '//b2Vec2 d = p2 - p1
        Local dX :Float = p2.x - p1.x
        Local dY :Float = p2.y - p1.y
        '//b2Vec2 n = b2Cross(d, 1.0f)
        Local nX :Float = dY
        Local nY :Float = -dX
        Local k_slop :Float = 100.0 * Constants.EPSILON
        '//var denom:Float = -b2Dot(r, n)
        Local denom :Float = -(rX*nX + rY*nY)
        '// Cull back facing collision and ignore parallel segments.
        If (denom > k_slop)
            
            '// Does the segment intersect the infinite line associated with this segment?
            '//b2Vec2 b = s - p1
            Local bX :Float = s.x - p1.x
            Local bY :Float = s.y - p1.y
            '//var a:Float = b2Dot(b, n)
            Local a :Float = (bX*nX + bY*nY)
            If (0.0 <= a And a <= maxLambda * denom)
                
                Local mu2 :Float = -rX * bY + rY * bX
                '// Does the segment intersect this segment?
                If (-k_slop * denom <= mu2 And mu2 <= denom * (1.0 + k_slop))
                    
                    a /= denom
                    '//n.Normalize()
                    Local nLen :Float = Sqrt(nX*nX + nY*nY)
                    nX /= nLen
                    nY /= nLen
                    '//lambda = a
                    lambda.Set( 0,  a )
                    '//normal = n
                    normal.Set(nX, nY)
                    Return True
                End
            End
        End
        Return False
    End
    '/**
    '* Extends or clips the segment so that its ends lie on the boundary of the AABB
    '*/
    
    Method Extend : void (aabb:b2AABB)
        
        ExtendForward(aabb)
        ExtendBackward(aabb)
    End
    #rem
    '/**
    '* @see Extend
    '*/
    #end
    Method ExtendForward : void (aabb:b2AABB)
        
        Local dX :Float = p2.x-p1.x
        Local dY :Float = p2.y-p1.y
        Local lambda :Float
        Local a:Float = Constants.FMAX
        If dX>0
            a = (aabb.upperBound.x-p1.x)/dX
        Else
            If( dX<0 )
                a = (aabb.lowerBound.x-p1.x)/dX
            End
        End
        Local b:Float = Constants.FMAX
        If dY>0
            b = (aabb.upperBound.y-p1.y)/dY
        Else
            If( dY<0 )
                b = (aabb.lowerBound.y-p1.y)/dY
            End
        End
        
        lambda = b2Math.Min(a,b)
        
        p2.x = p1.x + dX * lambda
        p2.y = p1.y + dY * lambda
    End
    #rem
    '/**
    '* @see Extend
    '*/
    #end
    Method ExtendBackward : void (aabb:b2AABB)
        
        Local dX :Float = -p2.x+p1.x
        Local dY :Float = -p2.y+p1.y
        Local lambda :Float
        Local a:Float = Constants.FMAX
        If dX>0
            a = (aabb.upperBound.x-p2.x)/dX
        Else
            If( dX<0 )
                a = (aabb.lowerBound.x-p2.x)/dX
            End
        End
        Local b:Float = Constants.FMAX
        If dY>0
            b = (aabb.upperBound.y-p2.y)/dY
        Else
            If( dY<0 )
                b = (aabb.lowerBound.y-p2.y)/dY
            End
        End
        
        lambda = b2Math.Min(a,b)
        
        p1.x = p2.x + dX * lambda
        p1.y = p2.y + dY * lambda
    End
    '* The starting point
    Field p1:b2Vec2 = New b2Vec2()
    
    
    '* The ending point
    Field p2:b2Vec2 = New b2Vec2()
    
    
End

