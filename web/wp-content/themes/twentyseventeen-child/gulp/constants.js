import browserSync from 'browser-sync';

export const server = browserSync.create();

export const url = 'https://pantheonwpbestpractices.lndo.site';

export const dirs = {
    src: 'source',
    dest: 'assets'
};

export const sassPaths = {
    src: `${dirs.src}/css/`,
    mainFile: `${dirs.src}/css/twentyseventeen-child.scss`,
    dest: `${dirs.dest}/css/`
};

export const JSpaths = {
    src: `${dirs.src}/js/`,
    mainFile: `${dirs.src}/js/twentyseventeen-child.js`,
    dest: `${dirs.dest}/js/`
};

export const $ = require('gulp-load-plugins')();