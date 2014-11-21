module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt)

  theme = grunt.option('theme') or 'bootstrap'
  lib = grunt.option('lib') or 'angular'

  grunt.initConfig
    connect:
      dev:
        options:
          port: 9001
          livereload: yes
          base: "doks"
          open:
            appName: 'google-chrome'
            target: 'http://127.0.0.1:<%= connect.dev.options.port %>'

    watch:
      dev:
        files: ["themes/#{theme}-#{lib}/**/*", "doks/**/*"]
        tasks: ['build']
        options:
          livereload: yes

  grunt.registerTask 'build', []
  grunt.registerTask 'dev', ['connect:dev', 'watch:dev']