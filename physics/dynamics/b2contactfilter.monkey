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
'* Implement this class to provide collision filtering. In other words, you can implement
'* this class if you want finer control over contact creation.
'*/
#end
Class b2ContactFilter
    #rem
    '/**
    '* Return True if contact calculations should be performed between these two fixtures.
    '* @warning for performance reasons only(this) called when the AABBs begin to overlap.
    '*/
    #end
    Method ShouldCollide : Bool (fixtureA:b2Fixture, fixtureB:b2Fixture)
        
        Local filter1 :b2FilterData = fixtureA.GetFilterData()
        Local filter2 :b2FilterData = fixtureB.GetFilterData()
        If (filter1.groupIndex = filter2.groupIndex And filter1.groupIndex <> 0)
            
            Return filter1.groupIndex > 0
        End
        Local collide :Bool = (filter1.maskBits & filter2.categoryBits) <> 0 And (filter1.categoryBits & filter2.maskBits) <> 0
        Return collide
    End
    #rem
    '/**
    '* Return True if the given fixture should be considered for ray intersection.
    '* By default, cast(userData) as a b2Fixture and resolved(collision) according to ShouldCollide
    '* @see ShouldCollide()
    '* @see b2World#Raycast
    '* @param userData	arbitrary data passed from Raycast or RaycastOne
    '* @param fixture		the fixture that we are testing for filtering
    '* @return a Bool, with a value of False indicating that this fixture should be ignored.
    '*/
    #end
    Method RayCollide : Bool (userData: Object, fixture:b2Fixture)
        
        If(Not(userData))
            Return True
        End
        Return ShouldCollide(b2Fixture(userData),fixture)
    End
    'static b2internal
    global b2_defaultFilter:b2ContactFilter = New b2ContactFilter()
    
End

