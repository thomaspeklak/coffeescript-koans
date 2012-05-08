fs = require 'fs'
path = require('path')
join = path.join

util  = require('util')
spawn = require('child_process').spawn

watch = (files, fn) ->
  options = interval: 100
  files.forEach (file) ->
    fs.watchFile file, options, (curr, prev) ->
      if prev.mtime < curr.mtime
        fn(file)

files = (dir, ret) ->
  ret?= []

  fs.readdirSync(dir)
    .forEach (path) ->
      path = join(dir, path)
      if fs.statSync(path).isDirectory()
        files path, ret
      else
        if  path.match(/\.coffee$/)
          ret.push path
  ret

test = (file) ->
  jasmine = spawn('jasmine-node', ['--coffee', file])
  
  jasmine.stdout.on 'data', (data) ->
    process.stdout.write(data)

  jasmine.on 'exit', (data) ->
    console.log '--------------------------------------------------'

watch(
  files('./koans'),
  (file) ->
    console.log 'running test on:' + file
    test file
)
