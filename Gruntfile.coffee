microflo_make = "make -f ./node_modules/microflo/Makefile \
  MICROFLO_SOURCE_DIR=#{process.cwd()}/node_modules/microflo/microflo \
  MICROFLO=./node_modules/.bin/microflo
  BUILD_DIR=#{process.cwd()}/build"

#console.log microflo_make

module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Updating the package manifest files
    noflo_manifest:
      update:
        files:
          'component.json': ['graphs/*', 'components/*']
          'package.json': ['graphs/*', 'components/*']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # Browser version building
    noflo_browser:
      build:
        files:
          'browser/ingress-table.js': ['component.json']

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          './browser/ingress-table.min.js': ['./browser/ingress-table.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

    exec:
      build_arduino: "#{microflo_make} GRAPH=graphs/PortalLights.fbp LIBRARY=arduino-standard build-arduino"
      build_tiva: "#{microflo_make} STELLARIS_GRAPH=graphs/TableLights.fbp build-stellaris"

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-noflo-manifest'
  @loadNpmTasks 'grunt-noflo-browser'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'microflo', ['exec:build_arduino']
  @registerTask 'build', ['noflo_manifest', 'noflo_browser', 'uglify']
  @registerTask 'test', ['coffeelint', 'build', 'cafemocha']
  @registerTask 'default', ['test']
