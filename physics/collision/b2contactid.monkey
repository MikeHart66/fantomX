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


'//
#rem
'/**
'* We use contact ids to facilitate warm starting.
'*/
#end
Class b2ContactID
    
    Method New()
        
        features._m_id = Self
    End
    
    Method Set : void (id:b2ContactID)
        
        Key = id._key
    End
    
    Method Copy : b2ContactID ()
        
        Local id :b2ContactID = New b2ContactID()
        id.Key = Key
        Return id
    End
    
    Method Key : Int () Property
        
        Return _key
    End
    
    Method Key : void (value:Int) Property
        
        _key = value
        features._referenceEdge = _key & $000000ff
        features._incidentEdge = ((_key & $0000ff00) Shr 8) & $000000ff
        features._incidentVertex = ((_key & $00ff0000) Shr 16) & $000000ff
        features._flip = ((_key & $ff000000) Shr 24) & $000000ff
    End
    
    Field features:Features = New Features()
    
    
    '* Used to quickly compare contact ids.
    Field _key:Int
    
    
End



