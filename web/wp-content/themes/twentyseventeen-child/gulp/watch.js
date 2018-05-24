import {src, dest, watch, parallel, series} from 'gulp';
import pump from 'pump';
import log from 'fancy-log';
import colors from 'ansi-colors';

import {sassPaths, JSpaths, $} from './constants';
import buildStyles from './buildStyles';
import buildScript from './buildScript';
import clean from './clean';

export default function watchFiles () {
    log(colors.green('Watching files for changes...'));
    watch(sassPaths.src, series(clean, buildStyles));
    watch(JSpaths.src, series(clean, buildScript));
}