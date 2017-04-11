ipc = require('electron').ipcRenderer
{ Envelope } = require './js/front/envelope'
{ Panel, Scene1, Scene2, Scene3 } = require './js/front/scenes'

time = 0
currentTime = 0
envelope = new Envelope()
panelLeft = null
panelRight = null

setup = () ->
    createCanvas windowWidth, windowHeight
    background 128, 128, 128
    panelLeft = new Panel true, new Envelope()
    panelRight = new Panel false, new Envelope()
    panelRight.setBackground [240, 240, 240]
    panelLeft.setScene new Scene3()
    panelLeft.setEUS (envelope) ->
        if ! envelope.busy
            envelope.start Math.random() * 2 + .5, 1, if Math.random() > .5 then true else false
            return true
        false
    panelRight.setScene new Scene3()
    panelRight.setEUS (envelope) ->
        if ! envelope.busy
            # envelope.start 2.1, 2, false
            envelope.start Math.random() * 2 + .3, 1, if Math.random() > .5 then true else false
            return true
        false
    return

draw = () ->
    background 255
    fill 0, 0, 0
    panelLeft.draw()
    panelRight.draw()
    return

window.onresize = () ->
    resizeCanvas windowWidth, windowHeight
    panelLeft.resize()
    panelRight.resize()
    return

ipc.on 'force-resize', () ->
    window.onresize()
    return