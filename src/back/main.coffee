{ app, BrowserWindow } = require 'electron'
mainWindow = null;

app.on 'ready', () ->
    mainWindow = new BrowserWindow { width: 1400, height: 900 }
    mainWindow.loadURL 'file:///' + __dirname + '/index.html'

    mainWindow.on 'enter-full-screen', (e, cmd) ->
        mainWindow.webContents.send 'force-resize'
        return

    mainWindow.on 'leave-full-screen', (e, cmd) ->
        mainWindow.webContents.send 'force-resize'
        return
    
    return