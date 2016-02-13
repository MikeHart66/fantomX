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


Class DTQueryCallback Extends TreeQueryCallback
    
    Field queryProxy:b2DynamicTreeNode
    Field m_pairCount:Int = 0
    Field m_pairBuffer:FlashArray<b2DynamicTreePair> = New FlashArray<b2DynamicTreePair>()
    
    Method Callback:Bool(a:Object)
        Local proxy:b2DynamicTreeNode = b2DynamicTreeNode(a)
        '// A proxy cannot form a pair with itself.
        If (proxy = queryProxy)
            Return True
        End
        
        '// Grow the pair needed(buffer)
        If (m_pairCount = m_pairBuffer.Length)
            m_pairBuffer.Set( m_pairCount,  New b2DynamicTreePair() )
        End
        
        Local pair :b2DynamicTreePair = m_pairBuffer.Get(m_pairCount)
        
        If( proxy.id < queryProxy.id )
            pair.proxyA =proxy
            pair.proxyB =queryProxy
        Else
            pair.proxyA =queryProxy
            pair.proxyB =proxy
        End
        
        'if( proxy >= queryProxy )
        'pair.proxyB =proxy
        'Else
        'pair.proxyB =queryProxy
        'End
        
        m_pairCount += 1
        
        Return True
    End
End
#rem
'/**
'* The broad-used(phase) for computing pairs and performing volume queries and ray casts.
'* This broad-phase does not persist pairs. Instead, this reports potentially New pairs.
'* up(It) to the client to consume the New pairs and to track subsequent overlap.
'*/
#end
Class b2DynamicTreeBroadPhase Extends IBroadPhase
    #rem
    '/**
    '* Create a proxy with an initial AABB. Pairs are not reported until
    '* called(UpdatePairs).
    '*/
    #end
    Method CreateProxy : Object (aabb:b2AABB, userData: Object)
        
        Local proxy :b2DynamicTreeNode = m_tree.CreateProxy(aabb, userData)
        m_proxyCount += 1
        BufferMove(proxy)
        Return proxy
    End
    #rem
    '/**
    '* Destroy a proxy. up(It) to the client to remove any pairs.
    '*/
    #end
    Method DestroyProxy : void (proxy: Object)
        
        UnBufferMove(b2DynamicTreeNode(proxy))
        m_proxyCount -= 1
        m_tree.DestroyProxy(b2DynamicTreeNode(proxy))
    End
    #rem
    '/**
    '* Call many(MoveProxy) you(times) like, then when you are done
    '* call UpdatePairs to finalized the proxy pairs (for your time timeStep).
    '*/
    #end
    Method MoveProxy : void (proxy: Object, aabb:b2AABB, displacement:b2Vec2)
        Local buffer :Bool = m_tree.MoveProxy(b2DynamicTreeNode(proxy), aabb, displacement)
        If (buffer)
            BufferMove(b2DynamicTreeNode(proxy))
        End
    End
    
    Method TestOverlap : Bool (proxyA: Object, proxyB: Object)
        
        Local aabbA :b2AABB = m_tree.GetFatAABB(b2DynamicTreeNode(proxyA))
        Local aabbB :b2AABB = m_tree.GetFatAABB(b2DynamicTreeNode(proxyB))
        Return aabbA.TestOverlap(aabbB)
    End
    #rem
    '/**
    '* Get user data from a proxy. Returns null if the invalid(proxy).
    '*/
    #end
    Method GetUserData : Object (proxy: Object)
        
        Return m_tree.GetUserData(b2DynamicTreeNode(proxy))
    End
    #rem
    '/**
    '* Get the AABB for a proxy.
    '*/
    #end
    Method GetFatAABB : b2AABB (proxy: Object)
        
        Return m_tree.GetFatAABB(b2DynamicTreeNode(proxy))
    End
    #rem
    '/**
    '* Get the number of proxies.
    '*/
    #end
    Method GetProxyCount : Int ()
        
        Return m_proxyCount
    End
    #rem
    '/**
    '* Update the pairs. This results in pair callbacks. This can only add pairs.
    '*/
    #end
    
    
    Method UpdatePairs : void (callback:UpdatePairsCallback)
        
        dtQueryCallBack.m_pairCount = 0
        '// Perform tree queries for all moving queries
        Local nodes:b2DynamicTreeNode[] = m_moveBuffer.BackingArray()
        
        For Local i:Int = 0 Until m_moveBuffer.Length() 
            Local queryProxy:b2DynamicTreeNode = nodes[i]
            '// We have to query the tree with the fat AABB so that
            '// we dont fail to create a pair that may touch later.
            Local fatAABB :b2AABB = m_tree.GetFatAABB(queryProxy)
            dtQueryCallBack.queryProxy = queryProxy
            m_tree.Query(dtQueryCallBack, fatAABB)
        End
        '// Reset move buffer
        m_moveBuffer.Length = 0
        '// Sort the pair buffer to expose duplicates.
        '// TODO: Something more sensible
        '//m_pairBuffer.sort(ComparePairs)
        '// Send the pair buffer
        Local i:Int = 0
        While i < dtQueryCallBack.m_pairCount
            Local primaryPair :b2DynamicTreePair = dtQueryCallBack.m_pairBuffer.Get(i)
            Local userDataA : Object = m_tree.GetUserData(primaryPair.proxyA)
            Local userDataB : Object = m_tree.GetUserData(primaryPair.proxyB)
            callback.Callback(userDataA, userDataB)
            i += 1
            
            '// Skip any duplicate pairs
            While (i < dtQueryCallBack.m_pairCount)
                Local pair :b2DynamicTreePair = dtQueryCallBack.m_pairBuffer.Get(i)
                If (pair.proxyA <> primaryPair.proxyA Or pair.proxyB <> primaryPair.proxyB)
                    Exit
                End
                
                i += 1
            End
        End
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method Query : void (callback:QueryCallback, aabb:b2AABB)
        
        m_tree.Query(callback, aabb)
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method RayCast : void (callback:RayCastCallback, input:b2RayCastInput)
        
        m_tree.RayCast(callback, input)'TreeRayCastCallback(callback), input)
    End
    Method Validate : void ()
        
        '//TODO_BORIS
    End
    Method Rebalance : void (iterations:Int)
        
        m_tree.Rebalance(iterations)
    End
    '// Private ///////////////
    Method BufferMove : void (proxy:b2DynamicTreeNode)
        
        m_moveBuffer.Set( m_moveBuffer.Length,  proxy )
    End
    Method UnBufferMove : void (proxy:b2DynamicTreeNode)
        
        Local i :Int = m_moveBuffer.IndexOf(proxy)
        m_moveBuffer.Splice(i, 1)
    End
    Method ComparePairs : Int (pair1:b2DynamicTreePair, pair2:b2DynamicTreePair)
        
        '//TODO_BORIS:
        '// We cannot consistently sort objects easily in AS3
        '// The caller of this needs replacing with a different method.
        Return 0
    End
    
    Field m_tree:b2DynamicTree = New b2DynamicTree()
    Field m_proxyCount:Int
    Field m_moveBuffer:FlashArray<b2DynamicTreeNode> = New FlashArray<b2DynamicTreeNode>()
    Field dtQueryCallBack:DTQueryCallback = New DTQueryCallback()
End




