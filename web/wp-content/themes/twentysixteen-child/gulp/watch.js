import gulp from 'gulp';
import {sassPaths, JSpaths, reload} from './constants';
import buildScript from './buildScript';

export default () => {
    // Watch Sass files and run scripts task on change
    gulp.watch([sassPaths.src + '**/*'], ['styles']);

    // Reload the page when a PHP file changes
    gulp.watch('**/*.php').on('change', browserSync.reload);

    // buildScript will run watchify since watch is set to true
    return buildScript(JSpaths.mainFile, true);
}