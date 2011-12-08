fs = require "fs"
{exec} = require "child_process"
closure = require "./build/closure"

task "zip", "Zip up nanoscroller.css and jquery.nanoscroller.min.js", ->
    console.log "Zipping files..."
    exec "cd bin && cd css && zip ../jquery.nanoscroller.zip nanoscroller.css", (errCSS, stdoutCSS, stderrCSS) ->
        throw errCSS if errCSS
        console.log stdoutCSS + stderrCSS if (stderrCSS? or stdoutCSS?)
        exec "cd bin && cd javascripts && zip ../jquery.nanoscroller.zip -g jquery.nanoscroller.min.js", (errJS, stdoutJS, stderrJS) ->
            throw errJS if errJS
            console.log stdoutJS + stderrJS if (stderrJS? or stdoutJS?)

task "build", "Build and zip everything", (options) ->
    exec "coffee -c --output bin/javascripts/ coffeescripts/", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr if (stderr? or stdout?)
        fs.readFile "bin/javascripts/jquery.nanoscroller.js", "utf-8", (errReading, data) ->
            throw errReading if errReading
            closure.compile data, (errCompiling, code) ->
                throw errCompiling if errCompiling
                fs.writeFile "bin/javascripts/jquery.nanoscroller.min.js", code, (errWriting) ->
                    throw errWriting if errWriting
                    console.log "Success!"
                    invoke "zip"
