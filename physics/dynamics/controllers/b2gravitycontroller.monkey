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
'* Applies simplified gravity between every pair of bodies
'*/
#end
Class b2GravityController Extends b2Controller
    #rem
    '/**
    '* Specifies the strength of the gravitiation force
    '*/
    #end
    Field G:Float = 1
    #rem
    '/**
    '* If True, proportional(gravity) to r^-2, otherwise r^-1
    '*/
    #end
    Field invSqr:Bool = True
    Method TimeStep : void (timeStep:b2TimeStep)
        
        '//Inlined
        Local i :b2ControllerEdge = null
        Local body1 :b2Body = null
        Local p1 :b2Vec2 = null
        Local mass1 :Float = 0
        Local j :b2ControllerEdge = null
        Local body2 :b2Body = null
        Local p2 :b2Vec2 = null
        Local dx :Float = 0
        Local dy :Float = 0
        Local r2 :Float = 0
        Local f :b2Vec2 = null
        If(invSqr)
            
            i=m_bodyList
            While( i <> Null )
                body1 = i.body
                p1 = body1.GetWorldCenter()
                mass1 = body1.GetMass()
                j=m_bodyList
                While(j<>i)
                    body2 = j.body
                    p2 = body2.GetWorldCenter()
                    dx = p2.x - p1.x
                    dy = p2.y - p1.y
                    r2 = dx*dx+dy*dy
                    If(r2<Constants.FMIN)
                        Continue
                    End
                    f = New b2Vec2(dx,dy)
                    f.Multiply(G / r2 / Sqrt(r2) * mass1* body2.GetMass())
                    If(body1.IsAwake())
                        body1.ApplyForce(f,p1)
                    End
                    f.Multiply(-1)
                    If(body2.IsAwake())
                        body2.ApplyForce(f,p2)
                    End
                    j=j.nextBody
                End
                i=i.nextBody
            End
            
        Else
            i=m_bodyList
            While( i <> Null )
                body1 = i.body
                p1 = body1.GetWorldCenter()
                mass1 = body1.GetMass()
                j=m_bodyList
                While(j<>i)
                    body2 = j.body
                    p2 = body2.GetWorldCenter()
                    dx = p2.x - p1.x
                    dy = p2.y - p1.y
                    r2 = dx*dx+dy*dy
                    If(r2<Constants.FMIN)
                        Continue
                    End
                    f = New b2Vec2(dx,dy)
                    f.Multiply(G / r2 * mass1 * body2.GetMass())
                    If(body1.IsAwake())
                        body1.ApplyForce(f,p1)
                    End
                    f.Multiply(-1)
                    If(body2.IsAwake())
                        body2.ApplyForce(f,p2)
                    End
                    j=j.nextBody
                End
                i=i.nextBody
            End
        End
    End
End

