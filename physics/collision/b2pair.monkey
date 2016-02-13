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

'// The pair used(manager) by the broad-phase to quickly add/remove/find pairs
'// of overlapping proxies. based(It) closely on code provided by Pierre Terdiman.
'// http://www.codercorner.com/IncrementalSAP.txt


#rem
'/**
'* A Pair represents a pair of overlapping b2Proxy in the broadphse.
'* @
'*/
#end
Class b2Pair
    
    Method SetBuffered : void ()
        status |= e_pairBuffered
    End
    
    Method ClearBuffered : void ()
        status &= ~e_pairBuffered
    End
    
    Method IsBuffered : Bool ()
        Return (status & e_pairBuffered) = e_pairBuffered
    End
    
    Method SetRemoved : void ()
        status |= e_pairRemoved
    End
    
    Method ClearRemoved : void ()
        status &= ~e_pairRemoved
    End
    
    Method IsRemoved : Bool ()
        Return (status & e_pairRemoved) = e_pairRemoved
    End
    
    Method SetFinal : void ()
        status |= e_pairFinal
    End
    
    Method IsFinal : Bool ()
        Return (status & e_pairFinal) = e_pairFinal
    End
    
    Field userData: Object = null
    Field proxy1:b2Proxy
    Field proxy2:b2Proxy
    Field nextItem:b2Pair
    Field status:Int
    
    '// STATIC
    Global b2_nullProxy:Int = b2Settings.USHRT_MAX
    '// enum
    Global e_pairBuffered:Int = $0001
    Global e_pairRemoved:Int = $0002
    Global e_pairFinal:Int = $0004
End
