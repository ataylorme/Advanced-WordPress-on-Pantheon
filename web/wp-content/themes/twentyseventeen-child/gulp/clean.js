import rimraf from 'rimraf';
import log from 'fancy-log';
import colors from 'ansi-colors';
import {dirs, sassPaths, JSpaths} from './constants';

export default function clean(done){
    log(colors.red('Deleting assets...'));
    rimraf(dirs.dest, done);
}

export function cleanScripts(done){
    log(colors.red('Deleting JS...'));
    rimraf(JSpaths.dest, done);
}

export function cleanStyles(done){
    log(colors.red('Deleting CSS...'));
    rimraf(sassPaths.dest, done);
}