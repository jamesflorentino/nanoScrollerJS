fs = require "fs"
{exec} = require "child_process"
closure = require "./build/closure"

task "build", "Build everything and minify", (options) ->
  exec "redcarpet README.md > bin/readme.html", () ->
  exec "coffee -c --bare --output bin/javascripts/ coffeescripts/", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr if (stderr? or stdout?)
    fs.readFile "bin/javascripts/jquery.nanoscroller.js", "utf-8", (errReading, data) ->
      throw errReading if errReading
      closure.compile data, (errCompiling, code) ->
        throw errCompiling if errCompiling
        fs.writeFile "bin/javascripts/jquery.nanoscroller.min.js", code, (errWriting) ->
          throw errWriting if errWriting
          console.log "Success!"

task "server", "Run a simple http server in Python for testing", (options) ->
  console.log "Running a python server in http://localhost:8100"
  exec "python -m SimpleHTTPServer 8100", (o) ->
