events = require 'events'
async = require 'async'
fs = require 'fs'

class TailWatcher extends events.EventEmitter

  constructor: (@filepath) ->
    @buffer = ''
    @dispatcher = new events.EventEmitter()
    @queue = []
    @watching_p = false
    @pos = fs.statSync(@filepath).size
    @dispatcher.on 'push', @readLine
    @watch()

  watch: ->
    return if @watching_p
    if fs.watch
      try
        @watcher = fs.watch @filepath, (event) => @handleWatchEvent event
      catch error
        console.log "error caused! can not read #{@filepath}"
    else
      try
        fs.wathcFile @filepath, (cur, pre) => @handleWatchFileEvent cur, pre
      catch error
        console.log "error caused! can not read #{@filepath}"

  handleWatchEvent: (event) ->
    if event is 'change'
      fs.stat @filepath, (err, stats) =>
        if err
          console.log "error: #{err}"
          @emit 'error', err
        else
          @pos = stats.size if stats.size < @pos
          if stats.size > @pos
            @queue.push {start: @pos, end: stats.size}
            @pos = stats.size
            @dispatcher.emit 'push' if @queue.length is 1
    else if event is 'rename'
      @unwatch()
      setTimeout (=> @watch()), 1000

  handleWatchFileEvent: (cur, pre) ->
    if cur.size > pre.size
      @queue.push {start: pre.size, end: cur.size}
      @dispatcher.emit 'push' if @queue.length is 1

  unwatch: ->
    if fs.watch and @watcher
      @watcher.close()
      @pos = 0
    else
      fs.unwatchFile @filepath
    @watching_p = false
    @queue = []

  readLine: =>
    if @queue.length >= 1
      line = @queue.shift()
      if line.end > line.start
        stream = fs.createReadStream(
                  @filepath
                  {start:line.start, end:line.end-1, encoding:"utf-8"})
        stream.on 'error', (err) =>
          console.log "error: #{err}"
          @emit 'error', err
        stream.on 'end', =>
          @dispatcher.emit 'push' if @queue.length >= 1
        stream.on 'data', (data) =>
          @buffer += data
          lines = @buffer.trim().split '\n'
          @buffer = ''
          for chunk in lines
            @emit 'push', chunk

class FolderWatcher extends events.EventEmitter

  constructor: (@folderpath) ->
    @files = fs.readdirSync @folderpath
    async.forEach @files, (file) =>
      (new TailWatcher @folderpath + file).on 'push', (data) =>
        @emit 'push', {file: @folderpath+file, data: data}
    @watchFolder()

  watchFolder: ->
    if fs.watch
      fs.watch @folderpath, (event) => @handleEvent()
    else
      fs.wathcFile @folderpath, (cur, pre) => @handleEvent()

  handleEvent: ->
    files = fs.readdirSync(@folderpath)
    for file in files
      unless file in @files
        @files.push file
        (new TailWatcher @folderpath + file).on 'push', (data) =>
          @emit 'push', {file: @folderpath+file, data: data}

exports.TailWatcher = TailWatcher
exports.FolderWatcher = FolderWatcher
