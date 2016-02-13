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
'* A 2D column vector.
'*/
#end
Class b2Vec2
    

    Field x:Float
    Field y:Float
    
    Method New(x_:Float=0, y_:Float=0)
        x=x_
        y=y_
    End
    
    Method SetZero:Void()
        x = 0.0
        y = 0.0
    End
    
    Method Set:Void(x_:Float=0, y_:Float=0)
        x=x_
        y=y_
    End
    
    Method SetV:Void(v:b2Vec2)
        x=v.x
        y=v.y
    End
    
    Method GetNegative:Void(out:b2Vec2)
        out.Set(-x, -y)
    End
    
    Method NegativeSelf:Void()
        x = -x
        y = -y
    End
    
    Function Make : b2Vec2 (x_:Float, y_:Float)
        Return New b2Vec2(x_, y_)
    End
    
    Method Copy : b2Vec2 ()
        Return New b2Vec2(x,y)
    End
    
    Method Add:Void(v:b2Vec2)
        x += v.x
        y += v.y
    End
    
    Method Subtract:Void(v:b2Vec2)
        x -= v.x
        y -= v.y
    End
    
    Method Multiply:Void(a:Float)
        x *= a
        y *= a
    End
    
    Method MulM:Void(A:b2Mat22)
        Local tX :Float = x
        x = A.col1.x * tX + A.col2.x * y
        y = A.col1.y * tX + A.col2.y * y
    End
    
    Method MulTM:Void(A:b2Mat22)
        Local tX :Float = b2Math.Dot(Self, A.col1)
        y = b2Math.Dot(Self, A.col2)
        x = tX
    End
    
    Method CrossVF:Void(s:Float)
        Local tX :Float = x
        x = s * y
        y = -s * tX
    End
    
    Method CrossFV:Void(s:Float)
        Local tX :Float = x
        x = -s * y
        y = s * tX
    End
    
    Method MinV:Void(b:b2Vec2)
        If( x < b.x  )
            x = x
        Else
            x = b.x
        End
        
        If( y < b.y  )
            y = y
        Else
            y = b.y
        End
    End
    
    Method MaxV:Void(b:b2Vec2)
        If( x > b.x  )
            x = x
        Else
            x = b.x
        End
        
        If( y > b.y  )
            y = y
        Else
            y = b.y
        End
    End
    
    Method Abs:Void()
        If (x < 0)
            x = -x
        End
        If (y < 0)
            y = -y
        End
    End
    
    Method Length : Float ()
        Return Sqrt(x * x + y * y)
    End
    
    Method LengthSquared : Float ()
        Return (x * x + y * y)
    End
    
    Method Normalize : Float ()
        Local length :Float = Sqrt(x * x + y * y)
        If (length < Constants.EPSILON)
            Return 0.0
        End
        
        Local invLength :Float = 1.0 / length
        x *= invLength
        y *= invLength
        Return length
    End
    
    Method IsValid : Bool ()
        Return b2Math.IsValid(x) And b2Math.IsValid(y)
    End
   
    Method Equals:Bool( vec:b2Vec2 )
        Return vec <> Null And vec.x = x And vec.y = y 
    End
End

