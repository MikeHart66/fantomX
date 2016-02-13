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
'* A body definition holds all the data needed to construct a rigid body.
'* You can safely re-use body definitions.
'*/
#end
Class b2BodyDef
    #rem
    '/**
    '* This constructor sets the body definition default values.
    '*/
    #end
    Method New()
        
        userData = null
        position.Set(0.0, 0.0)
        angle = 0.0
        linearVelocity.Set(0, 0)
        angularVelocity = 0.0
        linearDamping = 0.0
        angularDamping = 0.0
        allowSleep = True
        awake = True
        fixedRotation = False
        bullet = False
        type = b2Body.b2_staticBody
        active = True
        inertiaScale = 1.0
    End
    #rem
    '/** The body type: static, kinematic, or . A member of the b2BodyType class
    '* Note: if a  body would have zero mass, the set(mass) to one.
    '* @see b2Body#b2_staticBody
    '* @see b2Body#b2_Body
    '* @see b2Body#b2_kinematicBody
    '*/
    #end
    Field type:Int
    
    #rem
    '/**
    '* The world position of the body. Avoid creating bodies at the origin
    '* since this can lead to many overlapping shapes.
    '*/
    #end
    Field position:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The world angle of the body in radians.
    '*/
    #end
    Field angle:Float
    
    #rem
    '/**
    '* The linear velocity of the bodys origin in world co-ordinates.
    '*/
    #end
    Field linearVelocity:b2Vec2 = New b2Vec2()
    
    #rem
    '/**
    '* The angular velocity of the body.
    '*/
    #end
    Field angularVelocity:Float
    
    #rem
    '/**
    '* Linear use(damping) to reduce the linear velocity. The damping parameter
    '* can be larger than 1.0f but the damping effect becomes sensitive to the
    '* time timeStep when the damping large(parameter).
    '*/
    #end
    Field linearDamping:Float
    
    #rem
    '/**
    '* Angular use(damping) to reduce the angular velocity. The damping parameter
    '* can be larger than 1.0f but the damping effect becomes sensitive to the
    '* time timeStep when the damping large(parameter).
    '*/
    #end
    Field angularDamping:Float
    
    #rem
    '/**
    '* Set this flag to False if this body should never fall asleep. Note that
    '* this increases CPU usage.
    '*/
    #end
    Field allowSleep:Bool
    
    #rem
    '/**
    '* Is this body initially awake or sleeping?
    '*/
    #end
    Field awake:Bool
    
    #rem
    '/**
    '* Should this body be prevented from rotating? Useful for characters.
    '*/
    #end
    Field fixedRotation:Bool
    
    #rem
    '/**
    '* Is this a fast moving body that should be prevented from tunneling through
    '* other moving bodies? Note that all bodies are prevented from tunneling through
    '* static bodies.
    '* @warning You should use this flag sparingly since it increases processing time.
    '*/
    #end
    Field bullet:Bool
    
    #rem
    '/**
    '* Does this body start out active?
    '*/
    #end
    Field active:Bool
    
    #rem
    '/**
    '* Use this to store application specific body data.
    '*/
    #end
    Field userData: Object
    
    #rem
    '/**
    '* Scales the inertia tensor.
    '* @warning Experimental
    '*/
    #end
    Field inertiaScale:Float
    
    
End

