import {src, dest, watch, parallel, series} from 'gulp';
import pump from 'pump';
import log from 'fancy-log';
import colors from 'ansi-colors';

import {sassPaths, JSpaths, $} from './constants';
import buildStyles from './buildStyles';
import buildScript from './buildScript';
import {cleanScripts, cleanStyles} from './clean';
import {reload} from './browserSync';

export default function watchFiles () {
    log(colors.green('Watching files for changes...'));
    /**
     * Injected styles don't work with Lando/Docker.
     * If you run gulp locally remove reload from the
     * watch processes to get injected styles.
     */
    watch(sassPaths.src, series(cleanStyles, buildStyles, reload));
    watch(JSpaths.src, series(cleanScripts, buildScript, reload));
}