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

Class b2Simplex
    

    Field m_v1:b2SimplexVertex = New b2SimplexVertex()
    Field m_v2:b2SimplexVertex = New b2SimplexVertex()
    Field m_v3:b2SimplexVertex = New b2SimplexVertex()
    Field m_vertices:b2SimplexVertex[] = New b2SimplexVertex[3]
    Field m_count:Int
    Global tmpVec1:b2Vec2 = New b2Vec2()
    Global tmpVec2:b2Vec2 = New b2Vec2()
    Global tmpVec3:b2Vec2 = New b2Vec2()
    
    Method New()        
        m_vertices[0] = m_v1
        m_vertices[1] = m_v2
        m_vertices[2] = m_v3
    End
    
    Method ReadCache : void (cache:b2SimplexCache,
        proxyA:b2DistanceProxy, transformA:b2Transform,
        proxyB:b2DistanceProxy, transformB:b2Transform)
        
#If CONFIG = "debug"
        b2Settings.B2Assert(0 <= cache.count And cache.count <= 3)
#End
        Local wALocal :b2Vec2
        Local wBLocal :b2Vec2
        Local v :b2SimplexVertex
        '// Copy data from cache.
        m_count = cache.count
        Local vertices:b2SimplexVertex[] = m_vertices
        For Local i:Int = 0 Until m_count
            v = vertices[i]
            v.indexA = cache.indexA[i]
            v.indexB = cache.indexB[i]
            wALocal = proxyA.GetVertex(v.indexA)
            wBLocal = proxyB.GetVertex(v.indexB)
            b2Math.MulX(transformA, wALocal, v.wA)
            b2Math.MulX(transformB, wBLocal, v.wB)
            b2Math.SubtractVV(v.wB, v.wA, v.w)
            v.a = 0
        End
        '// Compute the New simplex metric, if it substantially different than
        '// old metric then flush the simplex
        If (m_count > 1)
            
            Local metric1 :Float = cache.metric
            Local metric2 :Float = GetMetric()
            If (metric2 < 0.5 * metric1 Or 2.0 * metric1 < metric2 Or metric2 < Constants.EPSILON)
                
                '// Reset the simplex
                m_count = 0
            End
        End
        '// If the empty(cache) or invalid
        If (m_count = 0)
            
            v = vertices[0]
            v.indexA = 0
            v.indexB = 0
            wALocal = proxyA.GetVertex(0)
            wBLocal = proxyB.GetVertex(0)
            b2Math.MulX(transformA, wALocal, v.wA)
            b2Math.MulX(transformB, wBLocal, v.wB)
            b2Math.SubtractVV(v.wB, v.wA, v.w)
            m_count = 1
        End
    End
    
    Method WriteCache : void (cache:b2SimplexCache)
        
        cache.metric = GetMetric()
        cache.count = m_count
        Local vertices:b2SimplexVertex[] = m_vertices
        For Local i:Int = 0 Until m_count
            cache.indexA[i] = vertices[i].indexA
            cache.indexB[i] = vertices[i].indexB
        End
    End

    Method GetSearchDirection:Void(out:b2Vec2)
        
        Select(m_count)
            
            Case 1
                m_v1.w.GetNegative(out)
            Case 2
                b2Math.SubtractVV(m_v2.w, m_v1.w, out)
			    m_v1.w.GetNegative(tmpVec1)
                Local sgn:Float = b2Math.CrossVV(out, tmpVec1)
                
                If (sgn > 0.0)
                    '// left(Origin) of e12.0
                    b2Math.CrossFV(1.0, out, out)
                Else
                    '// right(Origin) of e12.0
                    b2Math.CrossVF(out, 1.0, out)
                End
                
            Default
                b2Settings.B2Assert(False)
                out.Set(0.0,0.0)
        End
    End
    
    Method GetClosestPoint:Void(out:b2Vec2)
        
        Select(m_count)
            
            Case 0
                b2Settings.B2Assert(False)
                out.x = 0.0
                out.y = 0.0
            Case 1
                out.x = m_v1.w.x
                out.y = m_v1.w.y
            Case 2
                out.x = m_v1.a * m_v1.w.x + m_v2.a * m_v2.w.x
                out.y = m_v1.a * m_v1.w.y + m_v2.a * m_v2.w.y
            Default
                b2Settings.B2Assert(False)
                out.x = 0.0
                out.y = 0.0
        End
    End
    
    Method GetWitnessPoints : void (pA:b2Vec2, pB:b2Vec2)
        
        Select(m_count)
            
            Case 0
                b2Settings.B2Assert(False)
            Case 1
                pA.SetV(m_v1.wA)
                pB.SetV(m_v1.wB)
            Case 2
                pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x
                pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y
                pB.x = m_v1.a * m_v1.wB.x + m_v2.a * m_v2.wB.x
                pB.y = m_v1.a * m_v1.wB.y + m_v2.a * m_v2.wB.y
            Case 3
                pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x + m_v3.a * m_v3.wA.x
                pB.x = pA.x
                pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y + m_v3.a * m_v3.wA.y
                pB.y = pA.y
                Default
                b2Settings.B2Assert(False)
        End
    End
    
    Method GetMetric : Float ()
        
        Select (m_count)
            Case 0
                b2Settings.B2Assert(False)
                Return 0.0
            Case 1
                Return 0.0
            Case 2
                b2Math.SubtractVV(m_v1.w, m_v2.w,tmpVec1)
                Return tmpVec1.Length()
            Case 3
                b2Math.SubtractVV(m_v2.w, m_v1.w, tmpVec1)
                b2Math.SubtractVV(m_v3.w, m_v1.w, tmpVec2)
                Return b2Math.CrossVV(tmpVec1,tmpVec2)
            
            Default
                b2Settings.B2Assert(False)
                Return 0.0
        End
    End
    '// Solve a line segment using barycentric coordinates.
    '//
    '// p = a1 * w1 + a2 * w2
    '// a1 + a2 = 1
    '//
    '// The vector from the origin to the closest point on the line is
    '// perpendicular to the line.
    '// e12 = w2 - w1
    '// dot(p, e) = 0
    '// a1 * dot(w1, e) + a2 * dot(w2, e) = 0
    '//
    '// 2-by-2 linear system
    '// [1      1     ][a1] = [1]
    '// [w1.e12 w2.e12][a2] = [0]
    '//
    '// Define
    '// d12_1 =  dot(w2, e12)
    '// d12_2 = -dot(w1, e12)
    '// d12 = d12_1 + d12_2
    '//
    '// Solution
    '// a1 = d12_1 / d12
    '// a2 = d12_2 / d12
    Method Solve2 : void ()
        
        Local w1 :b2Vec2 = m_v1.w
        Local w2 :b2Vec2 = m_v2.w
        b2Math.SubtractVV(w2, w1, tmpVec1)
        Local e12 :b2Vec2 = tmpVec1
        '// w1 region
        Local d12_2 :Float = -(w1.x * e12.x + w1.y * e12.y)
        If (d12_2 <= 0.0)
            
            '// a2 <= 0, so we clamp it to 0
            m_v1.a = 1.0
            m_count = 1
            Return
        End
        '// w2 region
        Local d12_1 :Float = (w2.x * e12.x + w2.y * e12.y)
        If (d12_1 <= 0.0)
            
            '// a1 <= 0, so we clamp it to 0
            m_v2.a = 1.0
            m_count = 1
            m_v1.Set(m_v2)
            Return
        End
        '// Must be in e12 region.
        Local inv_d12 :Float = 1.0 / (d12_1 + d12_2)
        m_v1.a = d12_1 * inv_d12
        m_v2.a = d12_2 * inv_d12
        m_count = 2
    End
    
    Method Solve3 : void ()
        Local w1 :b2Vec2 = m_v1.w
        Local w2 :b2Vec2 = m_v2.w
        Local w3 :b2Vec2 = m_v3.w
        '// Edge12
        '// [1      1     ][a1] = [1]
        '// [w1.e12 w2.e12][a2] = [0]
        '// a3 = 0
        b2Math.SubtractVV(w2, w1, tmpVec1)
        Local e12 :b2Vec2 = tmpVec1
        Local w1e12:Float = b2Math.Dot(w1, e12)
        Local w2e12:Float = b2Math.Dot(w2, e12)
        Local d12_1 :Float = w2e12
        Local d12_2 :Float = -w1e12
        '// Edge13
        '// [1      1     ][a1] = [1]
        '// [w1.e13 w3.e13][a3] = [0]
        '// a2 = 0
        b2Math.SubtractVV(w3, w1, tmpVec2)
        Local e13 :b2Vec2 = tmpVec2 
        Local w1e13:Float = b2Math.Dot(w1, e13)
        Local w3e13:Float = b2Math.Dot(w3, e13)
        Local d13_1 :Float = w3e13
        Local d13_2 :Float = -w1e13
        '// Edge23
        '// [1      1     ][a2] = [1]
        '// [w2.e23 w3.e23][a3] = [0]
        '// a1 = 0
        b2Math.SubtractVV(w3, w2, tmpVec3)
        Local e23 :b2Vec2 = tmpVec3
        Local w2e23:Float = b2Math.Dot(w2, e23)
        Local w3e23:Float = b2Math.Dot(w3, e23)
        Local d23_1 :Float = w3e23
        Local d23_2 :Float = -w2e23
        '// Triangle123
        Local n123 :Float = b2Math.CrossVV(e12, e13)
        Local d123_1 :Float = n123 * b2Math.CrossVV(w2, w3)
        Local d123_2 :Float = n123 * b2Math.CrossVV(w3, w1)
        Local d123_3 :Float = n123 * b2Math.CrossVV(w1, w2)
        '// w1 region
        If (d12_2 <= 0.0 And d13_2 <= 0.0)
            
            m_v1.a = 1.0
            m_count = 1
            Return
        End
        '// e12
        If (d12_1 > 0.0 And d12_2 > 0.0 And d123_3 <= 0.0)
            
            Local inv_d12 :Float = 1.0 / (d12_1 + d12_2)
            m_v1.a = d12_1 * inv_d12
            m_v2.a = d12_2 * inv_d12
            m_count = 2
            Return
        End
        '// e13
        If (d13_1 > 0.0 And d13_2 > 0.0 And d123_2 <= 0.0)
            
            Local inv_d13 :Float = 1.0 / (d13_1 + d13_2)
            m_v1.a = d13_1 * inv_d13
            m_v3.a = d13_2 * inv_d13
            m_count = 2
            m_v2.Set(m_v3)
            Return
        End
        '// w2 region
        If (d12_1 <= 0.0 And d23_2 <= 0.0)
            
            m_v2.a = 1.0
            m_count = 1
            m_v1.Set(m_v2)
            Return
        End
        '// w3 region
        If (d13_1 <= 0.0 And d23_1 <= 0.0)
            
            m_v3.a = 1.0
            m_count = 1
            m_v1.Set(m_v3)
            Return
        End
        '// e23
        If (d23_1 > 0.0 And d23_2 > 0.0 And d123_1 <= 0.0)
            
            Local inv_d23 :Float = 1.0 / (d23_1 + d23_2)
            m_v2.a = d23_1 * inv_d23
            m_v3.a = d23_2 * inv_d23
            m_count = 2
            m_v1.Set(m_v3)
            Return
        End
        '// Must be in triangle123
        Local inv_d123 :Float = 1.0 / (d123_1 + d123_2 + d123_3)
        m_v1.a = d123_1 * inv_d123
        m_v2.a = d123_2 * inv_d123
        m_v3.a = d123_3 * inv_d123
        m_count = 3
    End
    
End


    
    
