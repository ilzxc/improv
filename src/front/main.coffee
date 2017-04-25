ipc = require('electron').ipcRenderer
{ Panel } = require './js/front/scenes'
{ Score } = require './js/front/score'

panelLeft = null
panelRight = null
score = null

setup = () ->
    createCanvas windowWidth, windowHeight
    background 128, 128, 128
    panelLeft = new Panel true, null
    panelRight = new Panel false, null
    score = new Score panelLeft, panelRight
    return

draw = () ->
    background 255
    score.update()
    panelLeft.drawSelf()
    panelRight.drawSelf()
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
