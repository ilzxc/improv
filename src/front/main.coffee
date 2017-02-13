{ Envelope } = require './build/front/envelope'

time = 0
currentTime = 0
test = new Envelope()

console.log test

setup = () ->
    createCanvas window.innerWidth, window.innerHeight
    background 128, 128, 128
    return

draw = () ->
    if ! test.busy
        console.log "starting a new test"
        test.start 5, 5, false
    val = test.update (new Date()).getTime() / 1000
    background 255
    ellipse width / 2, height - height * val, 10, 10
    return
