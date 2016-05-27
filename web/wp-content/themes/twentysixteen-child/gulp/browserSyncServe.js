import {browserSync} from './constants';

export default () => {
    browserSync.init({
        // see http://www.browsersync.io/docs/options/
        open: false
    });
}