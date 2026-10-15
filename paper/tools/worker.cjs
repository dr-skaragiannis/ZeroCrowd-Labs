const { parentPort, workerData } = require('worker_threads');
const nodeFs = require('fs');
const nodePath = require('path');
const vm = require('vm');
let handler = null;
const sandbox = {
  console, process, require, Buffer, setTimeout, clearTimeout, setInterval, clearInterval,
  __dirname: '/tmp/texrun', __filename: '/tmp/texrun/worker.cjs',
};
sandbox.self = sandbox;
sandbox.global = sandbox;
sandbox.postMessage = (msg) => parentPort.postMessage(msg);
Object.defineProperty(sandbox, 'onmessage', {
  get() { return handler; },
  set(fn) { handler = fn; }
});
function loadTexmf() {
  const FS = sandbox.g;
  const base = (workerData && workerData.texmfBase) || '/tmp/tltest/package/texlive';
  let count = 0, bytes = 0;
  function walk(dir) {
    for (const ent of nodeFs.readdirSync(dir, { withFileTypes: true })) {
      const full = nodePath.join(dir, ent.name);
      if (ent.isDirectory()) {
        if (ent.name === 'source' || ent.name === 'doc') continue;
        walk(full);
      } else {
        const rel = nodePath.relative(base, full); // e.g. texmf-dist/tex/...
        const vpath = '/' + rel.split(nodePath.sep).join('/');
        const parent = nodePath.posix.dirname(vpath);
        const name = nodePath.posix.basename(vpath);
        try { FS.oc('/', parent.slice(1), true, true); } catch (e) {}
        const buf = nodeFs.readFileSync(full);
        try {
          FS.Ma(parent, name, new Uint8Array(buf), true, true);
          count++; bytes += buf.length;
        } catch (e) { console.error('createDataFile fail', vpath, e && e.message); }
      }
    }
  }
  walk(base);
  console.error(`TEXMF LOADED ${count} files ${bytes} bytes`);
  parentPort.postMessage(JSON.stringify({ command: 'texmf_loaded', count, bytes }));
}
parentPort.on('message', (data) => {
  if (data === '__LOAD_TEXMF__') { loadTexmf(); return; }
  if (handler) handler({ data });
});
sandbox.XMLHttpRequest = class {
  open(method, url, asyncFlag) { this.url = url; }
  send() { this.response = ''; if (this.onload) this.onload(); }
};
vm.createContext(sandbox);
const code = nodeFs.readFileSync((workerData && workerData.workerJs) || '/tmp/tltest/package/pdftex-worker.js', 'utf8');
vm.runInContext(code, sandbox, { filename: 'pdftex-worker.js' });
