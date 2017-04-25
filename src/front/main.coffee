ipc = require('electron').ipcRenderer
{ Panel } = require './js/front/scenes'
{ Score } = require './js/front/score'

### TESTING ###
{ Scenes1, Scene2, Scenes3 } = require './js/front/scenes'
{ Envelope } = require './js/front/envelope'

### Envelope Update Strategies ###
SimpleEUS = (minTime, maxTime, minExponent, maxExponent, flip, restLiklihood, restDuration) ->
    @minTime = minTime
    @randomizeTime = maxTime - minTime
    @minExponent = minExponent
    @randomizeExponent = maxExponent - minExponent
    @flip = flip
    @restLiklihood = restLiklihood
    @restDuration = restDuration
    @update = (envelope) ->
        if ! envelope.busy
            envelope.start @minTime + Math.random() * @randomizeTime, @minExponent + Math.random() * @randomizeExponent, @flip, @restLiklihood, @restDuration
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

### END TESTING ###

panelLeft = null
panelRight = null
score = null

setup = () ->
    createCanvas windowWidth, windowHeight
    background 0
    panelLeft = new Panel true, null
    panelRight = new Panel false, null
    # score = new Score panelLeft, panelRight

    ### TESTING ###
    panelLeft.scene = new Scenes3.Scene3 5
    panelLeft.scene.mode = 4
    panelLeft.envelope = new Envelope()
    panelLeft.setEUS new SimpleEUS .2, .3, -3, 3, true, 0.1

    panelRight.scene = new Scenes3.Scene3 5
    panelRight.scene.mode = 1
    panelRight.envelope = new Envelope()
    panelRight.setEUS new SimpleEUS .8, .9, -1, 1, true, 0.2

    ### END TESTING ###
    return

# drawImpl = () ->
#     background 0
#     score.update()
#     panelLeft.drawSelf()
#     panelRight.drawSelf()
#     panelLeft.draw()
#     panelRight.draw()
#     return

# draw = () ->
#     background 0
#     return

### TESTING ###
draw = () ->
    background 0

    panelLeft.drawSelf()
    panelRight.drawSelf()
    panelLeft.draw()
    panelRight.draw()

    if panelLeft.scene.particles.length == 0
        panelLeft.scene = new Scenes3.Scene3a 2.5
        # panelLeft.setEUS new SimpleEUS .1, .05, -1, 2, false, 0.3, .3
        # panelLeft.setEUS new SimpleEUS .8, 1.3, 1, 3, true, 0.3, .3
        panelLeft.setEUS new TempoEUS .1, 1, .2, 1, 3, true, 0, 20
        panelRight.setEUS null
        panelRight.setEnvelope panelLeft.envelope
        panelRight.scene.mode = 3
        panelRight.scene.setVelLimit 2
    return
### END TESTING ###

window.onresize = () ->
    resizeCanvas windowWidth, windowHeight
    panelLeft.resize()
    panelRight.resize()
    return

ipc.on 'force-resize', () ->
    window.onresize()
    return

# mousePressed = () ->
#     score.setup() 
#     draw = drawImpl
#     mousePressed = () -> return