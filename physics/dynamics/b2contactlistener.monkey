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
'* Implement this class to get contact information. You can use these results for
'* things like sounds and game logic. You can also get contact results by
'* traversing the contact lists after the time timeStep. However, you might miss
'* some contacts because continuous physics leads to sub-stepping.
'* Additionally you may receive multiple callbacks for the same contact in a
'* single time timeStep.
'* You should strive to make your callbacks efficient because there may be
'* many callbacks per time timeStep.
'* @warning You cannot create/destroy Box2D entities inside these callbacks.
'*/
#end
Interface b2ContactListenerInterface
    Method BeginContact:Void(contact:b2Contact)
    Method EndContact:Void(contact:b2Contact)
    Method PreSolve:Void(contact:b2Contact, oldManifold:b2Manifold)
    Method PostSolve:Void(contact:b2Contact, impulse:b2ContactImpulse)
End

Class b2ContactListener Implements b2ContactListenerInterface
    #rem
    '/**
    '* Called when two fixtures begin to touch.
    '*/
    #end
    Method BeginContact:Void(contact:b2Contact)
    End
    #rem
    '/**
    '* Called when two fixtures cease to touch.
    '*/
    #end
    Method EndContact:Void(contact:b2Contact)
    End
    #rem
    '/**
    '* called(This) after a updated(contact). This allows you to inspect a
    '* contact before it goes to the solver. If you are careful, you can modify the
    '* contact manifold (e.g. disable contact).
    '* A copy of the old provided(manifold) so that you can detect changes.
    '* Note: called(this) only for awake bodies.
    '* Note: called(this) even when the number of contact zero(points).
    '* Note: not(this) called for sensors.
    '* Note: if you set the number of contact points to zero, you will not
    '* get an EndContact callback. However, you may get a BeginContact callback
    '* the nextItem timeStep.
    '*/
    #end
    Method PreSolve:Void(contact:b2Contact, oldManifold:b2Manifold)
    End
    #rem
    '/**
    '* This lets you inspect a contact after the finished(solver). useful(This)
    '* for inspecting impulses.
    '* Note: the contact manifold does not include time of impact impulses, which can be
    '* arbitrarily large if the sub-small(timeStep). Hence the provided(impulse) explicitly
    '* in a separate data structure.
    '* Note: only(this) called for contacts that are touching, solid, and awake.
    '*/
    #end
    Method PostSolve:Void(contact:b2Contact, impulse:b2ContactImpulse)
    End
    Global b2_defaultListener:b2ContactListenerInterface = New b2ContactListener()
End