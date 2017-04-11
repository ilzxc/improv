Panel = (isLeft, envelope) ->
    @envelope = envelope
    @position = if isLeft then [0, 0] else [width / 2, 0]
    @width = width / 2
    @height = height
    @background = [255, 255, 255]
    @scene = null
    @envelopeUpdateStrategy = null

    @setScene = (scene) ->
        @scene = scene

    @setBackground = (bkg) ->
        @background = bkg

    @resize = () ->
        if @position[0] != 0
            @position[0] = width / 2
        @width = width / 2
        @height = height

    @setEUS = (strategy) ->
        @envelopeUpdateStrategy = strategy

    @draw = () ->
        push()
        noStroke()
        translate @position[0], @position[1]
        fill @background[0], @background[1], @background[2]
        rect 0, 0, @width, @height
        translate @width / 2, @height / 2
        if @envelopeUpdateStrategy != null
            trigger = @envelopeUpdateStrategy envelope
        state = @envelope.update (new Date()).getTime() / 1000 
        if @scene != null
            @scene.draw state, trigger
        pop()
        return
    this

Scene1 = () ->
    ### Single-dot scene that pulsates according to the envelope ###
    @minRadius = 10
    @maxRadius = (Math.min width, height) / 2 - @minRadius - 100
    @draw = (state) ->
        push()
        stroke 200, 200, 200
        strokeWeight 10
        fill 255, 255, 255
        radius = @minRadius + (state * @maxRadius)
        ellipse 0, 0, radius, radius
        pop()
        return
    this

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
    @angleIncrement = 2 # degrees per second
    @dt = new deltaTime()
    @currentSquare = 0 # by default, the first square is selected
    @angle = 0
    @draw = (state, trigger) ->
        if trigger == true 
            @radius[@currentSquare] = 100
            @currentSquare = (@currentSquare + 1) % 2
        @radius[@currentSquare] = 100 + (75 * state)
        @angle += @angleIncrement * @dt.get()
        rotate @angle
        push()
        stroke 200, 200, 200
        strokeWeight 10
        fill 255, 255, 255
        translate 100, 0
        rotate -@angle * 2
        rect -@radius[0] / 2, -@radius[0] / 2, @radius[0], @radius[0]
        pop()
        push()
        stroke 200, 200, 200
        strokeWeight 10
        fill 255, 255, 255
        translate -100, 0
        rotate -@angle * 2
        rect -@radius[1] / 2, -@radius[1] / 2, @radius[1], @radius[1]
        pop()
    this

len = (x, y) ->
    return Math.sqrt x * x + y * y

lenV = (v) ->
    return Math.sqrt v[0] * v[0] + v[1] * v[1]

limitV = (v, val) ->
    for i in [0, 1]
        if v[i] > val then v[i] = val

Particle = () ->
    @color = Math.random() * 200 + 55
    angle = Math.random() * Math.PI * 2
    @position = [100 * Math.cos(angle), 100 * Math.sin(angle)]
    vel = [Math.random(), Math.random()]
    @velocity = [(if vel[0] > .5 then vel[0] * 2 else vel[0] * -2), (if vel[1] > .5 then vel[1] * 2 else vel[1] * -2)]
    @mass = 0.00005 + Math.random() * .0005 # some value between 0..5
    @gravity = 0 # will be controlled by the envelope
    @draw = (state) ->
        @gravity = @mass * state
        magnitude = -lenV @position
        @acceleration = [magnitude * @gravity * @position[0],  magnitude * @gravity * @position[1]]
        @velocity = [@velocity[0] + @acceleration[0], @velocity[1] + @acceleration[1]]
        limitV @velocity, 2
        @position = [@position[0] + @velocity[0], @position[1] + @velocity[1]]
        push()
        stroke @color
        strokeWeight 5
        fill 255
        translate @position[0], @position[1]
        radius = @mass * 25000
        ellipse 0, 0, radius, radius
        pop()
    this


Scene3 = () ->
    ### Particles that attract according to the envelope ###
    @numParticles = 50
    @particles = []
    for i in [0...@numParticles]
        @particles.push new Particle()
    @draw = (state) ->
        for p in @particles
            p.draw state
    this

module.exports = { Panel, Scene1, Scene2, Scene3 }
