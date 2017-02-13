{ app, BrowserWindow } = require 'electron'
mainWindow = null;

app.on 'ready', () ->
    mainWindow = new BrowserWindow { width: 700, height: 700 }
    mainWindow.loadURL 'file:///' + __dirname + '/index.html'

    mainWindow.on 'enter-full-screen', (e, cmd) ->
        mainWindow.webContents.send 'force-resize'
        return

    mainWindow.on 'leave-full-screen', (e, cmd) ->
        mainWindow.webContents.send 'force-resize'
        return
    
    return