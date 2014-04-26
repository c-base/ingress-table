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
    exec:
      install:
        command: 'node ./node_modules/component/bin/component install'
      build:
        command: 'node ./node_modules/component/bin/component build -u component-json,component-coffee -o browser -n ingress-table -c'

    # Fix broken Component aliases, as mentioned in
    # https://github.com/anthonyshort/component-coffee/issues/3
    combine:
      browser:
        input: 'browser/ingress-table.js'
        output: 'browser/ingress-table.js'
        tokens: [
          token: '.coffee"'
          string: '.js"'
        ]
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

    # Run a server for the tests so we can actually do AJAX
    connect:
      test:
        options:
          port: 9000

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # BDD tests on browser
    mocha_phantomjs:
      options:
        output: 'spec/result.xml'
        reporter: 'spec'
      all:
        options:
          urls: ['http://localhost:9000/spec/runner.html']

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-noflo-manifest'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-combine'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'build', ['noflo_manifest', 'exec:install', 'exec:build', 'combine', 'uglify']
  @registerTask 'test', ['coffeelint', 'cafemocha'] #, 'connect', 'mocha_phantomjs']
  @registerTask 'default', ['test']
