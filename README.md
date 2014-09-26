This is Tail Watcher for Node.js
===

author: Rudolph-Miller
---

How to Use
```
	TailWatcher = require('tail-watcher').TailWatcher('*watching-file*')
	TailWatcher.push, (data) -> *action-for-data* data

	FolderWatcher = require('node-tail-watcher').FolderWatcher('*watching-folder*')
	FolderWatcher.push, (data) -> *action-for-data* data
```

1. TailWatcher extends EventEmitter
	* watcher file and emit events if it has changed 
	* emit 'push', (data) -> console.log data
	* emit 'error', (err) -> console.log err

2. FolderWatcher
	* watcher folder and emit events if files in it have changed 
	* emit 'push', (data) -> console.log data
	* emit 'error', (err) -> console.log err

Please fork it and send me PR.
