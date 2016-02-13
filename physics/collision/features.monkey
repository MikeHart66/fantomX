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
'
'/**
'* We use contact ids to facilitate warm starting.
'*/
#end


Class Features
    #rem
    '/**
    '* The edge that defines the outward contact normal.
    '*/
    #end
    Method ReferenceEdge : Int () Property
        
        Return _referenceEdge
    End
    
    Method ReferenceEdge : void (value:Int) Property
        
        _referenceEdge = value
        _m_id._key = (_m_id._key & $ffffff00) | (_referenceEdge & $000000ff)
    End
    
    Field _referenceEdge:Int
    
    #rem
    '/**
    '* The edge most anti-parallel to the reference edge.
    '*/
    #end
    Method IncidentEdge : Int () Property
        
        Return _incidentEdge
    End
    
    Method IncidentEdge : void (value:Int) Property
        
        _incidentEdge = value
        _m_id._key = (_m_id._key & $ffff00ff) | ((_incidentEdge Shl 8) & $0000ff00)
    End
    
    Field _incidentEdge:Int
    
    #rem
    '/**
    '* The vertex (0 or 1) on the incident edge that was clipped.
    '*/
    #end
    Method IncidentVertex : Int () Property
        
        Return _incidentVertex
    End
    
    Method IncidentVertex : void (value:Int) Property
        
        _incidentVertex = value
        _m_id._key = (_m_id._key & $ff00ffff) | ((_incidentVertex Shl 16) & $00ff0000)
    End
    
    Field _incidentVertex:Int
    
    #rem
    '/**
    '* A value of 1 indicates that the reference on(edge) shape2.0
    '*/
    #end
    Method Flip : Int () Property
        
        Return _flip
    End
    
    Method Flip : void (value:Int) Property
        
        _flip = value
        _m_id._key = (_m_id._key & $00ffffff) | ((_flip Shl 24) & $ff000000)
    End
    
    Field _flip:Int
    
    
    Field _m_id:b2ContactID
    
    
End



