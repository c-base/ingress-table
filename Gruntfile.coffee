microflo_make = "make -f ./node_modules/microflo/Makefile \
  MICROFLO_SOURCE_DIR=#{process.cwd()}/node_modules/microflo/microflo \
  MICROFLO=./node_modules/.bin/microflo
  BUILD_DIR=#{process.cwd()}/build"

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

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-exec'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-noflo-lint'

  # Our local tasks
  @registerTask 'microflo', ['exec:build_arduino']
  @registerTask 'build', []
  @registerTask 'test', ['coffeelint', 'build', 'noflo_lint', 'mochaTest']
  @registerTask 'default', ['test']
