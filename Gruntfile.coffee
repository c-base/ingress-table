fs = require 'fs'
path = require 'path'

microflo_make = "make -f ./node_modules/microflo/Makefile \
  MICROFLO_SOURCE_DIR=#{process.cwd()}/node_modules/microflo/microflo \
  MICROFLO=./node_modules/.bin/microflo
  BUILD_DIR=#{process.cwd()}/build"

microflo_gen = (name, options={}) ->
  defaults =
    microflo: './node_modules/.bin/microflo'
    target: 'linux'
    out: "build/#{options.target||'linux'}/#{name}/#{name}.cpp"
    graph: "graphs/#{name}.fbp"
    library: "./components-#{name}.json"
  for k,v of defaults
    options[k] = v if not options[k]?

  dir = path.dirname options.out
  parent = path.dirname dir
  grandparent = path.dirname parent
  fs.mkdirSync grandparent if not fs.existsSync grandparent
  fs.mkdirSync parent if not fs.existsSync parent
  fs.mkdirSync dir if not fs.existsSync dir
  cmd = [
    options.microflo,
    '--target', options.target
    '--library', options.library
    'generate', options.graph, options.out
  ]
  return cmd.join(' ')

microflo_compile = (name, options={}) ->
  defaults =
    out: "build/#{options.target||'linux'}/#{name}/#{name}"
    in: "build/#{options.target||'linux'}/#{name}/#{name}.cpp"
  for k,v of defaults
    options[k] = v if not options[k]?
  cmd = [
    "g++ -g -Wall -Werror -Wno-unused-variable -DLINUX -std=c++0x"
    "-I./build -I./node_modules/microflo/microflo"
    "-o", options.out, options.in
    "-lrt -lutil"
  ]
  return cmd.join(' ')

#console.log microflo_make

module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          grep: process.env.TESTS

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

    noflo_lint:
      graphs:
        options:
          description: 'ignore'
          icon: 'ignore'
          port_descriptions: 'ignore'
          asynccomponent: 'error'
          wirepattern: 'warn'
          process_api: 'ignore'
          legacy_api: 'ignore'
        files:
          src: [
            'graphs/bgt9b.json'
          ]

    exec:
      build_arduino: "#{microflo_make} GRAPH=graphs/PortalLights.fbp LIBRARY=arduino-standard build-arduino"
      build_tiva: "#{microflo_make} STELLARIS_GRAPH=graphs/TableLights.fbp build-stellaris"
      tablelights_linux_gen: microflo_gen 'TableLights' 
      tablelights_linux_comp: microflo_compile 'TableLights'
      tablelights_run: './spec/microflo-linux.sh TableLights 4444 & sleep 5'
      portallights_linux_gen: microflo_gen 'PortalLights' 
      portallights_linux_comp: microflo_compile 'PortalLights'
      portallights_run: './spec/microflo-linux.sh PortalLights 5555 & sleep 5'
      kill_microflo_linux: 'kill $(pgrep microflo-linux)'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-exec'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-noflo-lint'

  # Our local tasks
  @registerTask 'build-microflo', [
    'exec:tablelights_linux_gen', 'exec:tablelights_linux_comp',
    'exec:portallights_linux_gen', 'exec:portallights_linux_comp',
  ]
  @registerTask 'run-microflo-linux', [
    'exec:kill_microflo_linux'
    'exec:tablelights_run'
    'exec:portallights_run'
  ]
  @registerTask 'build', ['build-microflo']
  @registerTask 'test', ['coffeelint', 'build', 'noflo_lint', 'run-microflo-linux', 'mochaTest']
  @registerTask 'default', ['test']
