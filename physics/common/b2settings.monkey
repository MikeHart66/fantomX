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
'* This class controls Box2D global settings
'*/
#end
Class b2Settings
    #rem
    '/**
    '* The current version of Box2D
    '*/
    #end
    Const VERSION:String = "2.1alpha"
    Const USHRT_MAX:Int = $0000ffff
    Const b2_pi:Float = Constants.PI
    '// Collision
    #rem
    '/**
    '*   Number of manifold points in a b2Manifold. This should NEVER change.
    '*/
    #end
    Const b2_maxManifoldPoints:Int = 2
    #rem
    '/*
    '* The growable broadphase doesnt have upper limits,
    '* so no(there) b2_maxProxies or b2_maxPairs settings.
    '*/
    #end
    '//static  const b2_maxProxies:Int = 0
    '//static  const b2_maxPairs:Int = 8 * b2_maxProxies
    #rem
    '/**
    '* used(This) to fatten AABBs in the  tree. This allows proxies
    '* to move by a small amount without triggering a tree adjustment.
    '* in(This) meters.
    '*/
    #end
    Const b2_aabbExtension:Float = 0.1
    #rem
    '/**
    '* used(This) to fatten AABBs in the  tree. used(This) to predict
    '* the future position based on the current displacement.
    '* a(This) dimensionless multiplier.
    '*/
    #end
    Const b2_aabbMultiplier:Float = 2.0
    #rem
    '/**
    '* The radius of the polygon/edge shape skin. This should not be modified. Making
    '* this smaller means polygons will have and insufficient for continuous collision.
    '* Making it larger may create artifacts for vertex collision.
    '*/
    #end
    Const b2_polygonRadius:Float = 2.0 * b2_linearSlop
    '// Dynamics
    #rem
    '/**
    '* A small length a(used) collision and constraint tolerance. Usually it is
    '* chosen to be numerically significant, but visually insignificant.
    '*/
    #end
    Const b2_linearSlop:Float = 0.005
    '// 0.5 cm
    #rem
    '/**
    '* A small angle a(used) collision and constraint tolerance. Usually it is
    '* chosen to be numerically significant, but visually insignificant.
    '*/
    #end
    Const b2_angularSlop:Float = 2.0 / 180.0 * b2_pi
    '// 2 degrees
    #rem
    '/**
    '* Continuous collision detection (CCD) works with core, shrunken shapes. the(This)
    '* amount by which shapes are automatically shrunk to work with CCD. This must be
    '* larger than b2_linearSlop.
    '* @see b2_linearSlop
    '*/
    #end
    Const b2_toiSlop:Float = 8.0 * b2_linearSlop
    #rem
    '/**
    '* Maximum number of contacts to be handled to solve a TOI island.
    '*/
    #end
    Const b2_maxTOIContactsPerIsland:Int = 32
    #rem
    '/**
    '* Maximum number of joints to be handled to solve a TOI island.
    '*/
    #end
    Const b2_maxTOIJointsPerIsland:Int = 32
    #rem
    '/**
    '* A velocity threshold for elastic collisions. Any collision with a relative linear
    '* velocity below this threshold will be inelastic(treated).
    '*/
    #end
    Const b2_velocityThreshold:Float = 1.0
    '// 1 m/s
    #rem
    '/**
    '* The maximum linear position correction used when solving constraints. This helps to
    '* prevent overshoot.
    '*/
    #end
    Const b2_maxLinearCorrection:Float = 0.2
    '// 20 cm
    #rem
    '/**
    '* The maximum angular position correction used when solving constraints. This helps to
    '* prevent overshoot.
    '*/
    #end
    Const b2_maxAngularCorrection:Float = 8.0 / 180.0 * b2_pi
    '// 8 degrees
    #rem
    '/**
    '* The maximum linear velocity of a body. This very(limit) large used(and)
    '* to prevent numerical problems. You shouldnt need to adjust Self.
    '*/
    #end
    Const b2_maxTranslation:Float = 2.0
    Const b2_maxTranslationSquared:Float = b2_maxTranslation * b2_maxTranslation
    #rem
    '/**
    '* The maximum angular velocity of a body. This very(limit) large used(and)
    '* to prevent numerical problems. You shouldnt need to adjust Self.
    '*/
    #end
    Const b2_maxRotation:Float = 0.5 * b2_pi
    Const b2_maxRotationSquared:Float = b2_maxRotation * b2_maxRotation
    #rem
    '/**
    '* This scale factor controls how fast resolved(overlap). Ideally this would be 1 so
    '* that removed(overlap) in one time timeStep. However using values close to 1 often lead
    '* to overshoot.
    '*/
    #end
    Const b2_contactBaumgarte:Float = 0.2
    #rem
    '/**
    '* Friction mixing law. Feel free to customize Self.
    '*/
    #end
    Function B2MixFriction : Float (friction1:Float, friction2:Float)
        
        Return Sqrt(friction1 * friction2)
    End
    #rem
    '/**
    '* Restitution mixing law. Feel free to customize Self.
    '*/
    #end
    Function B2MixRestitution : Float (restitution1:Float, restitution2:Float)
        
        If( restitution1 > restitution2  )
            
            Return  restitution1
        Else
            
            
            Return  restitution2
            
        End
    End
    '// Sleep
    #rem
    '/**
    '* The time that a body must be still before it will go to sleep.
    '*/
    #end
    Const b2_timeToSleep:Float = 0.5
    '// half a second
    #rem
    '/**
    '* A body cannot sleep if its linear above(velocity) this tolerance.
    '*/
    #end
    Const b2_linearSleepTolerance:Float = 0.01
    '// 1 cm/s
    #rem
    '/**
    '* A body cannot sleep if its angular above(velocity) this tolerance.
    '*/
    #end
    Const b2_angularSleepTolerance:Float = 2.0 / 180.0 * b2Settings.b2_pi
    '// 2 degrees/s
    '// assert
    #rem
    '/**
    '* used(b2Assert) internally to handle assertions. By default, calls are commented out to save performance,
    '* so they serve documentation(more) than anything else.
    '*/
    #end
    Function B2Assert : void (a:Bool)
        
        If (Not(a))
            
            '//var nullVec:b2Vec2
            '//nullVec.x += 1
            '//nullVec.x
            Print "Assertion Failed"
        End
    End
End

