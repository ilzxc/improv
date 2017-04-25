{ Envelope } = require './envelope'
{ Scene1, Scene2, Scene3 } = require './scenes'

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

Score = (panelLeft, panelRight) ->
    # keep references to panels that we will need to update
    @panelLeft = panelLeft
    @panelRight = panelRight
    @envelope = new Envelope()

    # state updates are encapsulated in functions (note that state0 is the only one without arguments, todo: fix for justice!)
    @state0 = () ->
        @panelLeft.setEnvelope new Envelope()
        @panelRight.setEnvelope @panelLeft.envelope
        @panelRight.setBackground [240, 240, 240]
        @panelLeft.setScene new Scene1()
        @panelLeft.setEUS new SimpleEUS .5, 2, -3, 3, false, .20
        @panelRight.setScene panelLeft.scene
        @envelope.start 30, 1, false, 0
        return

    @state1 = (envelope, panelLeft, panelRight) ->
        if ! panelLeft.envelope.busy
            panelRight.setScene new Scene1()
            console.log "left", panelLeft.scene
            console.log "right", panelRight.scene
            panelRight.setEnvelope new Envelope()
            panelRight.setEUS new SimpleEUS .5, 2.5, -3, 1, false, .20
            envelope.start 20, 1, false, 0
            return 1
        return 0

    @state2 = (envelope, panelLeft, panelRight) ->
        if ! panelLeft.envelope.busy
            panelLeft.setScene new Scene3()
            panelLeft.setEUS new SimpleEUS .3, 1, 1, 3, true, 0
            envelope.start 5, 1, false, 0
            return 1
        return 0

    @state3 = (envelope, panelLeft, panelRight) ->
        if ! panelLeft.envelope.busy
            panelLeft.setScene new Scene1()
            panelLeft.setEUS new SimpleEUS .7, 1, -3, 1, true, .20
            envelope.start 10, 1, false, 0
            return 1
        return 0

    @state4 = (envelope, panelLeft, panelRight) ->
        return

    @state5 = (envelope, panelLeft, panelRight) ->
        return

    @state6 = (envelope, panelLeft, panelRight) ->
        return

    @state7 = (envelope, panelLeft, panelRight) ->
        return

    @state8 = (envelope, panelLeft, panelRight) ->
        return

    @state9 = (envelope, panelLeft, panelRight) ->
        return

    @state0()

    @states = [@state0, @state1, @state2, @state3, @state4, @state5, @state6, @state7, @state8, @state9]
    @state = 0

    @update = () ->
        @envelope.update (new Date()).getTime() / 1000 
        if ! @envelope.busy
            @state += @states[@state + 1] @envelope, @panelLeft, @panelRight
            console.log @state
        return
    this

module.exports = { Score }