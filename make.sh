#!/bin/sh
coffee -c -b -o js/front src/front/*
coffee -c -b -o js/back src/back/*
cp js/back/main.js index.js
cp js/front/main.js app.js
