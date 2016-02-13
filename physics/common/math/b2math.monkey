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
Class b2Math
    #rem
    '/**
    '* This used(Method) to ensure that a floating point number is
    '* not a NaN or infinity.
    '*/
    #end
    Function IsValid : Bool (x:Float)
        Return x <= Constants.FMAX And x >= Constants.FMIN
    End
    #rem
    '/*Function b2InvSqrt : Float (x:Float){
    'union
    '
    'float32 x
    'int32 i
    'End
    'convert
    '
    'convert.x = x
    'float32 xhalf = 0.5f * x
    'convert.i = $5f3759df - (convert.i Shr 1)
    'x = convert.x
    'x = x * (1.5f - xhalf * x * x)
    'return x
    'End
    '*/
    '
    '
    #end
    Function Dot : Float (a:b2Vec2, b:b2Vec2)
        Return a.x * b.x + a.y * b.y
    End
    
    Function CrossVV : Float (a:b2Vec2, b:b2Vec2)
        Return a.x * b.y - a.y * b.x
    End
    
    Function CrossVF:Void (a:b2Vec2, s:Float, out:b2Vec2)
        Local tmp:Float = a.x
        out.x = s * a.y
        out.y = -s * tmp
    End
    
    Function CrossFV:Void (s:Float, a:b2Vec2, out:b2Vec2)
        Local tmp:Float = a.x
        out.x = -s * a.y
        out.y = s * tmp
    End
    
    Function MulMV:Void (A:b2Mat22, v:b2Vec2, out:b2Vec2)
        Local tmp:Float =  A.col1.y * v.x + A.col2.y * v.y
        out.x = A.col1.x * v.x + A.col2.x * v.y
        out.y = tmp
    End
    
    Function MulTMV:Void (A:b2Mat22, v:b2Vec2, out:b2Vec2)
        Local tmp:Float = Dot(v, A.col2)
        out.x = Dot(v, A.col1)
        out.y = tmp
    End
    
    Function MulX:Void (T:b2Transform, v:b2Vec2, out:b2Vec2)
        MulMV(T.R, v, out)
        out.x += T.position.x
        out.y += T.position.y
    End

    Function MulXT:Void (T:b2Transform, v:b2Vec2, out:b2Vec2)
        SubtractVV(v, T.position, out)
        '//return b2MulT(T.R, v - T.position)
        Local tX :Float = (out.x * T.R.col1.x + out.y * T.R.col1.y )
        out.y = (out.x * T.R.col2.x + out.y * T.R.col2.y )
        out.x = tX
    End
    
    Function AddVV:Void(a:b2Vec2, b:b2Vec2,out:b2Vec2)
        out.x = a.x + b.x
        out.y = a.y + b.y
    End
    
    Function SubtractVV:Void(a:b2Vec2, b:b2Vec2,out:b2Vec2)
        out.x = a.x - b.x
        out.y = a.y - b.y
    End
    
    Function Distance : Float (a:b2Vec2, b:b2Vec2)
        Local cX :Float = a.x-b.x
        Local cY :Float = a.y-b.y
        Return Sqrt(cX*cX + cY*cY)
    End
    
    Function DistanceSquared : Float (a:b2Vec2, b:b2Vec2)
        Local cX :Float = a.x-b.x
        Local cY :Float = a.y-b.y
        Return (cX*cX + cY*cY)
    End
    
    Function MulFV : b2Vec2 (s:Float, a:b2Vec2)
        Local v :b2Vec2 = New b2Vec2(s * a.x, s * a.y)
        Return v
    End
    
    Function AddMM : b2Mat22 (A:b2Mat22, B:b2Mat22)
        AddVV(A.col1, B.col1,tempVec)
        AddVV(A.col2, B.col2,tempVec2)
        Local C:b2Mat22 = b2Mat22.FromVV(tempVec,tempVec2)
        Return C
    End
    
    '// A * B
    Function MulMM : b2Mat22 (A:b2Mat22, B:b2Mat22)
        MulMV(A, B.col1, tempVec) 
        MulMV(A, B.col2, tempVec2)
        Local C:b2Mat22 = b2Mat22.FromVV(tempVec,tempVec2)
        Return C
    End
    
    '// A^T * B
    Function MulTMM : b2Mat22 (A:b2Mat22, B:b2Mat22)
        Local c1 :b2Vec2 = New b2Vec2(Dot(A.col1, B.col1), Dot(A.col2, B.col1))
        Local c2 :b2Vec2 = New b2Vec2(Dot(A.col1, B.col2), Dot(A.col2, B.col2))
        Local C :b2Mat22 = b2Mat22.FromVV(c1, c2)
        Return C
    End
    
    Function Abs : Float (a:Float)
        If( a > 0.0 )
            Return  a
        Else
            Return  -a
        End
    End
    
    Function AbsV:Void (a:b2Vec2, out:b2Vec2)
        out.x = Abs(a.x)
        out.y = Abs(a.y)
    End
    
    Function AbsM : b2Mat22 (A:b2Mat22)
        AbsV(A.col1,tempVec)
        AbsV(A.col2,tempVec2)
        Local B :b2Mat22 = b2Mat22.FromVV(tempVec,tempVec2)
        Return B
    End
    
    Function Round:Int( f : Float )
        If( Ceil(f) - f > f - Floor(f))
            Return Floor(f)
        Else
            Return Ceil(f)
        End
    End
    
    Function Min : Float (a:Float, b:Float)
        If( a < b  )
            Return  a
        Else
            Return  b
        End
    End
    
    Function MinV : b2Vec2 (a:b2Vec2, b:b2Vec2)
        Local c :b2Vec2 = New b2Vec2(Min(a.x, b.x), Min(a.y, b.y))
        Return c
    End
    
    Function Max : Float (a:Float, b:Float)
        If( a > b  )
            Return  a
        Else
            Return  b
        End
    End
    
    Function MaxV : b2Vec2 (a:b2Vec2, b:b2Vec2)
        Local c :b2Vec2 = New b2Vec2(Max(a.x, b.x), Max(a.y, b.y))
        Return c
    End
    
    Function Clamp : Float (a:Float, low:Float, high:Float)
        If( a < low  )
            Return  low
        Else
            If( a > high )
                Return high
            Else
                Return a
            End
        End
    
    End
    
    Function ClampV : b2Vec2 (a:b2Vec2, low:b2Vec2, high:b2Vec2)
        Return MaxV(low, MinV(a, high))
    End
    
    Function Swap : void (a:FlashArray<Object>, b:FlashArray<Object>)
        Local tmp : Object = a.Get(0)
        a.Set( 0,  b.Get(0) )
        b.Set( 0,  tmp )
    End
    
    '// b2Random number in range [-1,1]
    Function Random : Float ()
        Return Rnd() * 2 - 1
    End
    
    Function RandomRange : Float (lo:Float, hi:Float)
        Local r :Float = Rnd()
        r = (hi - lo) * r + lo
        Return r
    End
    
    '// "Next Largest Power of 2
    '// Given a binary integer value x, the nextItem largest power of 2 can be computed by a SWAR algorithm
    '// that recursively "folds" the upper bits into the lower bits. This process yields a bit vector with
    '// the same most significant x(1), but all 1s below it. Adding 1 to that value yields the nextItem
    '// largest power of 2.0 For a 32-bit value:"
    Function NextPowerOfTwo : Int (x:Int)
        x |= (x Shr 1) & $7FFFFFFF
        x |= (x Shr 2) & $3FFFFFFF
        x |= (x Shr 4) & $0FFFFFFF
        x |= (x Shr 8) & $00FFFFFF
        x |= (x Shr 16)& $0000FFFF
        Return x + 1
    End
    
    Function IsPowerOfTwo : Bool (x:Int)
        Local result :Bool = x > 0 And (x & (x - 1)) = 0
        Return result
    End
    
    '// Temp vector Methods to reduce calls to New
    Global tempVec:b2Vec2 = New b2Vec2()
    Global tempVec2:b2Vec2 = New b2Vec2()
    #rem
    '/*static  var tempVec:b2Vec2 = New b2Vec2()
    '
    'Global tempVec3:b2Vec2 = New b2Vec2()
    'Global tempVec4:b2Vec2 = New b2Vec2()
    'Global tempVec5:b2Vec2 = New b2Vec2()
    'Global tempMat:b2Mat22 = New b2Mat22()
    'Global tempAABB:b2AABB = New b2AABB()
    '*/
    #end
    Global b2Vec2_zero:b2Vec2 = New b2Vec2(0.0, 0.0)
    Global b2Mat22_identity:b2Mat22 = b2Mat22.FromVV(New b2Vec2(1.0, 0.0), New b2Vec2(0.0, 1.0))
    Global b2Transform_identity:b2Transform = New b2Transform(b2Vec2_zero, b2Mat22_identity)
End


