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
'* Base class for controllers. Controllers are a convience for encapsulating common
'* per-step Methodality.
'*/
#end
Class b2Controller
    
    Method TimeStep : void (timeStep:b2TimeStep)
    End
    Method Draw : void (debugDraw:b2DebugDraw)
    End
    Method AddBody : void (body:b2Body)
        
        Local edge :b2ControllerEdge = New b2ControllerEdge()
        edge.controller = Self
        edge.body = body
        '//
        edge.nextBody = m_bodyList
        edge.prevBody = null
        m_bodyList = edge
        If (edge.nextBody)
            edge.nextBody.prevBody = edge
        End
        m_bodyCount += 1
        '//
        edge.nextController = body.m_controllerList
        edge.prevController = null
        body.m_controllerList = edge
        If (edge.nextController)
            edge.nextController.prevController = edge
        End
        body.m_controllerCount += 1
        
    End
    Method RemoveBody : void (body:b2Body)
        
        Local edge :b2ControllerEdge = body.m_controllerList
        While (edge And edge.controller <> Self)
            edge = edge.nextController
        End
        '//Attempted to remove a body that was not attached?
        '//b2Settings.B2Assert(bEdge <> null)
        If (edge.prevBody)
            edge.prevBody.nextBody = edge.nextBody
        End
        If (edge.nextBody)
            edge.nextBody.prevBody = edge.prevBody
        End
        If (edge.nextController)
            edge.nextController.prevController = edge.prevController
        End
        If (edge.prevController)
            edge.prevController.nextController = edge.nextController
        End
        If (m_bodyList = edge)
            m_bodyList = edge.nextBody
        End
        If (body.m_controllerList = edge)
            body.m_controllerList = edge.nextController
        End
        body.m_controllerCount -= 1
        m_bodyCount -= 1
        '//b2Settings.B2Assert(body.m_controllerCount >= 0)
        '//b2Settings.B2Assert(m_bodyCount >= 0)
    End
    Method Clear : void ()
        
        While (m_bodyList)
            RemoveBody(m_bodyList.body)
        End
    End
    
    Method GetNext : b2Controller ()
        Return m_next
    End
    
    
    Method GetWorld : b2World ()
        Return m_world
    End
    Method GetBodyList : b2ControllerEdge ()
        
        Return m_bodyList
    End
    
    Field m_next:b2Controller
    
    
    Field m_prev:b2Controller
    
    Field m_bodyList:b2ControllerEdge
    Field m_bodyCount:Int
    Field m_world:b2World
    
    
End

