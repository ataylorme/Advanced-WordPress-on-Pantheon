'use strict';

// External dependencies
import {task, parallel, series} from 'gulp';
import rimraf from 'rimraf';
import log from 'fancy-log';
import colors from 'ansi-colors';

// Internal dependencies
import {JSpaths} from './gulp/constants';
import buildStyles from './gulp/buildStyles';
import buildScript from './gulp/buildScript';
import clean from './gulp/clean';
import watchFiles from './gulp/watch';
import serve from './gulp/browserSync';

export const assets = series(clean, parallel( buildStyles, buildScript ) );
export const watch = series(clean, parallel( buildStyles, buildScript ), watchFiles);
export const dev = series(clean, parallel( buildStyles, buildScript ), parallel(serve, watchFiles));

export default assets;