{ Envelope } = require './envelope'
{ Scenes1, Scene2, Scenes3 } = require './scenes'

### Envelope Update Strategies ###
SimpleEUS = (minTime, maxTime, minExponent, maxExponent, flip, restLiklihood) ->
    @minTime = minTime
    @randomizeTime = maxTime - minTime
    @minExponent = minExponent
    @randomizeExponent = maxExponent - minExponent
    @flip = flip
    @restLiklihood = restLiklihood
    @update = (envelope) ->
        if ! envelope.busy
            envelope.start @minTime + Math.random() * @randomizeTime, @minExponent + Math.random() * @randomizeExponent, @flip, @restLiklihood
            return true
        false
    this

TempoEUS = (minTimeStart, minTimeEnd, randomTime, minExponent, maxExponent, flip, restLiklihood, numSteps) ->
    @minTimeDelta = (minTimeEnd - minTimeStart) / numSteps
    @EUS = new SimpleEUS minTimeStart, randomTime + minTimeStart, minExponent, maxExponent, flip, restLiklihood
    @update = (envelope) ->
        if ! envelope.busy
            @EUS.minTime += @minTimeDelta
            return @EUS.update envelope
        false
    this
### END Envelope Update Strategies ###

### Score: a set of states with durations ###
Score = (panelLeft, panelRight) ->
    @panelLeft = panelLeft
    @panelRight = panelRight
    @envelope = new Envelope() # sections timer

    ### STATES: objects enforcing a particular logic to updates ###
    @setup = () ->
        @envelope.start 10, 1, false, 0 # fade-in envelope...
        # @envelope.start 1, 1, false, 0 # fade-in envelope...

    @state0 = () ->
        @colorLeft = 255
        @colorRight = 240
        @update = (envelope, panelLeft, panelRight, state) ->
            left = state * @colorLeft
            right = state * @colorRight
            panelLeft.setBackground [left, left, left]
            panelRight.setBackground [right, right, right]
            if ! envelope.busy then return true
            false
        this


    @state1 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelLeft.setEnvelope new Envelope()
                panelRight.setEnvelope panelLeft.envelope
                panelLeft.setScene new Scenes1.Scene1()
                panelLeft.setEUS new SimpleEUS .7, 2.5, -3, 1, false, .20
                panelRight.setScene panelLeft.scene # use the left scene in both, no need to set EUS for right panel
                envelope.start 40, 1, false, 0
                # envelope.start 1, 1, false, 0
                return true
            false
        this

    @state2 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelLeft.envelope.busy
                    panelRight.setScene new Scenes1.Scene1()
                    panelRight.setEnvelope new Envelope()
                    panelRight.setEUS new SimpleEUS .5, 2.5, -3, 1, false, .20
                    envelope.start 50, 1, false, 0
                    # envelope.start 1, 1, false, 0
                    return true
            false
        this

    @state3 = () ->
        @leftUpdated = false
        @rightUpdated = false
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if (! @leftUpdated) and (! panelLeft.envelope.busy)
                    panelLeft.setScene new Scenes1.Scene1a()
                    panelLeft.setEUS new SimpleEUS .3, 1, 1, 3, true, 0
                    @leftUpdated = true
                if (! @rightUpdated) and (! panelRight.envelope.busy)
                    panelRight.setScene new Scenes1.Scene1a()
                    panelRight.setEUS new TempoEUS .1, 3, 0, -1, 3, true, -1, 30
                    @rightUpdated = true
                if @leftUpdated and @rightUpdated
                    envelope.start 26, 1, false, 0
                    # envelope.start 1, 1, false, 0
                    return true
            false
        this

    @state4 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelLeft.envelope.busy
                    panelLeft.setScene new Scenes1.Scene1()
                    panelLeft.setEUS new SimpleEUS .3, 1, -3, 1, true, -1
                    panelRight.setEUS new SimpleEUS .2, .3, -3, 1, false, -1
                    envelope.start 43, 1, false, 0
                    # envelope.start 1, 1, false, 0
                    return true
            false
        this

    @state5 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelLeft.envelope.busy
                    panelLeft.setScene new Scenes1.Scene1b()
                    envelope.start 13, 1, false, 0
                    # envelope.start 1, 1, false, 0
                    return true
            false
        this

    @state6 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelRight.envelope.busy
                    panelRight.setScene new Scenes1.Scene1b 1
                    envelope.start 23, 1, false, 0
                    # envelope.start 1, 1, false, 0
                    return true
            false
        this

    @state7 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelLeft.setEUS null
                panelRight.setEUS null
                # envelope.start 15, 1, false, 0
                return true
            false
        this

    ### ASSUME THREES START FROM TWO SCENE 1Cs ###
    @ThreesInit = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if panelLeft.scene.dot.dots.length == panelRight.scene.dot.dots.length == 0
                panelLeft.scene = new Scenes3.Scene3 5
                panelLeft.scene.mode = 0
                panelLeft.envelope = new Envelope()
                panelLeft.setEUS new SimpleEUS .2, .3, -3, 3, true, 0.1

                panelRight.scene = new Scenes3.Scene3 5
                panelRight.scene.mode = 3
                panelRight.envelope = new Envelope()
                panelRight.setEUS new SimpleEUS .8, .9, -1, 1, true, 0.2
                envelope.start 30, 1, false, 0
                # envelope.start 1, 1, false, 0
                return true
            false
        this

    @Threes0 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelLeft.scene.mode = 2
                panelRight.scene.mode = 1
                panelRight.setEUS new SimpleEUS .8, .9, -1, 1, true, 0.2
                envelope.start 13, 1, false, 0
                # envelope.start 1, 1, false, 0
                return true
            false
        this

    @Threes1 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelLeft.scene.mode = 4
                panelRight.scene.mode = 1
                # panelLeft.setEUS new SimpleEUS .01, .1, -3, 3, true, 0.1 ## THIS IS NEW
                panelRight.setEUS new SimpleEUS .8, .9, -1, 1, true, 0.2
                # envelope.start 100, 1, false, 0
                # envelope.start 5, 1, false, 0
                return true
            false
        this

    @Threes2 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if panelLeft.scene.particles.length == 0
                panelLeft.scene = new Scenes3.Scene3a 2.5
                # panelLeft.setEUS new SimpleEUS .1, .05, -1, 2, false, 0.3, .3
                # panelLeft.setEUS new SimpleEUS .8, 1.3, 1, 3, true, 0.3, .3
                panelLeft.setEUS new TempoEUS .1, 1, .2, 1, 3, true, 0, 20
                panelRight.setEUS null
                panelRight.setEnvelope panelLeft.envelope
                panelRight.scene.mode = 3
                panelRight.scene.setVelLimit 2
                envelope.start 30, 1, false, 0
                # envelope.start 5, 1, false, 0
                return true
            false
        this

    @CrazySetup = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelRight.scene = new Scenes1.Scene1()
                # minTime, maxTime, minExponent, maxExponent, flip, restLiklihood
                panelRight.setEUS new SimpleEUS .05, .1, 1, 2, false, 0.01
                panelLeft.scene = null
                panelLeft.setEUS new SimpleEUS .06, .18, 1, 2, false, 0.01
                envelope.start 20, 1, false, 0
                return true
            false
        this

    @Crazy2 = () ->
        # very fast right, sporadic left
        @rightScenes = [new Scenes1.Scene1(), new Scenes1.Scene1a(), new Scenes1.Scene1b(), new Scenes3.Scene3(), new Scenes3.Scene3a()]
        @rightSceneTimer = new Envelope()
        @update = (envelope, panelLeft, panelRight) ->
            @rightSceneTimer.update (new Date()).getTime() / 1000
            if ! envelope.busy
                panelLeft.setScene new Scenes3.Scene3 2
                panelRight.setScene new Scenes3.Scene3 5
                panelLeft.setEUS new SimpleEUS .1, .3, 1, 2, false, 0.2
                panelRight.setEUS new SimpleEUS .3, .6, 1, 2, true, 0.4
                envelope.start 13, 1, false, 0 # will need this longer
                return true
            else if ! @rightSceneTimer.busy and envelope.currentValue > 0.1
                # roll the die:
                idx = Math.floor (@rightScenes.length * 2) * Math.random()
                if idx < @rightScenes.length
                    panelLeft.scene = @rightScenes[idx]
                else
                    panelLeft.scene = null
                panelLeft.setEUS new SimpleEUS 0.3 * Math.random() + 0.06, .3 * Math.random() + 0.1, -2, 3, false, Math.random() * 0.3
                @rightSceneTimer.start Math.random() + .3, 1, false, 0
            false
        this


    @ThreesRedux = () ->
        # randomized mode alteration (without fadeout)
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                envelope.start 40, 1, false, 0
                return true
            if Math.random() < 0.01
                if Math.random() < 0.5
                    mode = Math.floor 5 * Math.random()
                    panelLeft.scene.mode = mode
                if Math.random() < 0.5
                    mode = Math.floor 5 * Math.random()
                    panelRight.scene.mode = mode
            false
        this

    @ThreesExplode = () ->
        # explode the particles
        @explodeStarted = false
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                panelLeft.scene = new Scenes1.Scene1b()
                panelRight.scene = new Scenes1.Scene1b()
                panelLeft.setEUS new SimpleEUS .05, .1, 1, 2, false, 0.01
                panelRight.setEUS new SimpleEUS .05, .1, 1, 2, false, 0.01
                panelRight.setEnvelope panelLeft.envelope
                envelope.start 20, 1, false, 0
                return true
            else if ! @explodeStarted
                if envelope.currentValue > 0.1
                    panelLeft.setEUS null
                    panelRight.setEUS null
                    panelLeft.scene.explode = true
                    panelRight.scene.explode = true
                    @explodeStarted = true
            false
        this

    @EverythingEverything = () ->
        # like, crazy 4, but with different shapes
        @leftScenes = [new Scenes1.Scene1(), new Scenes1.Scene1a(), new Scenes3.Scene3(), new Scenes3.Scene3a()]
        @rightScenes = [new Scenes1.Scene1(), new Scenes1.Scene1a(), new Scenes3.Scene3(), new Scenes3.Scene3a()]
        # @sceneTimer = new Envelope()
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                return true
            else
                idxL = Math.floor (@rightScenes.length) * Math.random()
                if idxL < @leftScenes.length
                    panelLeft.scene = @leftScenes[idxL]
                else
                    panelLeft.scene = null
                idxR = Math.floor (@rightScenes.length) * Math.random()
                if idxR < @rightScenes.length
                    panelRight.scene = @rightScenes[idxR]
                else
                    panelRight.scene = null
                # panelLeft.setEUS new SimpleEUS 0.3 * Math.random() + 0.06, .3 * Math.random() + 0.1, -2, 3, false, Math.random() * 0.3
            false
        this

    @wrapup = () ->
        @leftUpdated = false
        @rightUpdated = false
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                # if (! @leftUpdated) and (! panelLeft.envelope.busy)
                panelLeft.setScene null
                panelLeft.setEUS null
                panelLeft.setEnvelope null
                @leftUpdated = true
                # if (! @rightUpdated) and (! panelRight.envelope.busy)
                panelRight.setScene null
                panelRight.setEUS null
                panelRight.setEnvelope null
                @rightUpdated = true
                # if @leftUpdated and @rightUpdated
                envelope.start 10, 1, false, 0
                return true
            false
        this


    @fadeOut = () ->
        @colorLeft = -255
        @colorRight = -240
        @update = (envelope, panelLeft, panelRight, state) ->
            left = 255 + state * @colorLeft
            right = 240 + state * @colorRight
            panelLeft.setBackground [left, left, left]
            panelRight.setBackground [right, right, right]
            if ! envelope.busy then return true
            false
        this


    # @setup()

    @states = [new @state0(), new @state1(), new @state2(), new @state3(), new @state4(), 
               new @state5(), new @state6(), new @state7(), 
               new @ThreesInit(), new @Threes0(), new @Threes1(), new @Threes2(),
               new @CrazySetup(), new @Crazy2(), # new @Crazy3(), new @Crazy4(),
               new @ThreesRedux(), new @ThreesExplode(), new @EverythingEverything(),
               new @wrapup(), new @fadeOut(), null]
    @state = -1

    @update = () ->
        state = @envelope.update (new Date()).getTime() / 1000 
        if @states[@state + 1].update @envelope, @panelLeft, @panelRight, state
            console.log "advancing state to", @state + 2
            if ++@state == @states.length - 1  
                console.log "setting noLoop"
                noLoop()
        return
    this

module.exports = { Score }