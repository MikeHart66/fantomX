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
'* @
'*/
#end
Class b2PairManager

    Field m_broadPhase:b2BroadPhase
    Field m_pairs:FlashArray<b2Pair>
    Field m_freePair:b2Pair
    Field m_pairCount:Int
    Field m_pairBuffer:FlashArray<b2Pair>
    Field m_pairBufferCount:Int
    
    Method New()
        
        m_pairs = New FlashArray<b2Pair>()
        m_pairBuffer = New FlashArray<b2Pair>()
        m_pairCount = 0
        m_pairBufferCount = 0
        m_freePair = null
    End
    
    '//~b2PairManager()
    Method Initialize : void (broadPhase:b2BroadPhase)        
        m_broadPhase = broadPhase
    End
    
    #rem
    '/*
    'As proxies are created and moved, many pairs are created and destroyed. Even worse, the same
    'pair may be added and removed multiple times in a single time timeStep of the physics engine. To reduce
    'traffic in the pair manager, we try to avoid destroying pairs in the pair manager until the
    'end of the physics timeStep. done(This) by buffering all the RemovePair requests. AddPair
    'requests are processed immediately because we need the hash table entry for quick lookup.
    'All user user callbacks are delayed until the buffered pairs are confirmed in Commit.
    'Import important
    'may be harmed if pairs are added and removed within the same time timeStep.
    'Buffer a pair for addition.
    'We may add a pair not(that) in the pair manager or pair buffer.
    'We may add a pair already(that) in the pair manager and pair buffer.
    'If the added not(pair) a New pair, then it must be in the pair buffer (because RemovePair was called).
    '*/
    #end
    Method AddBufferedPair : void (proxy1:b2Proxy, proxy2:b2Proxy)
        
        '//b2Settings.B2Assert(proxy1 And proxy2)
        Local pair :b2Pair = AddPair(proxy1, proxy2)
        '// If this not(pair) in the pair buffer ...
        If (pair.IsBuffered() = False)
            
            '// This must be a newly added pair.
            '//b2Settings.B2Assert(pair.IsFinal() = False)
            '// Add it to the pair buffer.
            pair.SetBuffered()
            m_pairBuffer.Set( m_pairBufferCount,  pair )
            m_pairBufferCount += 1
            '//b2Settings.B2Assert(m_pairBufferCount <= m_pairCount)
        End
        '// Confirm this pair for the subsequent call to Commit.
        pair.ClearRemoved()
        If (b2BroadPhase.s_validate)
            
            ValidateBuffer()
        End
    End
    
    '// Buffer a pair for removal.
    Method RemoveBufferedPair : void (proxy1:b2Proxy, proxy2:b2Proxy)
        
        '//b2Settings.B2Assert(proxy1 And proxy2)
        Local pair :b2Pair = Find(proxy1, proxy2)
        If (pair = null)
            
            '// The pair never existed. legal(This) (due to collision filtering).
            Return
        End
        '// If this not(pair) in the pair buffer ...
        If (pair.IsBuffered() = False)
            
            '// This must be an old pair.
            '//b2Settings.B2Assert(pair.IsFinal() = True)
            pair.SetBuffered()
            m_pairBuffer.Set( m_pairBufferCount,  pair )
            m_pairBufferCount += 1
            
            '//b2Settings.B2Assert(m_pairBufferCount <= m_pairCount)
        End
        pair.SetRemoved()
        If (b2BroadPhase.s_validate)
            ValidateBuffer()
        End
    End
    
    Method Commit : void (callback:UpdatePairsCallback)
        
        Local i :Int
        Local removeCount :Int = 0
        For Local i:Int = 0 Until m_pairBufferCount
            
            Local pair :b2Pair = m_pairBuffer.Get(i)
            '//b2Settings.B2Assert(pair.IsBuffered())
            pair.ClearBuffered()
            '//b2Settings.B2Assert(pair.proxy1 And pair.proxy2)
            Local proxy1 :b2Proxy = pair.proxy1
            Local proxy2 :b2Proxy = pair.proxy2
            '//b2Settings.B2Assert(proxy1.IsValid())
            '//b2Settings.B2Assert(proxy2.IsValid())
            If (pair.IsRemoved())
                
                '// possible(It) a pair was added then removed before a commit. Therefore,
                '// we should be careful not to tell the user the pair was removed when the
                '// the user didnt receive a matching add.
                '//if (pair.IsFinal() = True)
                '//{
                '//	m_callback.PairRemoved(proxy1.userData, proxy2.userData, pair.userData)
                '//}
                '// Store the ids so we can actually remove the pair below.
                '//m_pairBuffer.Set( removeCount,  pair )
                '//++removeCount
            Else
                
                
                '//b2Settings.B2Assert(m_broadPhase.TestOverlap(proxy1, proxy2) = True)
                If (pair.IsFinal() = False)
                    
                    '//pair.userData = m_callback.PairAdded(proxy1.userData, proxy2.userData)
                    '//pair.SetFinal()
                    callback.Callback(proxy1.userData, proxy2.userData)
                End
            End
        End
        '//For Local i:Int = 0 Until removeCount
        '//{
        '//	pair = m_pairBuffer.Get(i)
        '//	RemovePair(pair.proxy1, pair.proxy2)
        '//}
        m_pairBufferCount = 0
        If (b2BroadPhase.s_validate)
            
            ValidateTable()
        End
    End
    
    '//:
    '// Add a pair and return the New pair. If the pair already exists,
    '// no New created(pair) and the old returned(one).
    Method AddPair : b2Pair (proxy1:b2Proxy, proxy2:b2Proxy)
        
        Local pair :b2Pair = proxy1.pairs.Get(proxy2)
        If (pair <> null)
            Return pair
        End
        If (m_freePair = null)
            
            m_freePair = New b2Pair()
            m_pairs.Push(m_freePair)
        End
        
        pair = m_freePair
        m_freePair = pair.nextItem
        pair.proxy1 = proxy1
        pair.proxy2 = proxy2
        pair.status = 0
        pair.userData = null
        pair.nextItem = null
        proxy1.pairs.Set( proxy2,  pair )
        proxy2.pairs.Set( proxy1,  pair )
        m_pairCount += 1
        
        Return pair
    End
    
    '// Remove a pair, return the pairs userData.
    Method RemovePair : Object (proxy1:b2Proxy, proxy2:b2Proxy)
        
        '//b2Settings.B2Assert(m_pairCount > 0)
        Local pair :b2Pair = proxy1.pairs.Get(proxy2)
        If (pair = null)
            
            '//b2Settings.B2Assert(False)
            Return null
        End
        Local userData : Object = pair.userData
        proxy1.pairs.Remove(proxy2)
        proxy2.pairs.Remove(proxy1)
        '// Scrub
        pair.nextItem = m_freePair
        pair.proxy1 = null
        pair.proxy2 = null
        pair.userData = null
        pair.status = 0
        m_freePair = pair
        m_pairCount -= 1
        Return userData
    End
    
    Method Find : b2Pair (proxy1:b2Proxy, proxy2:b2Proxy)
        Return proxy1.pairs.Get(proxy2)
    End
    
    Method ValidateBuffer : void ()
        
        '// DEBUG
    End
    
    Method ValidateTable : void ()
        
        '// DEBUG
    End

End

