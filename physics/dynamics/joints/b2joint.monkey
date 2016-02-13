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
'* The base joint class. Joints are used to constraint two bodies together in
'* various fashions. Some joints also feature limits and motors.
'* @see b2JointDef
'*/
#end
Class b2Joint
    #rem
    '/**
    '* Get the type of the concrete joint.
    '*/
    #end
    Method GetType : Int ()
        
        Return m_type
    End
    #rem
    '/**
    '* Get the anchor point on bodyA in world coordinates.
    '*/
    #end
    Method GetAnchorA:Void( out:b2Vec2 )
    End
    #rem
    '/**
    '* Get the anchor point on bodyB in world coordinates.
    '*/
    #end
    Method GetAnchorB:Void( out:b2Vec2 )
    End
    #rem
    '/**
    '* Get the reaction force on body2 at the joint anchor in Newtons.
    '*/
    #end
    Method GetReactionForce:Void (inv_dt:Float, out:b2Vec2 )
    End
    #rem
    '/**
    '* Get the reaction torque on body2 in N*m.
    '*/
    #end
    Method GetReactionTorque : Float (inv_dt:Float)
        Return 0.0
    End
    #rem
    '/**
    '* Get the first body attached to this joint.
    '*/
    #end
    Method GetBodyA : b2Body ()
        
        Return m_bodyA
    End
    #rem
    '/**
    '* Get the second body attached to this joint.
    '*/
    #end
    Method GetBodyB : b2Body ()
        
        Return m_bodyB
    End
    #rem
    '/**
    '* Get the nextItem joint the world joint list.
    '*/
    #end
    Method GetNext : b2Joint ()
        
        Return m_next
    End
    #rem
    '/**
    '* Get the user data pointer.
    '*/
    #end
    Method GetUserData : Object ()
        
        Return m_userData
    End
    #rem
    '/**
    '* Set the user data pointer.
    '*/
    #end
    Method SetUserData : void (data: Object)
        
        m_userData = data
    End
    #rem
    '/**
    '* Short-cut Method to determine if either inactive(body).
    '* @return
    '*/
    #end
    Method IsActive : Bool ()
        
        Return m_bodyA.IsActive() And m_bodyB.IsActive()
    End
    '//--------------- Internals Below -------------------
    
    Function Create : b2Joint (def:b2JointDef, allocator: Object)
        Local joint :b2Joint = null
        Select (def.type)
            
            Case e_distanceJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2DistanceJoint))
                joint = New b2DistanceJoint(b2DistanceJointDef(def))
            Case e_mouseJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2MouseJoint))
                joint = New b2MouseJoint(b2MouseJointDef(def))
            Case e_prismaticJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2PrismaticJoint))
                joint = New b2PrismaticJoint(b2PrismaticJointDef(def))
            Case e_revoluteJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2RevoluteJoint))
                joint = New b2RevoluteJoint(b2RevoluteJointDef(def))
            Case e_pulleyJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2PulleyJoint))
                joint = New b2PulleyJoint(b2PulleyJointDef(def))
            Case e_gearJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2GearJoint))
                joint = New b2GearJoint(b2GearJointDef(def))
            Case e_lineJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2LineJoint))
                joint = New b2LineJoint(b2LineJointDef(def))
            Case e_weldJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2WeldJoint))
                joint = New b2WeldJoint(b2WeldJointDef(def))
            Case e_frictionJoint
                
                '//void* mem = allocator->Allocate(sizeof(b2FrictionJoint))
                joint = New b2FrictionJoint(b2FrictionJointDef(def))
				
			Case e_ropeJoint
				joint = New b2RopeJoint(b2RopeJointDef(def))
				
            Default
                '//b2Settings.B2Assert(False)
            End
            Return joint
        End
        Function Destroy : void (joint:b2Joint, allocator: Object)
            #rem
            '/*joint->~b2Joint()
            'Select (joint.m_type)
            '
            'Case e_distanceJoint
            'allocator->Free(joint, sizeof(b2DistanceJoint))
            'Exit
            'Case e_mouseJoint
            'allocator->Free(joint, sizeof(b2MouseJoint))
            'Exit
            'Case e_prismaticJoint
            'allocator->Free(joint, sizeof(b2PrismaticJoint))
            'Exit
            'Case e_revoluteJoint
            'allocator->Free(joint, sizeof(b2RevoluteJoint))
            'Exit
            'Case e_pulleyJoint
            'allocator->Free(joint, sizeof(b2PulleyJoint))
            'Exit
            'Case e_gearJoint
            'allocator->Free(joint, sizeof(b2GearJoint))
            'Exit
            'Case e_lineJoint
            'allocator->Free(joint, sizeof(b2LineJoint))
            'Exit
            'Case e_weldJoint
            'allocator->Free(joint, sizeof(b2WeldJoint))
            'Exit
            'Case e_frictionJoint
            'allocator->Free(joint, sizeof(b2FrictionJoint))
            'Exit
            'Default
            'B2Assert(False)
            'Exit
            'End
            '*/
            '
            '
            #end
        End
        '* @
        Method New(def:b2JointDef)
            
#If CONFIG = "debug"
            b2Settings.B2Assert(def.bodyA <> def.bodyB)
#End
            m_type = def.type
            m_prev = null
            m_next = null
            m_bodyA = def.bodyA
            m_bodyB = def.bodyB
            m_collideConnected = def.collideConnected
            m_islandFlag = False
            m_userData = def.userData
        End
        
        '// ~b2Joint() {}
        Method InitVelocityConstraints : void (timeStep:b2TimeStep)
        End
        
        
        Method SolveVelocityConstraints : void (timeStep:b2TimeStep)
        End
        
        
        Method FinalizeVelocityConstraints : void ()
        End
        '// This returns True if the position errors are within tolerance.
        Method SolvePositionConstraints : Bool (baumgarte:Float)
            Return False
        End
        
        
        Field m_type:Int
        
        
        Field m_prev:b2Joint
        
        
        Field m_next:b2Joint
        
        
        Field m_edgeA:b2JointEdge = New b2JointEdge()
        
        
        Field m_edgeB:b2JointEdge = New b2JointEdge()
        
        
        Field m_bodyA:b2Body
        
        
        Field m_bodyB:b2Body
        
        
        Field m_islandFlag:Bool
        
        
        Field m_collideConnected:Bool
        
        Field m_userData: Object
        
        '// Cache here per time timeStep to reduce cache misses.
        Field m_localCenterA:b2Vec2 = New b2Vec2()
        
        
        Field m_localCenterB:b2Vec2 = New b2Vec2()
        
        
        Field m_invMassA:Float
        
        
        Field m_invMassB:Float
        
        
        Field m_invIA:Float
        
        
        Field m_invIB:Float
        
        '// ENUMS
        
        Const e_unknownJoint:Int = 0
        Const e_revoluteJoint:Int = 1
        Const e_prismaticJoint:Int = 2
        Const e_distanceJoint:Int = 3
        Const e_pulleyJoint:Int = 4
        Const e_mouseJoint:Int = 5
        Const e_gearJoint:Int = 6
        Const e_lineJoint:Int = 7
        Const e_weldJoint:Int = 8
        Const e_frictionJoint:Int = 9
	Const e_ropeJoint:Int = 10
        '// enum b2LimitState
        Const e_inactiveLimit:Int = 0
        Const e_atLowerLimit:Int = 1
        Const e_atUpperLimit:Int = 2
        Const e_equalLimits:Int = 3
    End
    
    
