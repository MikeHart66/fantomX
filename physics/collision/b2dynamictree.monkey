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



'// A  AABB tree broad-phase, inspired by Nathanael Pressons btDbvt.
#rem
'/**
'* A  tree arranges data in a binary tree to accelerate
'* queries volume(such) queries and ray casts. Leafs are proxies
'* with an AABB. In the tree we expand the proxy AABB by b2_fatAABBFactor
'* so that the proxy bigger(AABB) than the client object. This allows the client
'* object to move by small amounts without triggering a tree update.
'*
'* Nodes are pooled.
'*/
#end

Class TreeQueryCallback Extends QueryCallback Abstract
    Method Callback:Bool(proxy:Object) Abstract
End


Class TreeRayCastCallback Extends RayCastCallback Abstract
    Method Callback:Float(a:Object,b:b2RayCastInput) Abstract
End
Class b2DynamicTree
    #rem
    '/**
    '* Constructing the tree initializes the node pool.
    '*/
    #end
    Method New()
        
        m_root = null
        '// TODO: Maybe allocate some free nodes?
        m_freeList = null
        m_path = 0
        m_insertionCount = 0
    End
    #rem
    '/*
    'Method Dump : void (node:b2DynamicTreeNode=null, depth:Int=0)
    '
    'if (Not(node))
    '
    'node = m_root
    'End
    '
    'if (Not(node))
    'return
    'End
    'For Local i:Int = 0 Until depth  s += " "
    'if (node.userData)
    '
    'Local ud : Object = b2Fixture((node.userData)).GetBody().GetUserData()
    'trace(s + ud)
    'Else
    '
    '
    'trace(s + "-")
    'End
    '
    'if (node.child1)
    'Dump(node.child1, depth + 1)
    'End
    'if (node.child2)
    'Dump(node.child2, depth + 1)
    'End
    'End
    '
    '*/
    #end
    #rem
    '/**
    '* Create a proxy. Provide a tight fitting AABB and a userData.
    '*/
    #end
    Method CreateProxy : b2DynamicTreeNode (aabb:b2AABB, userData: Object)
        
        Local node :b2DynamicTreeNode = AllocateNode()
        '// Fatten the aabb.
        Local extendX :Float = b2Settings.b2_aabbExtension
        Local extendY :Float = b2Settings.b2_aabbExtension
        node.aabb.lowerBound.x = aabb.lowerBound.x - extendX
        node.aabb.lowerBound.y = aabb.lowerBound.y - extendY
        node.aabb.upperBound.x = aabb.upperBound.x + extendX
        node.aabb.upperBound.y = aabb.upperBound.y + extendY
        node.userData = userData
        InsertLeaf(node)
        Return node
    End
    #rem
    '/**
    '* Destroy a proxy. This asserts if the invalid(id).
    '*/
    #end
    Method DestroyProxy : void (proxy:b2DynamicTreeNode)
        
        '//b2Settings.B2Assert(proxy.IsLeaf())
        RemoveLeaf(proxy)
        FreeNode(proxy)
    End
    #rem
    '/**
    '* Move a proxy with a swept AABB. If the proxy has moved outside of its fattened AABB,
    '* then the removed(proxy) from the tree and re-inserted. Otherwise
    '* the Method returns immediately.
    '*/
    #end
    Method MoveProxy : Bool (proxy:b2DynamicTreeNode, aabb:b2AABB, displacement:b2Vec2)
        
#If CONFIG = "debug"
        b2Settings.B2Assert(proxy.IsLeaf())
#End
        If (proxy.aabb.Contains(aabb))
            Return False
        End
        
        RemoveLeaf(proxy)
        '// Extend AABB
        Local extendX :Float = -displacement.x
        
        If( displacement.x > 0 )
            extendX = displacement.x
        End
        
        extendX *= b2Settings.b2_aabbMultiplier
        extendX += b2Settings.b2_aabbExtension
        
        Local extendY :Float = -displacement.y
        
        If( displacement.y > 0 )
            extendY = displacement.y
        End
        
        extendY *= b2Settings.b2_aabbMultiplier
        extendY += b2Settings.b2_aabbExtension
        
        proxy.aabb.lowerBound.x = aabb.lowerBound.x - extendX
        proxy.aabb.lowerBound.y = aabb.lowerBound.y - extendY
        proxy.aabb.upperBound.x = aabb.upperBound.x + extendX
        proxy.aabb.upperBound.y = aabb.upperBound.y + extendY
        InsertLeaf(proxy)
        Return True
    End
    #rem
    '/**
    '* Perform some iterations to re-balance the tree.
    '*/
    #end
    Method Rebalance : void (iterations:Int)
        
        If (m_root = null)
            Return
        End
        For Local i:Int = 0 Until iterations
            
            Local node :b2DynamicTreeNode = m_root
            Local bit :Int = 0
            While (node.IsLeaf() = False)
                
                If( (m_path Shr bit) & 1  )
                    node = node.child2
                Else
                    
                    
                    node = node.child1
                    
                End
                
                bit = (bit + 1) & 31
                
                '// 0-31 bits in a uint
            End
            
            m_path += 1
            
            RemoveLeaf(node)
            InsertLeaf(node)
        End
    End
    Method GetFatAABB : b2AABB (proxy:b2DynamicTreeNode)
        
        Return proxy.aabb
    End
    #rem
    '/**
    '* Get user data from a proxy. Returns null if the invalid(proxy).
    '*/
    #end
    Method GetUserData : Object (proxy:b2DynamicTreeNode)
        
        Return proxy.userData
    End
    #rem
    '/**
    '* Query an AABB for overlapping proxies. The callback
    '* is called for each proxy that overlaps the supplied AABB.
    '* The callback should match Method signature
    '* <code>fuction callback(proxy:b2DynamicTreeNode):Bool</code>
    '* and should return False to trigger premature termination.
    '*/
    #end
	
	Field nodeStack:b2DynamicTreeNode[] = New b2DynamicTreeNode[128]
    
    Method Query : void (callback:QueryCallback, aabb:b2AABB)
        
        If (m_root = null)
            Return
        End
        Local count:Int = 0
		Local nodeStackLength:Int = nodeStack.Length()
        nodeStack[count] = m_root
		count += 1
        While (count > 0)
            count -= 1
            Local node:b2DynamicTreeNode = nodeStack[count]
			
			'This is manually inlined from AABB.TestOverlap!
			Local overlap:Bool = True
			Local upperBound:b2Vec2 = node.aabb.upperBound
			Local otherLowerBound:b2Vec2 = aabb.lowerBound
			
			If (otherLowerBound.x > upperBound.x)
				overlap = False
			ElseIf(otherLowerBound.y > upperBound.y)
				overlap = False
			Else
				Local otherUpperBound:b2Vec2 = aabb.upperBound
				Local lowerBound:b2Vec2 = node.aabb.lowerBound
				If (lowerBound.x > otherUpperBound.x)
					overlap = False
				ElseIf(lowerBound.y > otherUpperBound.y)
					overlap = False
				End
			End
			
            'If (node.aabb.TestOverlap(aabb))
             If (overlap)
                
                If (node.child1 = Null)'IsLeaf())
                    
                    Local proceed :Bool = callback.Callback(node)
                    If (Not(proceed))
                        Return
                    End
                Else
                    
                    '// No stack limit, so no assert
                    If count + 2 >= nodeStackLength
						nodeStack = nodeStack.Resize(count * 2)
						nodeStackLength = count * 2
					End
                    nodeStack[count] = node.child1
					count += 1
                    nodeStack[count] = node.child2
					count += 1
                End
            End
        End
    End
    #rem
    '/**
    '* Ray-cast against the proxies in the tree. This relies on the callback
    '* to perform a exact ray-cast in the case were the proxy contains a shape.
    '* The callback also performs the any collision filtering. This has performance
    '* roughly equal to k * log(n), where the(k) number of collisions and the(n)
    '* number of proxies in the tree.
    '* @param input the ray-cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1).
    '* @param callback a callback class called(that) for each proxy hit(that) by the ray.
    '* It should be of signature:
    '* <code>Method callback:Void(input:b2RayCastInput, proxy: Object):void</code>
    '*/
    #end
    Method RayCast : void (callback:RayCastCallback, input:b2RayCastInput)
        
        If (m_root = null)
            Return
        End
        Local p1 :b2Vec2 = input.p1
        Local p2 :b2Vec2 = input.p2
        Local r :b2Vec2 = New b2Vec2()
        b2Math.SubtractVV(p1, p2, r)
        '//b2Settings.B2Assert(r.LengthSquared() > 0.0)
        r.Normalize()
        '// perpendicular(v) to the segment
        Local v :b2Vec2 = New b2Vec2()
        b2Math.CrossFV(1.0, r, v)
        Local abs_v :b2Vec2 = New b2Vec2()
        b2Math.AbsV(v, abs_v)
        Local maxFraction :Float = input.maxFraction
        '// Build a bounding box for the segment
        Local segmentAABB :b2AABB = New b2AABB()
        Local tX :Float
        Local tY :Float
        
        tX = p1.x + maxFraction * (p2.x - p1.x)
        tY = p1.y + maxFraction * (p2.y - p1.y)
        segmentAABB.lowerBound.x = b2Math.Min(p1.x, tX)
        segmentAABB.lowerBound.y = b2Math.Min(p1.y, tY)
        segmentAABB.upperBound.x = b2Math.Max(p1.x, tX)
        segmentAABB.upperBound.y = b2Math.Max(p1.y, tY)
        
        Local stack :FlashArray<b2DynamicTreeNode> = New FlashArray<b2DynamicTreeNode>()
        Local count :Int = 0
        
        stack.Set( count,  m_root )
        count += 1
        
        While (count > 0)
            count -= 1
            Local node :b2DynamicTreeNode = stack.Get(count)
            If (node.aabb.TestOverlap(segmentAABB) = False)
                Continue
            End
            '// Separating axis for segment (Gino, p80)
            '// |dot(v, p1 - c)| > dot(|v|,h)
            Local c :b2Vec2 = New b2Vec2()
            node.aabb.GetCenter(c)
            Local h :b2Vec2 = New b2Vec2()
            node.aabb.GetExtents(h)
            Local separation :Float = Abs(v.x * (p1.x - c.x) + v.y * (p1.y - c.y))	- abs_v.x * h.x - abs_v.y * h.y
            
            If (separation > 0.0)
                Continue
            End
            
            If (node.IsLeaf())
                Local subInput :b2RayCastInput = New b2RayCastInput()
                subInput.p1 = input.p1
                subInput.p2 = input.p2
                subInput.maxFraction = input.maxFraction
                maxFraction = callback.Callback(node, subInput)
                If (maxFraction = 0.0)
                    Return
                End
                '//Update the segment bounding box
                
                tX = p1.x + maxFraction * (p2.x - p1.x)
                tY = p1.y + maxFraction * (p2.y - p1.y)
                segmentAABB.lowerBound.x = b2Math.Min(p1.x, tX)
                segmentAABB.lowerBound.y = b2Math.Min(p1.y, tY)
                segmentAABB.upperBound.x = b2Math.Max(p1.x, tX)
                segmentAABB.upperBound.y = b2Math.Max(p1.y, tY)
            Else
                '// No stack limit, so no assert
                stack.Set( count,  node.child1 )
                count += 1
                stack.Set( count,  node.child2 )
                count += 1
            End
        End
    End
    
    
    Method AllocateNode : b2DynamicTreeNode ()
        
        '// Peel a node off the free list
        If (m_freeList)
            
            Local node :b2DynamicTreeNode = m_freeList
            m_freeList = node.parent
            node.parent = null
            node.child1 = null
            node.child2 = null
            Return node
        End
        '// Ignore length pool expansion and relocation found in the C
        '// As we are using heap allocation
        Return New b2DynamicTreeNode()
    End
    Method FreeNode : void (node:b2DynamicTreeNode)
        
        node.parent = m_freeList
        m_freeList = node
    End
    
    Global shared_aabbCenter:b2Vec2 = New b2Vec2()
    
    Method InsertLeaf : void (leaf:b2DynamicTreeNode)
        
        m_insertionCount += 1
        
        If (m_root = null)
            
            m_root = leaf
            m_root.parent = null
            Return
        End
        leaf.aabb.GetCenter(shared_aabbCenter)
        Local centerX:Float = shared_aabbCenter.x
	    Local centerY:Float = shared_aabbCenter.y
	            
		Local sibling :b2DynamicTreeNode = m_root
        If (sibling.child1 <> Null) 'sibling.IsLeaf() = False)
            Repeat
	            Local child1 :b2DynamicTreeNode = sibling.child1
	            Local child2 :b2DynamicTreeNode = sibling.child2
	            '//b2Vec2 delta1 = b2Abs(m_nodes.Get(child1).aabb.GetCenter() - center)
	            '//b2Vec2 delta2 = b2Abs(m_nodes.Get(child2).aabb.GetCenter() - center)
	            '//float32 norm1 = delta1.x + delta1.y
	            '//float32 norm2 = delta2.x + delta2.y
				Local aabb1:b2AABB = child1.aabb
				Local aabb2:b2AABB = child2.aabb
				Local lowerBound:b2Vec2 = aabb1.lowerBound
				Local upperBound:b2Vec2 = aabb1.upperBound
				
				Local midX:Float = (lowerBound.x + upperBound.x) * 0.5 - centerX
				If midX < 0
					midX = -midX
				End
				Local midY:Float = (lowerBound.y + upperBound.y) * 0.5 - centerY
				If midY < 0
					midY = -midY
				End
				
				Local norm1:Float = midX + midY
	            
				lowerBound = aabb2.lowerBound
				upperBound = aabb2.upperBound
				
				midX = (lowerBound.x + upperBound.x) * 0.5 - centerX
				If midX < 0
					midX = -midX
				End
				midY = (lowerBound.y + upperBound.y) * 0.5 - centerY
				If midY < 0
					midY = -midY
				End
				
				Local norm2:Float = midX + midY
				
	            If (norm1 < norm2)
	                sibling = child1
	            Else
	                sibling = child2
	            End
            Until (sibling.child1 = Null)'sibling.IsLeaf())
        End
        '// Create a parent for the siblings
        Local node1 :b2DynamicTreeNode = sibling.parent
        Local node2 :b2DynamicTreeNode = AllocateNode()
        node2.parent = node1
        node2.userData = null
        node2.aabb.Combine(leaf.aabb, sibling.aabb)
        If (node1)
            
            If (sibling.parent.child1 = sibling)
                node1.child1 = node2
            Else
                node1.child2 = node2
            End
            node2.child1 = sibling
            node2.child2 = leaf
            sibling.parent = node2
            leaf.parent = node2
            
            Repeat
	            If (node1.aabb.Contains(node2.aabb))
	                Exit
	            End
	            node1.aabb.Combine(node1.child1.aabb, node1.child2.aabb)
	            node2 = node1
	            node1 = node1.parent
            Until(node1 = Null)
        Else
            node2.child1 = sibling
            node2.child2 = leaf
            sibling.parent = node2
            leaf.parent = node2
            m_root = node2
        End
    End
	
    Method RemoveLeaf : void (leaf:b2DynamicTreeNode)
        
        If ( leaf = m_root)
            
            m_root = null
            Return
        End
        Local node2 :b2DynamicTreeNode = leaf.parent
        Local node1 :b2DynamicTreeNode = node2.parent
        Local sibling :b2DynamicTreeNode
        If (node2.child1 = leaf)
            
            sibling = node2.child2
        Else
            
            
            sibling = node2.child1
        End
        If (node1)
            
            '// Destroy node2 and connect node1 to sibling
            If (node1.child1 = node2)
                
                node1.child1 = sibling
            Else
                
                
                node1.child2 = sibling
            End
            
            sibling.parent = node1
            FreeNode(node2)
            '// Adjust the ancestor bounds
            While (node1)
                
                Local oldAABB :b2AABB = node1.aabb
                node1.aabb = b2AABB.StaticCombine(node1.child1.aabb, node1.child2.aabb)
                If (oldAABB.Contains(node1.aabb))
                    Exit
                End
                node1 = node1.parent
            End
            
        Else
            
            
            m_root = sibling
            sibling.parent = null
            FreeNode(node2)
        End
    End
    Field m_root:b2DynamicTreeNode
    
    
    Field m_freeList:b2DynamicTreeNode
    
    '* used(This) for incrementally traverse the tree for rebalancing
    Field m_path:Int
    
    Field m_insertionCount:Int
    
    
End







