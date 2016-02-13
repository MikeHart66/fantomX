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
'* This describes the motion of a body/shape for TOI computation.
'* Shapes are defined with respect to the body origin, which may
'* no coincide with the center of mass. However, to support s
'* we must interpolate the center of mass position.
'*/
#end
Class b2Sweep
    
    Method Set : void (other:b2Sweep)
        
        localCenter.SetV(other.localCenter)
        c0.SetV(other.c0)
        c.SetV(other.c)
        a0 = other.a0
        a = other.a
        t0 = other.t0
    End
    Method Copy : b2Sweep ()
        
        Local copy :b2Sweep = New b2Sweep()
        copy.localCenter.SetV(localCenter)
        copy.c0.SetV(c0)
        copy.c.SetV(c)
        copy.a0 = a0
        copy.a = a
        copy.t0 = t0
        Return copy
    End
    #rem
    '/**
    '* Get the interpolated transform at a specific time.
    '* @param a(alpha) factor in [0,1], where 0 indicates t0.0
    '*/
    #end
    Method GetTransform : void (xf:b2Transform, alpha:Float)
        
        xf.position.x = (1.0 - alpha) * c0.x + alpha * c.x
        xf.position.y = (1.0 - alpha) * c0.y + alpha * c.y
        Local angle :Float = (1.0 - alpha) * a0 + alpha * a
        xf.R.Set(angle)
        '// Shift to origin
        '//xf->position -= b2Mul(xf->R, localCenter)
        Local tMat :b2Mat22 = xf.R
        xf.position.x -= (tMat.col1.x * localCenter.x + tMat.col2.x * localCenter.y)
        xf.position.y -= (tMat.col1.y * localCenter.x + tMat.col2.y * localCenter.y)
    End
    #rem
    '/**
    '* Advance the sweep forward, yielding a New initial state.
    '* @param t the New initial time.
    '*/
    #end
    Method Advance : void (t:Float)
        
        If (t0 < t And 1.0 - t0 > Constants.EPSILON)
            
            Local alpha :Float = (t - t0) / (1.0 - t0)
            '//c0 = (1.0f - alpha) * c0 + alpha * c
            c0.x = (1.0 - alpha) * c0.x + alpha * c.x
            c0.y = (1.0 - alpha) * c0.y + alpha * c.y
            a0 = (1.0 - alpha) * a0 + alpha * a
            t0 = t
        End
    End
    '* Local center of mass position
    Field localCenter:b2Vec2 = New b2Vec2()
    
    '* Center world position
    Field c0:b2Vec2 = New b2Vec2
    
    '* Center world position
    Field c:b2Vec2 = New b2Vec2()
    
    '* World angle
    Field a0:Float
    
    '* World angle
    Field a:Float
    
    '* Time interval = [t0,1], where in(t0) [0,1]
    Field t0:Float
    
End
