import {server, url} from './constants';

export function reload(done) {
    server.reload();
    done();
}  

export default function serve(done) {
    server.init({
        files: ["assets/css/*.css", "assets/js/*.js", "**/*.php"],
        proxy: {
            target: url
        },
        open: false,
        port: 3000
    });
    done();
}
