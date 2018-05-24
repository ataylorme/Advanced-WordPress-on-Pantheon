'use strict';

// External dependencies
import {watch, parallel, series} from 'gulp';
import rimraf from 'rimraf';
import log from 'fancy-log';
import colors from 'ansi-colors';

// Internal dependencies
import {JSpaths} from './gulp/constants';
import buildStyles from './gulp/buildStyles';
import buildScript from './gulp/buildScript';

export function clean(done){
    log(colors.red('Deleting assets...'));
    rimraf('assets', done);
}

const assets = series(clean, parallel( buildStyles, buildScript ) );

export default assets;