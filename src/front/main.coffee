ipc = require('electron').ipcRenderer
{ Envelope } = require './js/front/envelope'

time = 0
currentTime = 0
test = new Envelope()

setup = () ->
    createCanvas windowWidth, windowHeight
    background 128, 128, 128
    return

draw = () ->
    if ! test.busy
        test.start 3, -2, true
    val = test.update (new Date()).getTime() / 1000
    background 255
    ellipse width / 2, height - height * val, 10, 10
    return

window.onresize = () ->
    resizeCanvas windowWidth, windowHeight
    return

ipc.on 'force-resize', () ->
    window.onresize()
    return