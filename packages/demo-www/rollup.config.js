import fs from 'fs-extra';
import path from 'path';
import serve from 'rollup-plugin-serve';
import typescript from 'rollup-plugin-typescript2';
import resolve from 'rollup-plugin-node-resolve';

const isWatching = process.env.ROLLUP_WATCH;

const dist = path.resolve(__dirname, 'dist');
const publicFolder = path.resolve(__dirname, 'public');
const output = path.resolve(dist, 'bundle.js');

// Copy public folder
fs.copySync(publicFolder, dist);

export default {
    input: 'src/index.ts',
    output: {
        file: output,
        format: 'es'
    },
    plugins: [
        resolve({
            mainFields: ['module'],
            preserveSymlinks: false
        }),
        typescript(),
        isWatching &&
            serve({
                contentBase: dist,
                open: false,
                host: '0.0.0.0',
                port: 3000
            })
    ].filter(Boolean)
};
