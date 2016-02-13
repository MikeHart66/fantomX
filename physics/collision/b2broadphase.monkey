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
'/*
'This broad phase uses the Sweep and Prune described(algorithm) in:
'Collision Detection in Interactive 3D Environments by Gino van den Bergen
'Also, some ideas, using(such) integral values for fast compares comes from
'Bullet (http:/www.bulletphysics.com).
'*/
#end
'// Notes:
'// - we use bound arrays instead of linked lists for cache coherence.
'// - we use quantized integral values for fast compares.
'// - we use short indices rather than pointers to save memory.
'// - we use a stabbing count for fast overlap queries (less than order N).
'// - we also use a time stamp on each proxy to speed up the registration of
'//   overlap query results.
'// - where possible, we compare bound indices instead of values to reduce
'//   cache misses (TODO_ERIN).
'// - no perfect(broadphase) and this(neither) one: not(it) great for huge
'//   worlds (use a multi-SAP instead), not(it) great for large objects.
#rem
'/**
'* @
'*/
#end
Class b2BroadPhase Extends IBroadPhase
    
    '//:
    Method New(worldAABB:b2AABB)
        
        '//b2Settings.B2Assert(worldAABB.IsValid())
        Local i :Int
        m_pairManager.Initialize(Self)
        m_worldAABB = worldAABB
        m_proxyCount = 0
        '// bounds array
        m_bounds = New FlashArray<FlashArray<b2Bound> >()
        For Local i:Int = 0 Until 2            
            m_bounds.Set( i,  New FlashArray<b2Bound>() )
        End
        '//b2Vec2 d = worldAABB.upperBound - worldAABB.lowerBound
        Local dX :Float = worldAABB.upperBound.x - worldAABB.lowerBound.x
        Local dY :Float = worldAABB.upperBound.y - worldAABB.lowerBound.y
        m_quantizationFactor.x = b2Settings.USHRT_MAX / dX
        m_quantizationFactor.y = b2Settings.USHRT_MAX / dY
        m_timeStamp = 1
        m_queryResultCount = 0
    End
    
    '//~b2BroadPhase()
    '// Use this to see if your in(proxy) range. If not(it) in range,
    '// it should be destroyed. Otherwise you may get O(m^2) pairs, where m
    '// is the number of proxies that are out of range.
    Method InRange : Bool (aabb:b2AABB)
        
        '//b2Vec2 d = b2Max(aabb.lowerBound - m_worldAABB.upperBound, m_worldAABB.lowerBound - aabb.upperBound)
        Local dX :Float
        Local dY :Float
        Local d2X :Float
        Local d2Y :Float
        dX = aabb.lowerBound.x
        dY = aabb.lowerBound.y
        dX -= m_worldAABB.upperBound.x
        dY -= m_worldAABB.upperBound.y
        d2X = m_worldAABB.lowerBound.x
        d2Y = m_worldAABB.lowerBound.y
        d2X -= aabb.upperBound.x
        d2Y -= aabb.upperBound.y
        dX = b2Math.Max(dX, d2X)
        dY = b2Math.Max(dY, d2Y)
        Return b2Math.Max(dX, dY) < 0.0
    End
    '// Create and destroy proxies. These call Flush first.
    Method CreateProxy : Object (aabb:b2AABB, userData: Object)
        
        Local index :Int
        Local proxy :b2Proxy
        Local i :Int
        Local j :Int
        '//b2Settings.B2Assert(m_proxyCount < b2_maxProxies)
        '//b2Settings.B2Assert(m_freeProxy <> b2Pair.b2_nullProxy)
        If (Not(m_freeProxy))
            
            '// As all proxies are allocated, m_proxyCount = m_proxyPool.Length
            m_freeProxy = New b2Proxy()
            If m_proxyCount = m_proxyPool.Length()
                m_proxyPool = m_proxyPool.Resize(m_proxyCount*2)
            End
            m_proxyPool[m_proxyCount] = m_freeProxy
            m_freeProxy.nextItem = null
            m_freeProxy.timeStamp = 0
            m_freeProxy.overlapCount = b2_invalid
            m_freeProxy.userData = null
            For Local i:Int = 0 Until 2
                
                j = m_proxyCount * 2
                j += 1
                m_bounds.Get(i).Set(j, New b2Bound())
                m_bounds.Get(i).Set(j, New b2Bound())
            End
        End
        proxy = m_freeProxy
        m_freeProxy = proxy.nextItem
        proxy.overlapCount = 0
        proxy.userData = userData
        Local boundCount :Int = 2 * m_proxyCount
        Local lowerValues :FlashArray<FloatObject> = New FlashArray<FloatObject>()
        Local upperValues :FlashArray<FloatObject> = New FlashArray<FloatObject>()
        ComputeBounds(lowerValues, upperValues, aabb)
        For Local axis:Int = 0 Until 2
            
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            Local lowerIndex :Int
            Local upperIndex :Int
            Local lowerIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
            lowerIndexOut.Push(lowerIndex)
            Local upperIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
            upperIndexOut.Push(upperIndex)
            QueryAxis(lowerIndexOut, upperIndexOut, lowerValues.Get(axis), upperValues.Get(axis), bounds, boundCount, axis)
            lowerIndex = lowerIndexOut.Get(0)
            upperIndex = upperIndexOut.Get(0)
            bounds.Splice(upperIndex, 0, bounds.Get(bounds.Length - 1))
            bounds.Length -= 1
            bounds.Splice(lowerIndex, 0, bounds.Get(bounds.Length - 1))
            bounds.Length -= 1
            
            '// The upper index has increased because of the lower bound insertion.
            upperIndex += 1
            
            '// Copy in the New bounds.
            Local tBound1 :b2Bound = bounds.Get(lowerIndex)
            Local tBound2 :b2Bound = bounds.Get(upperIndex)
            tBound1.value = lowerValues.Get(axis)
            tBound1.proxy = proxy
            tBound2.value = upperValues.Get(axis)
            tBound2.proxy = proxy
            Local tBoundAS3 :b2Bound = bounds.Get(Int(lowerIndex-1))
            If( lowerIndex = 0  )
                tBound1.stabbingCount = 0
            Else
                
                
                tBound1.stabbingCount = tBoundAS3.stabbingCount
                
            End
            
            tBoundAS3 = bounds.Get(Int(upperIndex-1))
            tBound2.stabbingCount = tBoundAS3.stabbingCount
            '// Adjust the stabbing count between the New bounds.
            For Local index:Int = lowerIndex Until upperIndex
                
                tBoundAS3 = bounds.Get(index)
                tBoundAS3.stabbingCount += 1
                
            End
            '// Adjust the all the affected bound indices.
            For Local index:Int = lowerIndex Until boundCount + 2
                
                tBound1 = bounds.Get(index)
                Local proxy2 :b2Proxy = tBound1.proxy
                If (tBound1.IsLower())
                    
                    proxy2.lowerBounds.Set( axis,  index )
                Else
                    
                    
                    proxy2.upperBounds.Set( axis,  index )
                End
            End
        End
        
        m_proxyCount += 1
        
        '//b2Settings.B2Assert(m_queryResultCount < b2Settings.b2_maxProxies)
        For Local i:Int = 0 Until m_queryResultCount
            
            '//b2Settings.B2Assert(m_queryResults.Get(i) < b2_maxProxies)
            '//b2Settings.B2Assert(m_proxyPool.Get(m_queryResults[i)].IsValid())
            m_pairManager.AddBufferedPair(proxy, m_queryResults.Get(i))
        End
        '// Prepare for nextItem query.
        m_queryResultCount = 0
        IncrementTimeStamp()
        Return proxy
    End
    Method DestroyProxy : void (proxy_: Object)
        
        Local proxy :b2Proxy = b2Proxy(proxy_)
        Local tBound1 :b2Bound
        Local tBound2 :b2Bound
        '//b2Settings.B2Assert(proxy.IsValid())
        Local boundCount :Int = 2 * m_proxyCount
        For Local axis:Int = 0 Until 2
            
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            Local lowerIndex :Int = proxy.lowerBounds.Get(axis)
            Local upperIndex :Int = proxy.upperBounds.Get(axis)
            tBound1 = bounds.Get(lowerIndex)
            Local lowerValue :Int = tBound1.value
            tBound2 = bounds.Get(upperIndex)
            Local upperValue :Int = tBound2.value
            bounds.Splice(upperIndex, 1)
            bounds.Splice(lowerIndex, 1)
            bounds.Push(tBound1)
            bounds.Push(tBound2)
            '// Fix bound indices.
            Local tEnd :Int = boundCount - 2
            For Local index:Int = lowerIndex Until tEnd
                
                tBound1 = bounds.Get(index)
                Local proxy2 :b2Proxy = tBound1.proxy
                If (tBound1.IsLower())
                    
                    proxy2.lowerBounds.Set( axis,  index )
                Else
                    
                    
                    proxy2.upperBounds.Set( axis,  index )
                End
            End
            '// Fix stabbing count.
            tEnd = upperIndex - 1
            For Local index2:Int = lowerIndex Until tEnd
                
                tBound1 = bounds.Get(index2)
                tBound1.stabbingCount -= 1
                
            End
            '// Query for pairs to be removed. lowerIndex and upperIndex are not needed.
            '// make lowerIndex and upper output using an array and do this for others if compiler doesnt pick them up
            Local ignore :FlashArray<IntObject> = New FlashArray<IntObject>()
            QueryAxis(ignore, ignore, lowerValue, upperValue, bounds, boundCount - 2, axis)
        End
        '//b2Settings.B2Assert(m_queryResultCount < b2Settings.b2_maxProxies)
        For Local i:Int = 0 Until m_queryResultCount
            
            '//b2Settings.B2Assert(m_proxyPool.Get(m_queryResults[i)].IsValid())
            m_pairManager.RemoveBufferedPair(proxy, m_queryResults.Get(i))
        End
        '// Prepare for nextItem query.
        m_queryResultCount = 0
        IncrementTimeStamp()
        '// Return the proxy to the pool.
        proxy.userData = null
        proxy.overlapCount = b2_invalid
        proxy.lowerBounds.Set( 0,  b2_invalid )
        proxy.lowerBounds.Set( 1,  b2_invalid )
        proxy.upperBounds.Set( 0,  b2_invalid )
        proxy.upperBounds.Set( 1,  b2_invalid )
        proxy.nextItem = m_freeProxy
        m_freeProxy = proxy
        m_proxyCount -= 1
        
    End
    '// Call many(MoveProxy) you(times) like, then when you are done
    '// call Commit to finalized the proxy pairs (for your time timeStep).
    Method MoveProxy : void (proxy_: Object, aabb:b2AABB, displacement:b2Vec2)
        
        Local proxy :b2Proxy = b2Proxy(proxy_)
        Local as3arr :FlashArray<IntObject>
        Local as3int :Int
        Local axis :Int
        Local index :Int
        Local bound :b2Bound
        Local prevBound :b2Bound
        Local nextBound :b2Bound
        Local nextProxyId :Int
        Local nextProxy :b2Proxy
        If (proxy = null)
            
            '//b2Settings.B2Assert(False)
            Return
        End
        If (aabb.IsValid() = False)
            
            '//b2Settings.B2Assert(False)
            Return
        End
        Local boundCount :Int = 2 * m_proxyCount
        '// Get New bound values
        Local newValues :b2BoundValues = New b2BoundValues()
        ComputeBounds(newValues.lowerValues, newValues.upperValues, aabb)
        '// Get old bound values
        Local oldValues :b2BoundValues = New b2BoundValues()
        
        For Local axis:Int = 0 Until 2            
            bound = m_bounds.Get(axis).Get(proxy.lowerBounds.Get(axis))
            oldValues.lowerValues.Set( axis,  bound.value )
            bound = m_bounds.Get(axis).Get(proxy.upperBounds.Get(axis))
            oldValues.upperValues.Set( axis,  bound.value )
        End
        
        For Local axis:Int = 0 Until 2
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            Local lowerIndex :Int = proxy.lowerBounds.Get(axis)
            Local upperIndex :Int = proxy.upperBounds.Get(axis)
            Local lowerValue :Int = newValues.lowerValues.Get(axis)
            Local upperValue :Int = newValues.upperValues.Get(axis)
            bound = bounds.Get(lowerIndex)
            Local deltaLower :Int = lowerValue - bound.value
            bound.value = lowerValue
            bound = bounds.Get(upperIndex)
            Local deltaUpper :Int = upperValue - bound.value
            bound.value = upperValue
            '//
            '// Expanding adds overlaps
            '//
            '// Should we move the lower bound down?
            If (deltaLower < 0)
                
                index = lowerIndex
                
                While (index > 0 And lowerValue < (bounds.Get(Int(index-1))).value)
                    bound = bounds.Get(index)
                    prevBound = bounds.Get(Int(index - 1))
                    Local prevProxy :b2Proxy = prevBound.proxy
                    prevBound.stabbingCount += 1
                    
                    If (prevBound.IsUpper() = True)
                        
                        If (TestOverlapBound(newValues, prevProxy))
                            
                            m_pairManager.AddBufferedPair(proxy, prevProxy)
                        End
                        '//prevProxy.upperBounds.Get(axis)++
                        as3arr = prevProxy.upperBounds
                        as3int = as3arr.Get(axis)
                        as3int += 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount += 1
                        
                    Else
                        
                        
                        '//prevProxy.lowerBounds.Get(axis)++
                        as3arr = prevProxy.lowerBounds
                        as3int = as3arr.Get(axis)
                        as3int += 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount -= 1
                        
                    End
                    '//proxy.lowerBounds.Get(axis)--
                    as3arr = proxy.lowerBounds
                    as3int = as3arr.Get(axis)
                    as3int -= 1
                    as3arr.Set( axis,  as3int )
                    '// swap
                    '//var temp:b2Bound = bound
                    '//bound = prevEdge
                    '//prevEdge = temp
                    bound.Swap(prevBound)
                    '//b2Math.Swap(bound, prevEdge)
                    index -= 1
                    
                End
            End
            '// Should we move the upper bound up?
            If (deltaUpper > 0)
                
                index = upperIndex
                While (index < boundCount-1 And (bounds.Get(Int(index+1))).value <= upperValue)
                    
                    bound = bounds.Get( index )
                    nextBound = bounds.Get( Int(index + 1) )
                    nextProxy = nextBound.proxy
                    nextBound.stabbingCount += 1
                    
                    If (nextBound.IsLower() = True)
                        
                        If (TestOverlapBound(newValues, nextProxy))
                            
                            m_pairManager.AddBufferedPair(proxy, nextProxy)
                        End
                        '//nextProxy.lowerBounds.Get(axis)--
                        as3arr = nextProxy.lowerBounds
                        as3int = as3arr.Get(axis)
                        as3int -= 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount += 1
                        
                    Else
                        
                        
                        '//nextProxy.upperBounds.Get(axis)--
                        as3arr = nextProxy.upperBounds
                        as3int = as3arr.Get(axis)
                        as3int -= 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount -= 1
                        
                    End
                    '//proxy.upperBounds.Get(axis)++
                    as3arr = proxy.upperBounds
                    as3int = as3arr.Get(axis)
                    as3int += 1
                    as3arr.Set( axis,  as3int )
                    '// swap
                    '//var temp:b2Bound = bound
                    '//bound = nextEdge
                    '//nextEdge = temp
                    bound.Swap(nextBound)
                    '//b2Math.Swap(bound, nextEdge)
                    index += 1
                    
                End
            End
            '//
            '// Shrinking removes overlaps
            '//
            '// Should we move the lower bound up?
            If (deltaLower > 0)
                
                index = lowerIndex
                While (index < boundCount-1 And (bounds.Get(Int(index+1))).value <= lowerValue)
                    
                    bound = bounds.Get( index )
                    nextBound = bounds.Get( Int(index + 1) )
                    nextProxy = nextBound.proxy
                    nextBound.stabbingCount -= 1
                    
                    If (nextBound.IsUpper())
                        
                        If (TestOverlapBound(oldValues, nextProxy))
                            
                            m_pairManager.RemoveBufferedPair(proxy, nextProxy)
                        End
                        '//nextProxy.upperBounds.Get(axis)--
                        as3arr = nextProxy.upperBounds
                        as3int = as3arr.Get(axis)
                        as3int -= 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount -= 1
                        
                    Else
                        
                        
                        '//nextProxy.lowerBounds.Get(axis)--
                        as3arr = nextProxy.lowerBounds
                        as3int = as3arr.Get(axis)
                        as3int -= 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount += 1
                        
                    End
                    '//proxy.lowerBounds.Get(axis)++
                    as3arr = proxy.lowerBounds
                    as3int = as3arr.Get(axis)
                    as3int += 1
                    as3arr.Set( axis,  as3int )
                    '// swap
                    '//var temp:b2Bound = bound
                    '//bound = nextEdge
                    '//nextEdge = temp
                    bound.Swap(nextBound)
                    '//b2Math.Swap(bound, nextEdge)
                    index += 1
                    
                End
            End
            '// Should we move the upper bound down?
            If (deltaUpper < 0)
                
                index = upperIndex
                While (index > 0 And upperValue < (bounds.Get(Int(index-1))).value)
                    
                    bound = bounds.Get(index)
                    prevBound = bounds.Get(Int(index - 1))
                    Local prevProxy :b2Proxy = prevBound.proxy
                    
                    prevBound.stabbingCount -= 1
                    
                    If (prevBound.IsLower() = True)
                        
                        If (TestOverlapBound(oldValues, prevProxy))
                            
                            m_pairManager.RemoveBufferedPair(proxy, prevProxy)
                        End
                        '//prevProxy.lowerBounds.Get(axis)++
                        as3arr = prevProxy.lowerBounds
                        as3int = as3arr.Get(axis)
                        as3int += 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount -= 1
                        
                    Else
                        
                        
                        '//prevProxy.upperBounds.Get(axis)++
                        as3arr = prevProxy.upperBounds
                        as3int = as3arr.Get(axis)
                        as3int += 1
                        as3arr.Set( axis,  as3int )
                        bound.stabbingCount += 1
                        
                    End
                    '//proxy.upperBounds.Get(axis)--
                    as3arr = proxy.upperBounds
                    as3int = as3arr.Get(axis)
                    as3int -= 1
                    as3arr.Set( axis,  as3int )
                    '// swap
                    '//var temp:b2Bound = bound
                    '//bound = prevEdge
                    '//prevEdge = temp
                    
                    bound.Swap(prevBound)
                    '//b2Math.Swap(bound, prevEdge)
                    index -= 1
                    
                End
            End
        End
    End
    
    Method UpdatePairs : void (callback:UpdatePairsCallback)
        m_pairManager.Commit(callback)
    End
    
    Method TestOverlap : Bool (proxyA: Object, proxyB: Object)
        
        Local proxyA_ :b2Proxy = b2Proxy(proxyA)
        Local proxyB_ :b2Proxy = b2Proxy(proxyB)
        If ( proxyA_.lowerBounds.Get(0).ToInt() > proxyB_.upperBounds.Get(0).ToInt())
            Return False
        End
        If ( proxyB_.lowerBounds.Get(0).ToInt() > proxyA_.upperBounds.Get(0).ToInt())
            Return False
        End
        If ( proxyA_.lowerBounds.Get(1).ToInt() > proxyB_.upperBounds.Get(1).ToInt())
            Return False
        End
        If ( proxyB_.lowerBounds.Get(1).ToInt() > proxyA_.upperBounds.Get(1).ToInt())
            Return False
        End
        Return True
    End
    #rem
    '/**
    '* Get user data from a proxy. Returns null if the invalid(proxy).
    '*/
    #end
    Method GetUserData : Object (proxy: Object)
        
        Return b2Proxy((proxy)).userData
    End
    #rem
    '/**
    '* Get the AABB for a proxy.
    '*/
    #end
    Method GetFatAABB : b2AABB (proxy_: Object)
        
        Local aabb :b2AABB = New b2AABB()
        Local proxy :b2Proxy = b2Proxy(proxy_)
        aabb.lowerBound.x = m_worldAABB.lowerBound.x +  m_bounds.Get(0).Get(proxy.lowerBounds.Get(0)).value  / m_quantizationFactor.x
        aabb.lowerBound.y = m_worldAABB.lowerBound.y +  m_bounds.Get(1).Get(proxy.lowerBounds.Get(1)).value  / m_quantizationFactor.y
        aabb.upperBound.x = m_worldAABB.lowerBound.x +  m_bounds.Get(0).Get(proxy.upperBounds.Get(0)).value  / m_quantizationFactor.x
        aabb.upperBound.y = m_worldAABB.lowerBound.y +  m_bounds.Get(1).Get(proxy.upperBounds.Get(1)).value  / m_quantizationFactor.y
        Return aabb
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
    '* Query an AABB for overlapping proxies. The callback class
    '* is called for each proxy that overlaps the supplied AABB.
    '*/
    #end
    Method Query : void (callback:QueryCallback, aabb:b2AABB)
        
        Local lowerValues :FlashArray<FloatObject> = New FlashArray<FloatObject>()
        Local upperValues :FlashArray<FloatObject> = New FlashArray<FloatObject>()
        ComputeBounds(lowerValues, upperValues, aabb)
        Local lowerIndex :Int
        Local upperIndex :Int
        Local lowerIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
        lowerIndexOut.Push(lowerIndex)
        Local upperIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
        upperIndexOut.Push(upperIndex)
        QueryAxis(lowerIndexOut, upperIndexOut, lowerValues.Get(0), upperValues.Get(0), m_bounds.Get(0), 2*m_proxyCount, 0)
        QueryAxis(lowerIndexOut, upperIndexOut, lowerValues.Get(1), upperValues.Get(1), m_bounds.Get(1), 2*m_proxyCount, 1)
        '//b2Settings.B2Assert(m_queryResultCount < b2Settings.b2_maxProxies)
        '// TODO: Dont be lazy, transform QueryAxis to directly call callback
        For Local i:Int = 0 Until m_queryResultCount
            
            Local proxy :b2Proxy =  m_queryResults.Get(i)
            '//b2Settings.B2Assert(proxy.IsValid())
            If (Not(callback.Callback(proxy)))
                
                Exit
            End
        End
        '// Prepare for nextItem query.
        m_queryResultCount = 0
        IncrementTimeStamp()
    End
    
    Method Validate : void ()
        
        Local pair :b2Pair
        Local proxy1 :b2Proxy
        Local proxy2 :b2Proxy
        Local overlap :Bool
        For Local axis:Int = 0 Until 2
            
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            Local boundCount :Int = 2 * m_proxyCount
            Local stabbingCount :Int = 0
            For Local i:Int = 0 Until boundCount
                
                Local bound :b2Bound = bounds.Get(i)
                '//b2Settings.B2Assert(i = 0 Or bounds.Get(i-1).value <= bound->value)
                '//b2Settings.B2Assert(bound->proxyId <> b2_nullProxy)
                '//b2Settings.B2Assert(m_proxyPool.Get(bound->proxyId).IsValid())
                If (bound.IsLower() = True)
                    
                    '//b2Settings.B2Assert(m_proxyPool.Get(bound.proxyId).lowerBounds.Set( axis,  i) )
                    stabbingCount += 1
                    
                Else
                    
                    
                    '//b2Settings.B2Assert(m_proxyPool.Get(bound.proxyId).upperBounds.Set( axis,  i) )
                    stabbingCount -= 1
                    
                End
                '//b2Settings.B2Assert(bound.stabbingCount = stabbingCount)
            End
        End
    End
    Method Rebalance : void (iterations:Int)
        
        '// Do nothing
    End
    #rem
    '/**
    '* @inheritDoc
    '*/
    #end
    Method RayCast : void (callback:RayCastCallback, input:b2RayCastInput)
        
        Local subInput :b2RayCastInput = New  b2RayCastInput()
        subInput.p1.SetV(input.p1)
        subInput.p2.SetV(input.p2)
        subInput.maxFraction = input.maxFraction
        Local dx :Float = (input.p2.x-input.p1.x)*m_quantizationFactor.x
        Local dy :Float = (input.p2.y-input.p1.y)*m_quantizationFactor.y
        Local sx :Int = 0
        
        If( dx<-Constants.EPSILON  )
            sx = -1
        Else If (dx>Constants.EPSILON)
            sx = 1
        End
        
        Local sy :Int = 0
        
        If( dy<-Constants.EPSILON  )
            sy = -1
        Else If (dy>Constants.EPSILON)
            sy = 1
        End
        '//b2Settings.B2Assert(sx<>0Orsy<>0)
        Local p1x :Float = m_quantizationFactor.x * (input.p1.x - m_worldAABB.lowerBound.x)
        Local p1y :Float = m_quantizationFactor.y * (input.p1.y - m_worldAABB.lowerBound.y)
        Local startValues:FlashArray<IntObject> = New FlashArray<IntObject>()
        Local startValues2:FlashArray<IntObject> = New FlashArray<IntObject>()
        startValues.Set( 0, Int(p1x) & (b2Settings.USHRT_MAX - 1) )
        startValues.Set( 1, Int(p1y) & (b2Settings.USHRT_MAX - 1) )
        startValues2.Set( 0, startValues.Get(0)+1 )
        startValues2.Set( 1, startValues.Get(1)+1 )
        'Local startIndices:Array = New Array()
        Local xIndex :Int
        Local yIndex :Int
        Local proxy :b2Proxy
        '//First deal with all the proxies that contain segment.p1
        Local lowerIndex :Int
        Local upperIndex :Int
        Local lowerIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
        lowerIndexOut.Push(lowerIndex)
        Local upperIndexOut :FlashArray<IntObject> = New FlashArray<IntObject>()
        upperIndexOut.Push(upperIndex)
        QueryAxis(lowerIndexOut, upperIndexOut, startValues.Get(0), startValues2.Get(0), m_bounds.Get(0), 2*m_proxyCount, 0)
        If(sx>=0)
            xIndex = upperIndexOut.Get(0)-1
        Else
            
            xIndex = lowerIndexOut.Get(0)
        End
        QueryAxis(lowerIndexOut, upperIndexOut, startValues.Get(1), startValues2.Get(1), m_bounds.Get(1), 2*m_proxyCount, 1)
        If(sy>=0)
            yIndex = upperIndexOut.Get(0)-1
        Else
            
            yIndex = lowerIndexOut.Get(0)
        End
        '// Callback for starting proxies:
        For Local i:Int = 0 Until m_queryResultCount
            
            subInput.maxFraction = callback.Callback(m_queryResults.Get(i), subInput)
        End
        '//Now work through the rest of the segment
        While( True )
            Local xProgress :Float = 0
            Local yProgress :Float = 0
            '//Move on to nextItem bound
            If( sx >= 0 )
                xIndex +=1
            Else
                xIndex += -1
            End
            
            If(xIndex<0 Or xIndex>=m_proxyCount*2)
                Exit
            End
            
            If(sx<>0)
                xProgress = (m_bounds.Get(0).Get(xIndex).value - p1x) / dx
            End
            
            '//Move on to nextItem bound
            If( sy >= 0 )
                yIndex +=1
            Else
                yIndex += -1
            End
            
            If(yIndex<0 Or yIndex>=m_proxyCount*2)
                Exit
            End
            
            If(sy<>0)
                yProgress = (m_bounds.Get(1).Get(yIndex).value - p1y) / dy
            End
            
            While( True )
                
                If(sy=0 Or (sx<>0 And xProgress<yProgress))
                    
                    If(xProgress>subInput.maxFraction)
                        Exit
                    End
                    '//Check that we are entering a proxy, not leaving
                    If( (sx>0 And m_bounds.Get(0).Get(xIndex).IsLower()) Or (sx>=0 And m_bounds.Get(0).Get(xIndex).IsUpper()) )
                        
                        '//Check the other axis of the proxy
                        proxy = m_bounds.Get(0).Get(xIndex).proxy
                        If(sy>=0)
                            
                            If(proxy.lowerBounds.Get(1)<=yIndex-1 And proxy.upperBounds.Get(1)>=yIndex)
                                
                                '//Add the proxy
                                subInput.maxFraction = callback.Callback(proxy, subInput)
                            End
                            
                        Else
                            
                            
                            If(proxy.lowerBounds.Get(1)<=yIndex And proxy.upperBounds.Get(1)>=yIndex+1)
                                
                                '//Add the proxy
                                subInput.maxFraction = callback.Callback(proxy, subInput)
                            End
                        End
                    End
                    '//Early out
                    If(subInput.maxFraction=0)
                        Exit
                    End
                    '//Move on to the nextItem bound
                    If(sx>0)
                        
                        xIndex += 1
                        If(xIndex=m_proxyCount*2)
                            Exit
                        End
                    Else
                        
                        
                        xIndex -= 1
                        If(xIndex<0)
                            Exit
                        End
                    End
                    
                    xProgress = (m_bounds.Get(0).Get(xIndex).value - p1x) / dx
                Else
                    
                    
                    If(yProgress>subInput.maxFraction)
                        Exit
                    End
                    '//Check that we are entering a proxy, not leaving
                    If( (sy>0 And m_bounds.Get(1).Get(yIndex).IsLower())  Or (sx<=0 And m_bounds.Get(1).Get(yIndex).IsUpper()))
                        
                        '//Check the other axis of the proxy
                        proxy = m_bounds.Get(1).Get(yIndex).proxy
                        If(sx>=0)
                            
                            If(proxy.lowerBounds.Get(0)<=xIndex-1 And proxy.upperBounds.Get(0)>=xIndex)
                                
                                '//Add the proxy
                                subInput.maxFraction = callback.Callback(proxy, subInput)
                            End
                            
                        Else
                            
                            
                            If(proxy.lowerBounds.Get(0)<=xIndex And proxy.upperBounds.Get(0)>=xIndex+1)
                                
                                '//Add the proxy
                                subInput.maxFraction = callback.Callback(proxy, subInput)
                            End
                        End
                    End
                    '//Early out
                    If(subInput.maxFraction=0)
                        Exit
                    End
                    '//Move on to the nextItem bound
                    If(sy>0)
                        
                        yIndex += 1
                        If(yIndex=m_proxyCount*2)
                            Exit
                        End
                    Else
                        
                        
                        yIndex -= 1
                        If(yIndex<0)
                            Exit
                        End
                    End
                    
                    yProgress = (m_bounds.Get(1).Get(yIndex).value - p1y) / dy
                End
            End
            
            Exit
        End
        '// Prepare for nextItem query.
        m_queryResultCount = 0
        IncrementTimeStamp()
        Return
    End
    '//:
    Method ComputeBounds : void (lowerValues:FlashArray<FloatObject>, upperValues:FlashArray<FloatObject>, aabb:b2AABB)
        
        '//b2Settings.B2Assert(aabb.upperBound.x >= aabb.lowerBound.x)
        '//b2Settings.B2Assert(aabb.upperBound.y >= aabb.lowerBound.y)
        '//var minVertex:b2Vec2 = b2Math.ClampV(aabb.minVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex)
        Local minVertexX :Float = aabb.lowerBound.x
        Local minVertexY :Float = aabb.lowerBound.y
        minVertexX = b2Math.Min(minVertexX, m_worldAABB.upperBound.x)
        minVertexY = b2Math.Min(minVertexY, m_worldAABB.upperBound.y)
        minVertexX = b2Math.Max(minVertexX, m_worldAABB.lowerBound.x)
        minVertexY = b2Math.Max(minVertexY, m_worldAABB.lowerBound.y)
        '//var maxVertex:b2Vec2 = b2Math.ClampV(aabb.maxVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex)
        Local maxVertexX :Float = aabb.upperBound.x
        Local maxVertexY :Float = aabb.upperBound.y
        maxVertexX = b2Math.Min(maxVertexX, m_worldAABB.upperBound.x)
        maxVertexY = b2Math.Min(maxVertexY, m_worldAABB.upperBound.y)
        maxVertexX = b2Math.Max(maxVertexX, m_worldAABB.lowerBound.x)
        maxVertexY = b2Math.Max(maxVertexY, m_worldAABB.lowerBound.y)
        '// Bump lower bounds downs and upper bounds up. This ensures correct sorting of
        '// lower/upper bounds that would have equal values.
        '// TODO_ERIN implement fast float to uint16 conversion.
        lowerValues.Set( 0,  Int(m_quantizationFactor.x * (minVertexX - m_worldAABB.lowerBound.x)) & (b2Settings.USHRT_MAX - 1) )
        upperValues.Set( 0,  (Int(m_quantizationFactor.x * (maxVertexX - m_worldAABB.lowerBound.x))& $0000ffff) | 1 )
        lowerValues.Set( 1,  Int(m_quantizationFactor.y * (minVertexY - m_worldAABB.lowerBound.y)) & (b2Settings.USHRT_MAX - 1) )
        upperValues.Set( 1,  (Int(m_quantizationFactor.y * (maxVertexY - m_worldAABB.lowerBound.y))& $0000ffff) | 1 )
    End
    '// This only(one) used for validation.
    Method TestOverlapValidate : Bool (p1:b2Proxy, p2:b2Proxy)
        For Local axis:Int = 0 Until 2
            
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            '//b2Settings.B2Assert(p1.lowerBounds.Get(axis) < 2 * m_proxyCount)
            '//b2Settings.B2Assert(p1.upperBounds.Get(axis) < 2 * m_proxyCount)
            '//b2Settings.B2Assert(p2.lowerBounds.Get(axis) < 2 * m_proxyCount)
            '//b2Settings.B2Assert(p2.upperBounds.Get(axis) < 2 * m_proxyCount)
            Local bound1 :b2Bound = bounds.Get(p1.lowerBounds.Get(axis))
            Local bound2 :b2Bound = bounds.Get(p2.upperBounds.Get(axis))
            If (bound1.value > bound2.value)
                Return False
            End
            bound1 = bounds.Get(p1.upperBounds.Get(axis))
            bound2 = bounds.Get(p2.lowerBounds.Get(axis))
            If (bound1.value < bound2.value)
                Return False
            End
        End
        Return True
    End
    Method TestOverlapBound : Bool (b:b2BoundValues, p:b2Proxy)
        
        For Local axis:Int = 0 Until 2
            
            Local bounds :FlashArray<b2Bound> = m_bounds.Get(axis)
            '//b2Settings.B2Assert(p.lowerBounds.Get(axis) < 2 * m_proxyCount)
            '//b2Settings.B2Assert(p.upperBounds.Get(axis) < 2 * m_proxyCount)
            Local bound :b2Bound = bounds.Get(p.upperBounds.Get(axis))
            If (b.lowerValues.Get(axis) > bound.value)
                Return False
            End
            bound = bounds.Get(p.lowerBounds.Get(axis))
            If (b.upperValues.Get(axis) < bound.value)
                Return False
            End
        End
        Return True
    End
    Method QueryAxis : void (lowerQueryOut:FlashArray<IntObject>, upperQueryOut:FlashArray<IntObject>, lowerValue:Int, upperValue:Int, bounds:FlashArray<b2Bound>, boundCount:Int, axis:Int)
        Local lowerQuery :Int = BinarySearch(bounds, boundCount, lowerValue)
        Local upperQuery :Int = BinarySearch(bounds, boundCount, upperValue)
        Local bound : b2Bound
        '// Easy case: lowerQuery <= lowerIndex(i) < upperQuery
        '// Solution: search query range for min bounds.
        For Local j:Int = lowerQuery Until upperQuery
            
            bound = bounds.Get(j)
            If (bound.IsLower())
                
                IncrementOverlapCount(bound.proxy)
            End
        End
        '// Hard case: lowerIndex(i) < lowerQuery < upperIndex(i)
        '// Solution: use the stabbing count to search down the bound array.
        If (lowerQuery > 0)
            
            Local i :Int = lowerQuery - 1
            bound = bounds.Get(i)
            Local s :Int = bound.stabbingCount
            '// Find the s overlaps.
            While (s)
                
                '//b2Settings.B2Assert(i >= 0)
                bound = bounds.Get(i)
                If (bound.IsLower())
                    
                    Local proxy :b2Proxy = bound.proxy
                    If (lowerQuery <= proxy.upperBounds.Get(axis))
                        
                        IncrementOverlapCount(bound.proxy)
                        s -= 1
                        
                    End
                End
                
                i -= 1
                
            End
        End
        lowerQueryOut.Set( 0,  lowerQuery )
        upperQueryOut.Set( 0,  upperQuery )
    End
    Method IncrementOverlapCount : void (proxy:b2Proxy)
        
        If (proxy.timeStamp < m_timeStamp)
            
            proxy.timeStamp = m_timeStamp
            proxy.overlapCount = 1
        Else
            
            
            proxy.overlapCount = 2
            '//b2Settings.B2Assert(m_queryResultCount < b2Settings.b2_maxProxies)
            m_queryResults.Set( m_queryResultCount,  proxy )
            m_queryResultCount += 1
            
        End
    End
    
    Method IncrementTimeStamp : void ()
        
        If (m_timeStamp = b2Settings.USHRT_MAX)
            
            For Local i:Int = 0 Until m_proxyPool.Length
                
                m_proxyPool[i].timeStamp = 0
            End
            
            m_timeStamp = 1
        Else
            
            
            m_timeStamp += 1
            
        End
    End
    
    Field m_pairManager:b2PairManager = New b2PairManager()
    Field m_proxyPool:b2Proxy[] = New b2Proxy[128]
    Field m_freeProxy:b2Proxy
    Field m_bounds:FlashArray<FlashArray<b2Bound> >
    Field m_querySortKeys:FlashArray<b2Proxy> = New FlashArray<b2Proxy>()
    Field m_queryResults:FlashArray<b2Proxy> = New FlashArray<b2Proxy>()
    Field m_queryResultCount:Int
    Field m_worldAABB:b2AABB
    Field m_quantizationFactor:b2Vec2 = New b2Vec2()
    Field m_proxyCount:Int
    Field m_timeStamp:Int
    
    Global s_validate:Bool = False
    Const b2_invalid:Int = b2Settings.USHRT_MAX
    Const b2_nullEdge:Int = b2Settings.USHRT_MAX
    
    Function BinarySearch : Int (bounds:FlashArray<b2Bound>, count:Int, value:Int)
        
        Local low :Int = 0
        Local high :Int = count - 1
        While (low <= high)
            
            Local mid :Int = ((low + high) / 2)
            Local bound :b2Bound = bounds.Get(mid)
            If (bound.value > value)
                
                high = mid - 1
            Else  If (bound.value < value)
                
                
                low = mid + 1
            Else
                
                
                Return Int(mid)
            End
        End
        Return Int(low)
    End
End




