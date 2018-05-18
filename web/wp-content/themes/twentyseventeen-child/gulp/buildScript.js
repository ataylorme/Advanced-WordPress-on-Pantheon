import gulp from 'gulp';
import source from 'vinyl-source-stream';
import browserify from 'browserify';
import babelify from 'babelify';
import watchify from 'watchify';
import buffer from 'vinyl-buffer';
import {JSpaths, $} from './constants';

/**
 *
 * @param file {string} Relative path to the file to compile
 * @param watch {boolean} True to watch for changes, false to run once
 * @returns {*}
 */
export default (file, watch) => {
    let props = {
        entries: ['./' + file],
        debug: true,
        transform: [babelify]
    };

    // watchify() if watch requested, otherwise run browserify() once
    let bundler = watch ? watchify(browserify(props)) : browserify(props);

    if (!watch) {
        $.util.log($.util.colors.green('Building ') + $.util.colors.yellow(`${file}...`));
    }

    function rebundle() {
        // create an initial text stream from browserify
        let stream = bundler.bundle();
        return stream
        // log errors
            .on('error', err => {
                // __dirname is the path of the current file, so we need to remove '/gulp'
                let projectPath = __dirname.replace( /\/gulp$/, '');
                $.util.log($.util.colors.red("JS Error:"), $.util.colors.yellow(
                    // remove the project path from the error message to only display a relative path
                    err.message.replace(projectPath, '.').replace(projectPath, '.')
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
                mangle: false
            }))
            // rename to .min
            .pipe($.rename({
                suffix: ".min"
            }))
            // save source map
            .pipe($.sourcemaps.write('./'))
            // save the minified file
            .pipe(gulp.dest(JSpaths.dest));
    }

    // listen for an update and run rebundle
    bundler.on('update', function () {
        rebundle();
        $.util.log($.util.colors.green('Rebuilding ') + $.util.colors.yellow(`${file}...`));
    });

    // run it once the first time buildScript is called
    return rebundle();
}
