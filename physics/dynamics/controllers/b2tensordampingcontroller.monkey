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
'* Applies top down linear damping to the controlled bodies
'* The calculated(damping) by multiplying velocity by a matrix in local co-ordinates.
'*/
#end
Class b2TensorDampingController Extends b2Controller
    #rem
    '/**
    '* Tensor to use in damping model
    '*/
    #end
    Field T:b2Mat22 = New b2Mat22()
    #rem
    '/*Some examples (matrixes in format (row1; row2) )
    '(-a 0
    '0 -a)		Standard isotropic damping with strength a
    '(0 a
    '-a 0)		Electron in fixed field - a force at right angles to velocity with proportional magnitude
    '(-a 0
    '0 -b)		Differing x and y damping. Useful e.g. for top-down wheels.
    '*/
    #end
    '//By the way, tensor in this case just means matrix, dont let the terminology get you down.
    #rem
    '/**
    '* Set this to a positive number to clamp the maximum amount of damping done.
    '*/
    #end
    Field maxTimestep:Float = 0
    '// Typically one wants maxTimestep to be 1/(max eigenvalue of T), so that damping will never cause something to reverse direction
    #rem
    '/**
    '* Helper Method to set T in a common case
    '*/
    #end
    Method SetAxisAligned : void (xDamping:Float, yDamping:Float)
        
        T.col1.x = -xDamping
        T.col1.y = 0
        T.col2.x = 0
        T.col2.y = -yDamping
        If(xDamping>0 Or yDamping>0)

             
            'maxTimestep = 1/Math.Max(xDamping,yDamping)  'MikeHart 20151030
            maxTimestep = 1.0/Max(xDamping,yDamping)  'MikeHart 20151030
        Else
            
            
            maxTimestep = 0
        End
    End
    Method TimeStep : void (timeStep:b2TimeStep)
        
        Local timestep :Float = timeStep.dt
        If(timestep<=Constants.EPSILON)
            Return
        End
        If(timestep>maxTimestep And maxTimestep>0)
            timestep = maxTimestep
        End
        Local i:b2ControllerEdge=m_bodyList
        While(i<> Null)
            Local body :b2Body = i.body
            If(Not(body.IsAwake()))
                
                '//Sleeping bodies are still - so have no damping
                Continue
            End
            
            Local damping:b2Vec2 = New b2Vec2()
            body.GetLocalVector(body.GetLinearVelocity(),damping)
            b2Math.MulMV(T,damping,damping)
            body.GetWorldVector(damping,damping)
            body.SetLinearVelocity(New b2Vec2(body.GetLinearVelocity().x + damping.x * timestep, body.GetLinearVelocity().y + damping.y * timestep ))
            i=i.nextBody
        End
    End
End


