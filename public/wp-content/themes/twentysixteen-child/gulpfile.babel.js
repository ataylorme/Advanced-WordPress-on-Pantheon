'use strict';

import gulp from 'gulp';
import source from 'vinyl-source-stream';
import browserify from 'browserify';
import babelify from 'babelify';
import watchify from 'watchify';
import buffer from 'vinyl-buffer';
import chalk from 'chalk';


var $ = require('gulp-load-plugins')({
        pattern: ['gulp-*', 'gulp.*', 'main-bower-files'],
        replaceString: /\bgulp[\-.]/
    }),
    browserSync = require('browser-sync').create(),
    reload = browserSync.reload;

const dirs = {
    src: 'source',
    dest: 'assets'
};

const sassPaths = {
    src: `${dirs.src}/css/twentysixteen-child.scss`,
    dest: `${dirs.dest}/css/`
};

const JSpaths = {
    src: `${dirs.src}/js/twentysixteen-child.js`,
    dest: `${dirs.dest}/js/`
};

gulp.task('styles', () => {
    $.util.log($.util.colors.green('Building ') + $.util.colors.yellow(`${sassPaths.src}...`));
    return gulp.src(sassPaths.src)
        // start sourcemap
        .pipe($.sourcemaps.init())
        // run sass
        .pipe($.sass.sync({
            // define relative image path for "image-url"
            imagePath: '../images',
            outputStyle: 'nested'
        }))
        // log sass errors
        .on('error', err => {
        $.util.log($.util.colors.red("CSS Error:"), $.util.colors.yellow(
                err.message.replace(__dirname, '.').replace(__dirname, '.')
            ));
        })
        // add browser prefixes
        .pipe($.autoprefixer({
            browsers: ['last 2 versions', 'ie 10']
        }))
        // save human readable file
        .pipe(gulp.dest(sassPaths.dest))
        // send changes to Browser-sync
        .pipe(reload({stream: true}))
        // minify css
        .pipe($.minifyCss({
            keepSpecialComments: 1
        }))
        // rename to min
        .pipe($.rename({
            suffix: ".min"
        }))
        // write sourcemap
        .pipe($.sourcemaps.write('./'))
        // save minified file
        .pipe(gulp.dest(sassPaths.dest));
});

function buildScript(file, watch) {
    var props = {
        entries: ['./' + file],
        debug: true,
        transform: [babelify.configure({presets: ["es2015"]})]
    };

    // watchify() if watch requested, otherwise run browserify() once
    var bundler = watch ? watchify(browserify(props)) : browserify(props);

    if( !watch ){
        $.util.log($.util.colors.green('Building ') + $.util.colors.yellow(`${file}...`));
    }

    function rebundle() {
        // create an initial text stream from browserify
        var stream = bundler.bundle();
        return stream
            // log errors
            .on('error', err => {
                $.util.log($.util.colors.red("JS Error:"), $.util.colors.yellow(
                    err.message.replace(__dirname, '.').replace(__dirname, '.')
                ));
            })
            /**
             * stream is a text stream but gulp uses
             * vinyl streams so we must convert the
             * text stream to a vinyl stream to use
             * any gulp elements
             */
            .pipe(source(file))
            // strip any directories in the file path
            .pipe($.rename({
                dirname: '/'
            }))
            // output a human readable file
            .pipe(gulp.dest(JSpaths.dest))
            /**
             * we have a streaming vinyl object but uglify and
             * sourcemaps need a buffered vinyl file objects so
             * we must change the stream again by buffering it
             */
            .pipe(buffer())
            // start source maps
            .pipe($.sourcemaps.init({loadMaps: true}))
            // minify the file
            .pipe($.uglify({
                preserveComments: 'some',
                mangle: false
            }))
            // rename to .min
            .pipe($.rename({
                suffix: ".min"
            }))
            // save source map
            .pipe($.sourcemaps.write('./'))
            // save the minified file
            .pipe(gulp.dest(JSpaths.dest))
            // pass changes to browser sync
            .pipe(reload({stream: true}));
    }

    // listen for an update and run rebundle
    bundler.on('update', function () {
        rebundle();
        $.util.log($.util.colors.green('Rebuilding ') + $.util.colors.yellow(`${file}...`));
    });

    // run it once the first time buildScript is called
    return rebundle();
}

// buildScript will run once because watch is set to false
gulp.task('scripts', () => buildScript(JSpaths.src, false) );

// BrowserSync
gulp.task('browserSync', ['assets'], () => {
    browserSync.init({
        // see http://www.browsersync.io/docs/options/
        open: false
    });
});

// Assets Task
gulp.task('assets', [
    'scripts',
    'styles'
]);

gulp.task('watch', ['assets'], () => {
    // Watch Sass files and run scripts task on change
    gulp.watch([sassPaths.src], ['styles']);

    // Reload the page when a PHP file changes
    gulp.watch('**/*.php').on('change', browserSync.reload);

    return buildScript(JSpaths.src, true);
});

// Default task is to build assets
gulp.task('default', ['assets']);

// Watch task
gulp.task('build', ['browserSync', 'watch']);