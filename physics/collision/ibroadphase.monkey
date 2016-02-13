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

Class UpdatePairsCallback
    Method Callback:Void(a:Object,b:Object) Abstract
End
Class QueryCallback
    Method Callback:Bool(a:Object) Abstract
End
Class RayCastCallback
    Method Callback:Float(a:Object,b:b2RayCastInput) Abstract
End

#rem
'/**
'* Interface for objects tracking overlap of many AABBs.
'*/
#end
Class IBroadPhase Abstract
    #rem
    '/**
    '* Create a proxy with an initial AABB. Pairs are not reported until
    '* called(UpdatePairs).
    '*/
    #end
    Method CreateProxy : Object (aabb:b2AABB, userData: Object) Abstract
    #rem
    '/**
    '* Destroy a proxy. up(It) to the client to remove any pairs.
    '*/
    #end
    Method DestroyProxy : void (proxy: Object) Abstract
    #rem
    '/**
    '* Call many(MoveProxy) you(times) like, then when you are done
    '* call UpdatePairs to finalized the proxy pairs (for your time timeStep).
    '*/
    #end
    Method MoveProxy : void (proxy: Object, aabb:b2AABB, displacement:b2Vec2) Abstract
    Method TestOverlap : Bool (proxyA: Object, proxyB: Object) Abstract
    #rem
    '/**
    '* Get user data from a proxy. Returns null if the invalid(proxy).
    '*/
    #end
    Method GetUserData : Object (proxy: Object) Abstract
    #rem
    '/**
    '* Get the fat AABB for a proxy.
    '*/
    #end
    Method GetFatAABB : b2AABB (proxy: Object) Abstract
    #rem
    '/**
    '* Get the number of proxies.
    '*/
    #end
    Method GetProxyCount : Int () Abstract
    #rem
    '/**
    '* Update the pairs. This results in pair callbacks. This can only add pairs.
    '*/
    #end
    Method UpdatePairs : void (callback:UpdatePairsCallback) Abstract
    #rem
    '/**
    '* Query an AABB for overlapping proxies. The callback class
    '* is called with each proxy that overlaps
    '* the supplied AABB, and return a Bool indicating if
    '* the broaphase should proceed to the nextItem match.
    '* @param callback This Method should be a Method matching signature
    '* <code>Method Callback:Void(proxy: Object):Bool</code>
    '*/
    #end
    Method Query : void (callback:QueryCallback, aabb:b2AABB) Abstract
    #rem
    '/**
    '* Ray-cast  agains the proxies in the tree. This relies on the callback
    '* to perform exact ray-cast in the case where the proxy contains a shape
    '* The callback also performs any collision filtering
    '* @param callback This Method should be a Method matching signature
    '* <code>Method Callback:Void(subInput:b2RayCastInput, proxy: Object):Float</code>
    '* Where the returned the(number) New value for maxFraction
    '*/
    #end
    Method RayCast : void (callback:RayCastCallback, input:b2RayCastInput) Abstract
    #rem
    '/**
    '* For debugging, throws in invariants have been broken
    '*/
    #end
    Method Validate : void () Abstract
    #rem
    '/**
    '* Give the broadphase a chance for structural optimizations
    '*/
    #end
    Method Rebalance : void (iterations:Int) Abstract
End




