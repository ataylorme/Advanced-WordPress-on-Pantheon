import gulp from 'gulp';
import {sassPaths, JSpaths} from './constants';
import buildScript from './buildScript';

export default () => {
    // Watch Sass files and run scripts task on change
    gulp.watch([sassPaths.src + '**/*'], ['styles']);

    // buildScript will run watchify since watch is set to true
    return buildScript(JSpaths.mainFile, true);
}