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
Class b2TimeOfImpact
    Global b2_toiCalls:Int = 0
    Global b2_toiIters:Int = 0
    Global b2_toiMaxIters:Int = 0
    Global b2_toiRootIters:Int = 0
    Global b2_toiMaxRootIters:Int = 0
    Global s_cache:b2SimplexCache = New b2SimplexCache()
    Global s_distanceInput:b2DistanceInput = New b2DistanceInput()
    Global s_xfA:b2Transform = New b2Transform()
    Global s_xfB:b2Transform = New b2Transform()
    Global s_fcn:b2SeparationFunction = New b2SeparationFunction()
    Global s_distanceOutput:b2DistanceOutput = New b2DistanceOutput()
    Function TimeOfImpact : Float (input:b2TOIInput)
        
        b2_toiCalls += 1
        
        Local proxyA :b2DistanceProxy = input.proxyA
        Local proxyB :b2DistanceProxy = input.proxyB
        Local sweepA :b2Sweep = input.sweepA
        Local sweepB :b2Sweep = input.sweepB
#If CONFIG = "debug"
        b2Settings.B2Assert(sweepA.t0 = sweepB.t0)
        b2Settings.B2Assert(1.0 - sweepA.t0 > Constants.EPSILON)
#End
        Local radius :Float = proxyA.m_radius + proxyB.m_radius
        Local tolerance :Float = input.tolerance
        Local alpha :Float = 0.0
        const k_maxIterations:Int = 1000
        '//TODO_ERIN b2Settings
        Local iter :Int = 0
        Local target :Float = 0.0
        '// Prepare input for distance query.
        s_cache.count = 0
        s_distanceInput.useRadii = False
        While True
            
            sweepA.GetTransform(s_xfA, alpha)
            sweepB.GetTransform(s_xfB, alpha)
            '// Get the distance between shapes
            s_distanceInput.proxyA = proxyA
            s_distanceInput.proxyB = proxyB
            s_distanceInput.transformA = s_xfA
            s_distanceInput.transformB = s_xfB
            b2Distance.Distance(s_distanceOutput, s_cache, s_distanceInput)
            If (s_distanceOutput.distance <= 0.0)
                
                alpha = 1.0
                Exit
            End
            s_fcn.Initialize(s_cache, proxyA, sweepA, proxyB, sweepB, alpha)
            Local separation :Float = s_fcn.Evaluate(s_xfA, s_xfB)
            If (separation <= 0.0)
                
                alpha = 1.0
                Exit
            End
            If (iter = 0)
                
                '// Compute a reasonable target distance to give some breathing room
                '// for conservative advancement. We take advantage of the shape radii
                '// to create additional clearance
                If (separation > radius)
                    
                    target = b2Math.Max(radius - tolerance, 0.75 * radius)
                Else
                    
                    
                    target = b2Math.Max(separation - tolerance, 0.02 * radius)
                End
            End
            If (separation - target < 0.5 * tolerance)
                
                If (iter = 0)
                    
                    alpha = 1.0
                    Exit
                End
                
                Exit
            End
            '//#if 0
            '// Dump the curve seen by the root finder
            '//{
            '//const N:Int = 100
            '//var dx:Float = 1.0 / N
            '//var xs:FlashArray<FloatObject> = New Array(N + 1)
            '//var fs:FlashArray<FloatObject> = New Array(N + 1)
            '//
            '//var x:Float = 0.0
            '//For Local i:Int = 0 Until = N
            '//{
            '//sweepA.GetTransform(xfA, x)
            '//sweepB.GetTransform(xfB, x)
            '//var f:Float = fcn.Evaluate(xfA, xfB) - target
            '//
            '//trace(x, f)
            '//xs.Set( i,  x )
            '//fx.Set( i,  f )
            '//
            '//x += dx
            '//}
            '//}
            '//#endif
            '// Compute 1D root of f(x) - target = 0
            Local newAlpha :Float = alpha
            
            Local x1 :Float = alpha
            Local x2 :Float = 1.0
            Local f1 :Float = separation
            sweepA.GetTransform(s_xfA, x2)
            sweepB.GetTransform(s_xfB, x2)
            Local f2 :Float = s_fcn.Evaluate(s_xfA, s_xfB)
            '// If intervals dont overlap at t2, then we are done
            If (f2 >= target)
                
                alpha = 1.0
                Exit
            End
            '// Determine when intervals intersect
            Local rootIterCount :Int = 0
            While True
                
                '// Use a mis of the secand rule and bisection
                Local x :Float
                If (rootIterCount & 1)
                    
                    '// Secant rule to improve convergence
                    x = x1 + (target - f1) * (x2 - x1) / (f2 - f1)
                Else
                    
                    
                    '// Bisection to guarantee progress
                    x = 0.5 * (x1 + x2)
                End
                sweepA.GetTransform(s_xfA, x)
                sweepB.GetTransform(s_xfB, x)
                Local f :Float = s_fcn.Evaluate(s_xfA, s_xfB)
                If (b2Math.Abs(f - target) < 0.025 * tolerance)
                    
                    newAlpha = x
                    Exit
                End
                '// Ensure we continue to bracket the root
                If (f > target)
                    
                    x1 = x
                    f1 = f
                Else
                    
                    
                    x2 = x
                    f2 = f
                End
                
                rootIterCount += 1
                b2_toiRootIters += 1
                If (rootIterCount = 50)
                    
                    Exit
                End
            End
            b2_toiMaxRootIters = b2Math.Max(b2_toiMaxRootIters, rootIterCount)
            'End
            '// Ensure significant advancement
            If (newAlpha < (1.0 + 100.0 * Constants.EPSILON) * alpha)
                
                Exit
            End
            alpha = newAlpha
            iter += 1
            b2_toiIters += 1
            
            If (iter = k_maxIterations)
                
                Exit
            End
        End
        b2_toiMaxIters = b2Math.Max(b2_toiMaxIters, iter)
        Return alpha
    End
End

