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
Class B2ProxyMap<V> Extends Map<b2Proxy,V>

	Method Compare:Int( lhs:b2Proxy,rhs:b2Proxy )
		If lhs.id<rhs.id Return -1
		Return lhs.id>rhs.id
	End
	
End

Class b2Proxy
    Global idCount:Int = 0
    Field id:Int
    
    Method New()
        id = idCount
        idCount += 1
    End
    
    Method IsValid : Bool ()
        Return overlapCount <> b2BroadPhase.b2_invalid
    End

    Field lowerBounds:FlashArray<IntObject> = New FlashArray<IntObject>(2)
    Field upperBounds:FlashArray<IntObject> = New FlashArray<IntObject>(2)
    Field overlapCount:Int
    Field timeStamp:Int
    
    '// Maps from the other b2Proxy to their mutual b2Pair.
    Field pairs:B2ProxyMap<b2Pair> = New B2ProxyMap<b2Pair>
    Field nextItem:b2Proxy
    Field userData: Object = null
    
End

