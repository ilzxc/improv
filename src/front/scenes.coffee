{ Envelope } = require './envelope'

Panel = (isLeft, envelope) ->
    @envelope = envelope
    @position = if isLeft then [0, 0] else [width / 2, 0]
    @width = width / 2
    @height = height
    @background = 0
    @scene = null
    @envelopeUpdateStrategy = null

    @setScene = (scene) ->
        @scene = scene

    @setBackground = (bkg) ->
        @background = bkg

    @setEnvelope = (envelope) ->
        @envelope = envelope

    @resize = () ->
        if @position[0] != 0
            @position[0] = width / 2
        @width = width / 2
        @height = height

    @setEUS = (strategy) ->
        @envelopeUpdateStrategy = strategy

    @drawSelf = () ->
        push()
        noStroke()
        translate @position[0], @position[1]
        fill @background[0], @background[1], @background[2]
        rect 0, 0, @width, @height
        pop()

    @draw = () ->
        push()
        translate @position[0], @position[1]
        translate @width / 2, @height / 2
        if @envelopeUpdateStrategy != null
            trigger = @envelopeUpdateStrategy.update @envelope
        if @envelope != null
            state = @envelope.update (new Date()).getTime() / 1000 
        if @scene != null # and @envelope.isRest == false
            @scene.draw state, trigger
        pop()
        return
    this

###################################################################################################
### Scene 1 : Dot --> Dots --> Animated Behaviors
###################################################################################################

ColorLerp = (colorStart, colorDelta, state) ->
    result = (colorDelta[i] * state + val for val, i in colorStart)
    result[3] = 255 - state * 255
    return result

Dot = (minRadius, maxDelta) ->
    @minRadius = minRadius
    @maxDelta = maxDelta
    @radius = @minRadius + Math.random() * @maxDelta
    @fillColor = [0, 0, 0] # todo: make pretty
    @deltaColor = [255, 255, 255]
    @draw = (state, trigger) ->
        if trigger == true
            @radius = @minRadius + Math.random() * @maxDelta
            if Math.random() < 0.09
                @fillColor = [255, 200, 200] # todo: make pretty
                @deltaColor = [0, 55, 55]
            else
                @fillColor = [0, 0, 0] # todo: make pretty
                @deltaColor = [255, 255, 255]
        push()
        noStroke()
        # fill ColorLerp @fillColor, @deltaColor, state
        col = ColorLerp @fillColor, @deltaColor, state
        fill col
        ellipse 0, 0, @radius, @radius
        pop()
        return
    this

TimedDot = (minRadius, maxDelta, t) ->
    angle = noise(t) * Math.PI * 2
    radius = Math.random() * maxDelta + minRadius
    @position = [Math.cos(angle) * radius, Math.sin(angle) * radius]
    @radius = minRadius + Math.random() * maxDelta
    @fillColor = [0, 0, 0]
    @deltaColor = [255, 255, 255]
    @startTime = (new Date()).getTime() / 1000
    @duration = Math.random() * 2.5 + 0.3 # DURATION
    @time = 0
    @draw = () ->
        @time = (((new Date()).getTime() / 1000) - @startTime) / @duration
        if @time > 1 then @time = 1
        push()
        translate @position[0], @position[1]
        noStroke()
        col = ColorLerp @fillColor, @deltaColor, @time
        fill col
        ellipse 0, 0, @radius, @radius
        pop()
    this

MovingDot = (minRadius, maxDelta, upDown, t) ->
    @t = t
    @position = [Math.random() * 500 - 250, 0]
    @radius = minRadius + Math.random() * maxDelta
    @fillColor = [0, 0, 0]
    @deltaColor = [255, 255, 255]
    @startTime = (new Date()).getTime() / 1000
    @duration = Math.random() * 5.5 + 0.9 # DURATION
    @time = 0
    @offset = 300 * upDown
    @draw = () ->
        @time = (((new Date()).getTime() / 1000) - @startTime) / @duration
        if @time > 1 then @time = 1
        @position[1] = @time * @offset
        @t += 0.2
        push()
        translate @position[0], @position[1]
        noStroke()
        col = ColorLerp @fillColor, @deltaColor, @time
        fill col
        ellipse 0, 0, @radius, @radius
        pop()
    this

Dots = (minRadius, maxDelta) ->
    @t = 0
    @minRadius = minRadius
    @maxDelta = maxDelta
    @dots = []
    @draw = (state, trigger) ->
        if trigger == true
            @dots.push new TimedDot @minRadius, @maxDelta, @t
            @t += .1
            if Math.random() < 0.02
                @dots[@dots.length - 1].fillColor = [255, 100, 100]
                @dots[@dots.length - 1].colorDelta = [0, 155, 155]
        for dot in @dots 
            dot.draw()
        @dots = @dots.filter (dot) -> return dot.time < 1
        return
    this

Behaviors = (minRadius, maxDelta) ->
    @mode = 0 # 0: down, 1: down w/ red up, 2: up, 3: up w/ red down, 4: up & down
    @t = 0
    @minRadius = minRadius
    @maxDelta = maxDelta
    @dots = []
    @draw = (state, trigger) ->
        if trigger == true
            @t += 0.2
            switch @mode
                when 0
                    @dots.push new MovingDot @minRadius, @maxDelta, 1, @t
                when 1
                    @dots.push new MovingDot @minRadius, @maxDelta, 1, @t
                    if Math.random() < 0.02
                        @dots[@dots.length - 1].fillColor = [255, 100, 100]
                        @dots[@dots.length - 1].colorDelta = [0, 155, 155]
                        @dots[@dots.length - 1].offset *= -1
                when 2
                     @dots.push new MovingDot @minRadius, @maxDelta, -1, @t
                when 3
                    @dots.push new MovingDot @minRadius, @maxDelta, -1, @t
                    if Math.random() < 0.02
                        @dots[@dots.length - 1].fillColor = [255, 100, 100]
                        @dots[@dots.length - 1].colorDelta = [0, 155, 155]
                        @dots[@dots.length - 1].offset *= -1
                when 4
                    @dots.push new MovingDot @minRadius, @maxDelta, (if Math.random() < .5 then 1 else -1), @t
        for dot in @dots 
            dot.draw()
        @dots = @dots.filter (dot) -> return dot.time < 1
        return
    this

### the basic dot scene ###
Scene1 = () ->
    @dot = new Dot 10, 300
    @draw = (state, trigger) ->
        @dot.draw state, trigger
        return
    this

### the timed dot scene (with movement) ###
Scene1a = () ->
    @dot = new Dots 10, 100 # (minRadius, maxDelta, upDown, t) ->
    @draw = (state, trigger) ->
        @dot.draw state, trigger
        return
    this

Scene1b = (mode=0) ->
    @dot = new Behaviors 10, 100
    @dot.mode = mode
    @draw = (state, trigger) ->
        @dot.draw state, trigger
    this

Scenes1 = { Scene1, Scene1a, Scene1b }

### the behaviors scene (to be expanded with up, down, up & down + colorful things)



###################################################################################################
### Scene 2 : bars --> many bars --> waves
###################################################################################################

deltaTime = () ->
    @prevTime = millis()
    @get = () ->
        result = millis() - @prevTime
        @prevTime = millis()
        result / 1000
    this

Scene2 = () ->
    ### Two squares, which take turns in growing / shrinking 
        according to the envelope ###
    @radius = [100, 100]
    @angleIncrement = 1 + Math.random() # degrees per second
    @reverseAngle = 2 + Math.random()
    @dt = new deltaTime()
    @currentSquare = 0 # by default, the first square is selected
    @angle = 0
    @draw = (state, trigger) ->
        if trigger == true 
            @radius[@currentSquare] = 100
            @currentSquare = Math.floor(Math.random() * 2)
        @radius[@currentSquare] = 100 + (75 * state)
        @angle += @angleIncrement * @dt.get()
        rotate @angle
        push()
        stroke 200
        strokeWeight 10
        fill 255
        translate 100, 0
        rotate -@angle * @reverseAngle
        rect -@radius[0] / 2, -@radius[0] / 2, @radius[0], @radius[0]
        pop()
        push()
        stroke 0
        strokeWeight 10
        fill 55
        translate -100, 0
        rotate -@angle * @reverseAngle
        rect -@radius[1] / 2, -@radius[1] / 2, @radius[1], @radius[1]
        pop()
    this

###################################################################################################
### Scene 3 : Swarm --> Voices in the Dark --> Multimotions
###################################################################################################

len = (x, y) ->
    return Math.sqrt x * x + y * y

lenV = (v) ->
    return Math.sqrt v[0] * v[0] + v[1] * v[1]

limitV = (v, val) ->
    mag = lenV v
    for i in [0, 1]
        if mag > val 
            v[i] /= mag
            v[i] *= val

Particle = (origin, velLimit, color=undefined) ->
    @origin = origin
    @velLimit = velLimit
    if color is undefined
        @color = Math.random() * 200 + 55
        @fill = [255, 255, 255]
    else
        @color = color
        @fill = color
    angle = Math.random() * Math.PI * 2
    @position = [100 * Math.cos(angle), 100 * Math.sin(angle)]
    vel = [Math.random(), Math.random()]
    @velocity = [(if vel[0] > .5 then vel[0] * 4 else vel[0] * -4), (if vel[1] > .5 then vel[1] * 4 else vel[1] * -4)]
    @mass = 0.00005 + Math.random() * .0005
    @gravity = 0 # will be controlled by the envelope
    @draw = (state, explode) ->
        if ! explode
            @gravity = @mass * state
            magnitude = -lenV [@position[0] - @origin[0], @position[1] - @origin[1]]
            @acceleration = [magnitude * @gravity * (@position[0] - @origin[0]) ,  magnitude * @gravity * (@position[1] - @origin[1])]
            @velocity = [@velocity[0] + @acceleration[0], @velocity[1] + @acceleration[1]]
            limitV @velocity, @velLimit
        @position = [@position[0] + @velocity[0], @position[1] + @velocity[1]]
        push()
        stroke @color
        strokeWeight 5
        fill @fill
        translate @position[0], @position[1]
        radius = @mass * 25000
        ellipse 0, 0, radius, radius
        pop()
    this


Scene3 = (velLimit=20) ->
    ### Particles that attract according to the envelope ###
    @origin = [0, 0]
    @numParticles = 100
    @particles = []
    @mode = 0
    for i in [0...@numParticles]
        @particles.push new Particle @origin, velLimit
    @explode = false
    @drawSimple = (particles, state, trigger, explode) ->
        for p in particles
            p.draw state, explode
        return
    @drawToRed = (particles, state, trigger, explode) ->
        if trigger
            idx = Math.floor Math.random() * (particles.length - 1)
            strong = Math.random() * 128 + 128
            weak = Math.random() * 128
            color = [strong, weak, weak]
            particles[idx].color = color
        for p in particles
            p.draw state, explode
        return
    @drawToGrey = (particles, state, trigger, explode) ->
        if trigger
            idx = Math.floor Math.random() * (particles.length - 1)
            color = Math.random() * 100 + 155
            particles[idx].color = [color, color, color]
        for p in particles
            p.draw state, explode
        return
    @drawSimpleJitter = (particles, state, trigger, explode) ->
        if trigger
            for p in particles
                angle = Math.random() * Math.PI * 2
                p.velocity = [3 * Math.cos(angle), 3 * Math.sin(angle)]
        for p in particles
            p.draw state, explode
        return
    @drawToFadeOut = (particles, state, trigger, explode) ->
        if trigger
            if particles.length > 0
                --particles.length 
        for p in particles
            p.draw state, explode
        return
    @drawFuncs = [@drawSimple, @drawToRed, @drawToGrey, @drawSimpleJitter, @drawToFadeOut]
    @draw = (state, trigger) ->
        @drawFuncs[@mode] @particles, state, trigger, @explode
        return
    @updateOrigin = (radius) ->
        angle = Math.random() * Math.PI * 2
        @origin = [radius * Math.cos(angle), radius * Math.sin(angle)]
        return
    @setVelLimit = (velLimit) ->
        for p in @particles
            p.velLimit = velLimit
        return
    this

Scene3a = (velLimit=20) ->
    @origin = [0, 0]
    @numParticles = 200
    @particles = []
    for i in [0...@numParticles]
        @particles.push new Particle @origin, velLimit, [33, 33, 33]
    strong = Math.random() * 128 + 128
    weak = Math.random() * 128
    @particles[@particles.length - 1].color = @particles[@particles.length - 1].fill = [strong, weak, weak]
    @explode = false
    @draw = (state, trigger) ->
        if trigger
            # set the previous high-lit particle to be regular
            @particles[@particles.length - 1].color = @particles[@particles.length - 1].fill = [33, 33, 33]
            @particles[@particles.length - 1].mass = 0.00005 + Math.random() * .0005
            # swap a random particle
            idx = Math.floor Math.random() * (@particles.length - 2)
            temp = @particles[@particles.length - 1]
            @particles[@particles.length - 1] = @particles[idx]
            @particles[idx] = temp
            # set the new "highlight" particle:
            strong = Math.random() * 128 + 128
            weak = Math.random() * 128
            @particles[@particles.length - 1].color = @particles[@particles.length - 1].fill = [strong, weak, weak]
            # give everyone new velocities:
            for p in @particles
                angle = Math.random() * Math.PI * 2
                p.velocity = [3 * Math.cos(angle), 3 * Math.sin(angle)]
                r = if Math.random() < .5 then 0 else 1
                p.velocity[r] *= 2
        for p in @particles
            p.draw state, @explode 
        return
    @updateOrigin = (radius) ->
        angle = Math.random() * Math.PI * 2
        @origin = [radius * Math.cos(angle), radius * Math.sin(angle)]
        for p in @particles
            p.origin = @origin
        return
    this

Scenes3 = {Scene3, Scene3a}

Scene4 = () ->
    this

Scene5 = () ->
    this

module.exports = { Panel, Scenes1, Scene2, Scenes3 }
