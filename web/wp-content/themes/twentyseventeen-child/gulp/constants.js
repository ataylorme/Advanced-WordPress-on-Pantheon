import browserSync from 'browser-sync';

export const server = browserSync.create();
export const reload = browserSync.reload();

export const url = 'https://nginx/';

// Root path is where npm run commands happen
export const rootPath = process.env.INIT_CWD;

export const dirs = {
    src: `${rootPath}/source`,
    dest: `${rootPath}/assets`
};

export const sassPaths = {
    src: `${dirs.src}/css/**/*.scss`,
    mainFile: `${dirs.src}/css/twentyseventeen-child.scss`,
    dest: `${dirs.dest}/css/`
};

export const JSpaths = {
    src: `${dirs.src}/js/**/*.js`,
    mainFile: `${dirs.src}/js/twentyseventeen-child.js`,
    dest: `${dirs.dest}/js/`
};

export const $ = require('gulp-load-plugins')();
