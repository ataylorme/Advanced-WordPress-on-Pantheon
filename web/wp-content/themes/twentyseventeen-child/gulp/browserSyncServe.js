import {browserSync} from './constants';

export default () => {
    browserSync.init({
        // see http://www.browsersync.io/docs/options/
        open: false,
        https: true,
        proxy: 'https://pantheon-wp-best-practices.kbox.site/',
		files: ['assets/css/*.min.css', 'assets/js/*.min.js', '**/*.php'],
		reloadDelay: 1500
    });
}
