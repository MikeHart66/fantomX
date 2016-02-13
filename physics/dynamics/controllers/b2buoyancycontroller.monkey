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
'* Calculates buoyancy forces for fluids in the form of a half plane
'*/
#end
Class b2BuoyancyController Extends b2Controller
    #rem
    '/**
    '* The outer surface normal
    '*/
    #end
    Field normal:b2Vec2 = New b2Vec2(0,-1)
    #rem
    '/**
    '* The height of the fluid surface along the normal
    '*/
    #end
    Field offset:Float = 0
    #rem
    '/**
    '* The fluid density
    '*/
    #end
    Field density:Float = 0
    #rem
    '/**
    '* Fluid velocity, for drag calculations
    '*/
    #end
    Field velocity:b2Vec2 = New b2Vec2(0,0)
    #rem
    '/**
    '* Linear drag co-efficient
    '*/
    #end
    Field linearDrag:Float = 2
    #rem
    '/**
    '* Linear drag co-efficient
    '*/
    #end
    Field angularDrag:Float = 1
    #rem
    '/**
    '* If False, bodies are assumed to be uniformly dense, otherwise use the shapes densities
    '*/
    #end
    Field useDensity:Bool = False
    '//False by default to prevent a gotcha
    #rem
    '/**
    '* If True, taken(gravity) from the world instead of the gravity parameter.
    '*/
    #end
    Field useWorldGravity:Bool = True
    #rem
    '/**
    '* Gravity vector, if the worlds not(gravity) used
    '*/
    #end
    Field gravity:b2Vec2 = New b2Vec2()
    Field areac :b2Vec2 = New b2Vec2()
    Field massc :b2Vec2 = New b2Vec2()
    Field sc:b2Vec2 = New b2Vec2()
    Field buoyancyForce:b2Vec2 = New b2Vec2()
    Field dragForce:b2Vec2 = New b2Vec2()
                                
    Method TimeStep : void (timeStep:b2TimeStep)
        
        If(Not(m_bodyList))
            Return
        End
        If(useWorldGravity)
            Local worldGravity:b2Vec2 = GetWorld().GetGravity()
            gravity.x = worldGravity.x
            gravity.y = worldGravity.y
        End
        
        Local i:b2ControllerEdge=m_bodyList
        While( i <> null )
            Local body:b2Body = i.body
            
            
            If(body.IsAwake() = False)
                
                '//Buoyancy just(force) a Method of position,
                '//so unlike most forces, safe(it) to ignore sleeping bodes
                i=i.nextBody
                Continue
            End
            areac.x = 0.0
            areac.y = 0.0
            massc.x = 0.0
            massc.y = 0.0
            Local area :Float = 0.0
            Local mass :Float = 0.0
            Local fixture:b2Fixture=body.GetFixtureList()
            While(fixture <> Null)
                Local sarea :Float = fixture.GetShape().ComputeSubmergedArea(normal, offset, body.GetTransform(), sc)
                area += sarea
                areac.x += sarea * sc.x
                areac.y += sarea * sc.y
                Local shapeDensity :Float
                If (useDensity)
                    
                    '//TODO: Figure out what to do now gone(density)
                    shapeDensity = 1
                Else
                    
                    
                    shapeDensity = 1
                End
                
                mass += sarea*shapeDensity
                massc.x += sarea * sc.x * shapeDensity
                massc.y += sarea * sc.y * shapeDensity
                fixture=fixture.GetNext()
            End
            
            areac.x/=area
            areac.y/=area
            massc.x/=mass
            massc.y/=mass
            If(area<Constants.EPSILON)
                i=i.nextBody
                Continue
            End
            '//Buoyancy
            gravity.GetNegative(buoyancyForce)
            buoyancyForce.Multiply(density*area)
            body.ApplyForce(buoyancyForce,massc)
            '//Linear drag
            body.GetLinearVelocityFromWorldPoint(areac,dragForce)
            dragForce.Subtract(velocity)
            dragForce.Multiply(-linearDrag*area)
            body.ApplyForce(dragForce,areac)
            '//Angular drag
            '//TODO: Something that makes more physical sense?
            body.ApplyTorque(-body.GetInertia()/body.GetMass()*area*body.GetAngularVelocity()*angularDrag)
            i=i.nextBody
        End
    End
    
    Method Draw : void (debugDraw:b2DebugDraw)
        
        Local r :Float = 1000
        '//Would like to draw a semi-transparent box
        '//But debug draw doesnt support that
        Local p1 :b2Vec2 = New b2Vec2()
        Local p2 :b2Vec2 = New b2Vec2()
        p1.x = normal.x * offset + normal.y * r
        p1.y = normal.y * offset - normal.x * r
        p2.x = normal.x * offset - normal.y * r
        p2.y = normal.y * offset + normal.x * r
        Local color :b2Color = New b2Color(0,0,1)
        debugDraw.DrawSegment(p1,p2,color)
    End
End


