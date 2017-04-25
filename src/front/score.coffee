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
            console.log @EUS.minTime
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
        @envelope.start 1, 1, false, 0 # fade-in envelope...

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
                # envelope.start 5, 1, false, 0
                envelope.start 30, 1, false, 0
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
                    envelope.start 20, 1, false, 0
                    # envelope.start 5, 1, false, 0
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
                    envelope.start 16, 1, false, 0
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
                    envelope.start 20, 1, false, 0
                    return true
            false
        this

    @state5 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelLeft.envelope.busy
                    panelLeft.setScene new Scenes1.Scene1b()
                    envelope.start 13, 1, false, 0
                    return true
            false
        this

    @state6 = () ->
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if ! panelRight.envelope.busy
                    panelRight.setScene new Scenes1.Scene1b 1
                    envelope.start 20, 1, false, 0
                    return true
            false
        this

    @wrapup = () ->
        @leftUpdated = false
        @rightUpdated = false
        @update = (envelope, panelLeft, panelRight) ->
            if ! envelope.busy
                if (! @leftUpdated) and (! panelLeft.envelope.busy)
                    panelLeft.setScene null
                    panelLeft.setEUS null
                    panelLeft.setEnvelope null
                    @leftUpdated = true
                if (! @rightUpdated) and (! panelRight.envelope.busy)
                    panelRight.setScene null
                    panelRight.setEUS null
                    panelRight.setEnvelope null
                    @rightUpdated = true
                if @leftUpdated and @rightUpdated
                    envelope.start 20, 1, false, 0
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
               new @state5(), new @state6(), new @wrapup(), new @fadeOut()]
    @state = -1

    @update = () ->
        state = @envelope.update (new Date()).getTime() / 1000 
        if @states[@state + 1].update @envelope, @panelLeft, @panelRight, state
            console.log "advancing state to", @state + 1
            if ++@state == @states.length - 1  
                console.log "setting noLoop"
                noLoop()
        return
    this

module.exports = { Score }