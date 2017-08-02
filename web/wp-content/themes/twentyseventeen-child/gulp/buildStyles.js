import gulp from 'gulp';
import {sassPaths, $} from './constants';

/**
 * @desc Compiles the main Sass file into an expanded,
 *  human readable format and a minified format.
 *  Adds browser prefixing and sourcemaps.
 * @returns {*}
 */
export default () => {
    $.util.log($.util.colors.green('Building ') + $.util.colors.yellow(`${sassPaths.mainFile}...`));
    return gulp.src(sassPaths.mainFile)
        // start sourcemap
        .pipe($.sourcemaps.init())
        // run sass
        .pipe($.sass.sync({
            // define relative image path for "image-url"
            imagePath: '../images',
            outputStyle: 'nested',
            includePaths: [
                './node_modules/breakpoint-sass/stylesheets',
                './node_modules/normalize.css'
            ]
        }))
        // log sass errors
        .on('error', err => {
            let projectPath = __dirname.replace( /\/gulp$/, '');
            $.util.log($.util.colors.red("CSS Error:"), $.util.colors.yellow(
                err.message.replace(projectPath, '.').replace(projectPath, '.')
            ));
        })
        // add browser prefixes
        .pipe($.autoprefixer({
            browsers: ['last 2 versions', 'ie 10']
        }))
        // save human readable file
        .pipe(gulp.dest(sassPaths.dest))
        // minify css
        .pipe($.cssnano())
        // rename to min
        .pipe($.rename({
            suffix: ".min"
        }))
        // write sourcemap
        .pipe($.sourcemaps.write('./'))
        // save minified file
        .pipe(gulp.dest(sassPaths.dest));
}