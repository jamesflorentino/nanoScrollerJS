/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-yuidoc');
  grunt.loadNpmTasks('grunt-jasmine-task');
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-css');
  grunt.loadNpmTasks('grunt-sizediff');
  grunt.loadNpmTasks('grunt-shell');

  // Project configuration.
  grunt.initConfig({
    dirs: {
      coffeeDir: 'coffeescripts',
      jsDir: 'bin/javascripts',
      cssDir: 'bin/css',
      testDir: 'tests'
    },
    pkg: '<json:nanoscroller.jquery.json>',
    meta: {
      unmin: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */',
      min: '/*! <%= pkg.title || pkg.name %> v<%= pkg.version %> ' +
        '(c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */'
    },
    concat: {
      unmin: {
        src: ['<banner:meta.unmin>', '<file_strip_banner:bin/javascripts/<%= pkg.name %>.js>'],
        dest: '<%= dirs.jsDir %>/<%= pkg.name %>.js'
      },
      min: {
        src: ['<banner:meta.min>', '<file_strip_banner:bin/javascripts/<%= pkg.name %>.min.js>'],
        dest: '<%= dirs.jsDir %>/<%= pkg.name %>.min.js'
      }
    },
    csslint: {
      all: {
        src: '<%= dirs.cssDir %>/nanoscroller.css',
        rules: {
            'fallback-colors': false,
            'known-properties': false,
            'compatible-vendor-prefixes': false,
            'adjoining-classes': false,
            'empty-rules': true,
            'zero-units': true,
            ids: true,
            important: true
        }
      }
    },
    coffee: {
      nano: {
        src: ['<%= dirs.coffeeDir %>/*.coffee'],
        dest: '<%= dirs.jsDir %>',
        options: {
            bare: true
        }
      },
      tests: {
        src: ['<%= dirs.testDir %>/coffeescripts/*.coffee'],
        dest: '<%= dirs.testDir %>/spec'
      }
    },
    min: {
      all: {
        src: ['<%= dirs.jsDir %>/<%= pkg.name %>.js'],
        dest: '<%= dirs.jsDir %>/<%= pkg.name %>.min.js'
      }
    },
    sizediff: {
      all: {
        files: [
            '<%= dirs.jsDir %>/<%= pkg.name %>.js',
            '<%= dirs.jsDir %>/<%= pkg.name %>.min.js'
        ]
      }
    },
    jasmine: {
      all: ['<%= dirs.testDir %>/SpecRunner.html']
    },
    lint: {
      files: ['grunt.js']
    },
    watch: {
      files: '<config:coffee.nano.src>',
      tasks: 'default'
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true
      },
      globals: {
        jQuery: true
      }
    },
    shell: {
      marked: {
        command: 'node_modules/marked/bin/marked README.md > bin/readme.html',
        stdout: true
      }
    },
    yuidoc: {
      compile: {
        options: {
          paths: "bin/javascripts",
          outdir: "docs/"
        }
      }
    }
  });

  grunt.registerTask('default', 'coffee:nano min concat:unmin concat:min csslint lint sizediff shell:marked yuidoc');
  grunt.registerTask('build', 'default');
  grunt.registerTask('build:tests', 'coffee:tests');
  grunt.registerTask('test', 'coffee:tests jasmine');
  grunt.registerTask('size', 'sizediff');
};
