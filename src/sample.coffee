fs = require 'fs'
Tail = require('./tail-watcher').TailWatcher
tail = new Tail('../../log/mylog.log')
folder = require('./tail-watcher').FolderWatcher
f= new folder('../../log/')
f.on 'push', console.log

