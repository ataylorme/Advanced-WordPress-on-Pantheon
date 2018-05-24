import {src, dest, watch, parallel, series} from 'gulp';
import pump from 'pump';
import {JSpaths, $} from './constants';
import log from 'fancy-log';
import colors from 'ansi-colors';

export default function buildScript (done) {
    log(colors.green('Building ') + colors.yellow(`${JSpaths.mainFile}...`));

    pump([
        // read source JS file
        src(JSpaths.mainFile, {sourcemaps: true}),
        // run Babel
        $.babel({
             presets: [
                ['babel-preset-env', {
                  'targets': {
                    // The % refers to the global coverage of users from browserslist
                    'browsers': [ '>0.25%']
                  },
                  'modules': false
                }]
            ]
        })
        // log babel errors
        .on('error', err => {
            let projectPath = __dirname.replace( /\/gulp$/, '');
            log(colors.red("JS Error:"), colors.yellow(
                err.message.replace(projectPath, '.').replace(projectPath, '.')
            ));
        }),
        // save human readable file
        dest(JSpaths.dest, {sourcemaps: true}),
        // rename to add .min
        $.rename({
            suffix: ".min"
        }),
        // minify
        $.uglify({
            mangle: false
        }),
        // save minified file
        dest(JSpaths.dest, {sourcemaps: true}),
    ], done);
}
