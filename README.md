
# recompile

"recompile" is an auto-recompiler for command-line node scripts.

For example, if you're writing a CLI tool in coffee-script, it may be convenient for it to recompile and restart itself if the source code changes. You can do this by starting your script with:

```coffee-script
recompile = require "recompile"

recompile.check "./src", "./lib", ->
  # your actual code here
```

The `check` function is:

```
check(sourceFolder, targetFolder, [options], callback)
```

It deep-compares the two folders, using a transform function to build target filenames from source filenames, and if any file in the target folder is newer than its corresponding file in the source folder, it executes a recompile command (using `child_process.spawn`) and then re-spawns node with its original command-line arguments, to try again. If the target folder is up-to-date, it simply calls your callback.

Note that the callback is only called once `recompile` is sure that the target folder is up-to-date. If it's not, the callback will never be called inside the current process -- only the spawned one.

Valid options are:

- `quiet` (default: `false`) -- if true, don't emit anything to the console when recompiling

- `command` (default: `[ "./node_modules/.bin/coffee", "-o", targetFolder, "-c", sourceFolder ]`) -- command to execute to recompile, as an array

- `transform` (default: `(filename) -> filename.replace(/.coffee$/, ".js")`) -- transform function to convert source filenames to target filenames

# License

Apache 2 (open-source) license, included in 'LICENSE.txt'.

# Authors

@robey - Robey Pointer <robeypointer@gmail.com>
