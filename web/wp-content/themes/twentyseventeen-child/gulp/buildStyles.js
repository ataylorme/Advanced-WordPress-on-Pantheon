import {src, dest, watch, parallel, series} from 'gulp';
import pump from 'pump';
import {sassPaths, $} from './constants';
import log from 'fancy-log';
import colors from 'ansi-colors';

export default function buildStyles (done) {
    log(colors.green('Building ') + colors.yellow(`${sassPaths.mainFile}...`));
    
    pump([
        // read source sass file
        src(sassPaths.mainFile, {sourcemaps: true}),
        // run sass
        $.sass.sync({
            // define relative image path for "image-url"
            imagePath: '../images',
            outputStyle: 'nested',
            includePaths: [
                './node_modules/breakpoint-sass/stylesheets',
                './node_modules/normalize.css'
            ]
        })
        // log sass errors
        .on('error', err => {
            let projectPath = __dirname.replace( /\/gulp$/, '');
            log(colors.red("CSS Error:"), colors.yellow(
                err.message.replace(projectPath, '.').replace(projectPath, '.')
            ));
        }),
        // autoprefix
        $.autoprefixer({
            browsers: ['last 2 versions']
        }),
        // save human readable file
        dest(sassPaths.dest, {sourcemaps: true}),
        // rename to add .min
        $.rename({
            suffix: ".min"
        }),
        // minify
        $.cssnano(),
        // save minified file
        dest(sassPaths.dest, {sourcemaps: true}),
    ], done);
}