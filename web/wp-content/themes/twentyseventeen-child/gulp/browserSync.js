import {server, url} from './constants';

export default function serve(done) {
    server.init({
        files: ["assets/css/*.css", "assets/js/*.js", "**/*.php"],
        proxy: {
            target: url
        }
    });
    done();
}