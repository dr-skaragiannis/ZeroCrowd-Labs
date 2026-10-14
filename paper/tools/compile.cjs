// Compile a .tex file with the texlive.js pdfTeX (TeX Live 2010) in Node.
// Usage: node compile.cjs <input.tex> <output.pdf> [extraFile::/virtual/path ...]
// Env: TEXLIVE_JS_DIR = dir containing pdftex-worker.js and texlive/ (npm package "texlive").
// pdfTeX can run main() only once per worker, so each pass uses a fresh
// worker and the .aux/.log are carried forward between passes (3 passes).
const { Worker } = require('worker_threads');
const fs = require('fs'); const path = require('path');
const TEXDIR = process.env.TEXLIVE_JS_DIR || path.join(__dirname, 'texlive-js');
const WORKER_JS = path.join(TEXDIR, 'pdftex-worker.js');
const TEXMF = path.join(TEXDIR, 'texlive');

function runPass(texSource, extras, auxContent) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(path.join(__dirname, 'worker.cjs'), {
      workerData: { texmfBase: TEXMF, workerJs: WORKER_JS },
    });
    let msgId = 0; const promises = {}; let texmfResolve = null;
    const timer = setTimeout(() => reject(new Error('pass timeout')), 600000);
    worker.on('error', (e) => { clearTimeout(timer); reject(e); });
    worker.on('message', async (raw) => {
      const data = JSON.parse(raw);
      if (data.command === 'texmf_loaded') { if (texmfResolve) texmfResolve(); return; }
      if (data.command === 'stdout' || data.command === 'stderr') return; // log file carries this
      if (data.command === 'ready') {
        try {
          const send = (cmd) => new Promise((res) => { const id = msgId++; promises[id] = res; worker.postMessage(JSON.stringify({ ...cmd, msg_id: id })); });
          await send({ command: 'set_TOTAL_MEMORY', arguments: [256 * 1024 * 1024] });
          await new Promise((res) => { texmfResolve = res; worker.postMessage('__LOAD_TEXMF__'); });
          await send({ command: 'FS_createDataFile', arguments: ['/', 'input.tex', texSource, true, true] });
          if (auxContent) await send({ command: 'FS_createDataFile', arguments: ['/', 'input.aux', auxContent, true, true] });
          for (const [vpath, buf] of extras) {
            const vdir = path.posix.dirname(vpath); const vname = path.posix.basename(vpath);
            if (vdir !== '/') await send({ command: 'FS_createPath', arguments: ['/', vdir.slice(1), true, true] });
            await send({ command: 'FS_createDataFile', arguments: [vdir, vname, buf.toString('binary'), true, true] });
          }
          await send({ command: 'run', arguments: ['-interaction=nonstopmode', '-output-format', 'pdf', 'input.tex'] });
          const readBin = async (name) => { const r = await send({ command: 'FS_readFile', arguments: [name] }); return r.result; };
          const pdfStr = await readBin('/input.pdf');
          let logStr = '', newAux = null;
          try { logStr = await readBin('/input.log'); } catch (e) {}
          try { newAux = await readBin('/input.aux'); } catch (e) {}
          clearTimeout(timer);
          await worker.terminate();
          resolve({ pdf: Buffer.from(pdfStr, 'binary'), log: logStr, aux: newAux });
        } catch (e) { clearTimeout(timer); reject(e); }
        return;
      }
      const id = data.msg_id;
      if (id !== undefined && promises[id]) { promises[id](data); delete promises[id]; }
    });
  });
}

(async () => {
  const [texPath, outPath, ...extraArgs] = process.argv.slice(2);
  const texSource = fs.readFileSync(texPath, 'utf8');
  const extras = extraArgs.map((arg) => {
    const [local, virt] = arg.split('::');
    return [virt, fs.readFileSync(local)];
  });
  let aux = null, result = null;
  for (let pass = 1; pass <= 3; pass++) {
    result = await runPass(texSource, extras, aux);
    aux = result.aux;
    console.log(`pass ${pass}: pdf=${result.pdf.length} bytes`);
    fs.writeFileSync(outPath + `.pass${pass}.log`, result.log || '');
    if (result.aux) fs.writeFileSync(outPath + `.pass${pass}.aux`, result.aux);
  }
  fs.writeFileSync(outPath, result.pdf);
  fs.writeFileSync(outPath.replace(/\.pdf$/, '.log.txt'), result.log || '');
  console.log('wrote', outPath, result.pdf.length, 'bytes');
})().catch((e) => { console.error(e); process.exit(1); });
