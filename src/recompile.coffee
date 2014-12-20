child_process = require "child_process"
fs = require "fs"
path = require "path"
util = require "util"

check = (sourcePath, targetPath, options = {}, callback) ->
  # treat "options" as optional
  if (not callback?) and (typeof options == "function")
    callback = options
    options = {}
  options.command or= [ "./node_modules/.bin/coffee", "-o", targetPath, "-c", sourcePath ]
  options.transform or= (filename) -> filename.replace(/.coffee$/, ".js")
  return callback() unless isFolderNewer(sourcePath, targetPath, options.transform)

  if not options.quiet then console.log "Source is newer; recompiling..."
  spawnOrDie options.command, { detached: true, stdio: "inherit" }, ->
    trueCommand = Array.prototype.concat([ process.execPath ], process.execArgv, process.argv[1...])
    spawnOrDie trueCommand, { detached: true, stdio: "inherit" }, ->
      # nothing.

spawnOrDie = (command, options, callback) ->
  failed = (message) ->
    console.log "Unable to run: " + command.join(" ")
    console.log "Failed to recompile -- #{message}"
    process.exit(1)
  p = child_process.spawn(command[0], command[1...], options)
  p.on "error", (error) -> failed(error.stack)
  p.on "exit", (code, signal) ->
    if not code? then failed("signal #{signal}")
    if code != 0 then failed("error code #{code}")
    callback()

isFolderNewer = (sourcePath, targetPath, transform) ->
  for filename in fs.readdirSync(sourcePath)
    sourceFilename = path.join(sourcePath, filename)
    targetFilename = path.join(targetPath, transform(filename))
    if not fs.existsSync(targetFilename) then return true
    sourceStat = fs.statSync(sourceFilename)
    targetStat = fs.statSync(targetFilename)
    if sourceStat.isDirectory() != targetStat.isDirectory() then return true
    newer = if sourceStat.isDirectory() then isFolderNewer(sourceFilename, targetFilename, transform) else targetStat.mtime < sourceStat.mtime
    if newer then return true
  false

exports.check = check
