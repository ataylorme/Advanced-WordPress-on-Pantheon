'use strict';

import gulp from 'gulp';
import {JSpaths} from './gulp/constants';
import buildStyles from './gulp/buildStyles';
import buildScript from './gulp/buildScript';
import browserSyncServe from './gulp/browserSyncServe';
import watch from './gulp/watch';

gulp.task('styles', buildStyles);

// buildScript will run once because watch is set to false
gulp.task('scripts', () => buildScript(JSpaths.mainFile, false));

/**
 * BrowserSync task
 * Runs a web server and listens for asset
 * changes to inject into the browser
 */
gulp.task('browserSync', ['assets'], browserSyncServe);

/**
 * Assets Task
 * Builds scripts and styles
 */
gulp.task(
    'assets', [
    'scripts',
    'styles'
    ]
);

/**
 *  Watch task builds assets and serves them with BrowserSync.
 *  When a file changes the assets are rebuilt and the changes sent to the browser
 */
gulp.task('watch', ['assets', 'browserSync'], watch);

/**
 * Default task
 * Simply builds assets
 * Runs when `gulp` is invoked with no task specified
 */
gulp.task('default', ['assets']);