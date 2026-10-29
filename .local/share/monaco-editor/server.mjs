import { createServer } from "node:http";
import { readFile, writeFile, stat, readdir } from "node:fs/promises";
import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, extname, join, relative, resolve } from "node:path";
import { homedir } from "node:os";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { gzipSync } from "node:zlib";

const ROOT = new URL(".", import.meta.url).pathname;
const PORT = 8765;
const TYPES = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css", ".json": "application/json", ".ttf": "font/ttf", ".svg": "image/svg+xml", ".map": "application/json" };
const run = promisify(execFile);
const gzCache = new Map();
// Launch timing log: "launch" from the launcher, "index" when the browser asks for the page,
// "ready" when the editor is rendered. Shows where the seconds actually go.
const LOG = join(homedir(), ".local/state/monaco-editor/timing.log");
mkdirSync(dirname(LOG), { recursive: true });
const log = (what) => appendFileSync(LOG, `${Date.now()} ${what}\n`);
let pending = "";
const git = async (args, cwd) => (await run("git", args, { cwd, maxBuffer: 1 << 24 })).stdout;
const json = (res, data) => { res.setHeader("content-type", "application/json"); res.end(JSON.stringify(data)); };

// Local single-user editor; no auth, 127.0.0.1 only. shortcut: no path sandbox, add one if the port is ever exposed
createServer(async (req, res) => {
  const url = new URL(req.url, "http://x");
  const q = resolve(url.searchParams.get("path") || ".");

  if (url.pathname === "/api/file") {
    try {
      if (req.method === "POST") {
        let body = "";
        for await (const c of req) body += c;
        await writeFile(q, body);
        res.end("ok");
      } else if ((await stat(q)).isDirectory()) {
        const list = await readdir(q, { withFileTypes: true });
        json(res, list.map(d => d.name + (d.isDirectory() ? "/" : "")));
      } else {
        res.end(await readFile(q, "utf8"));
      }
    } catch (e) {
      res.statusCode = 404;
      res.end(e.message);
    }
    return;
  }

  // Repo state for the file being edited: branch + changed files.
  if (url.pathname === "/api/git") {
    try {
      const dir = (await stat(q)).isDirectory() ? q : dirname(q);
      const root = (await git(["rev-parse", "--show-toplevel"], dir)).trim();
      const branch = (await git(["rev-parse", "--abbrev-ref", "HEAD"], root)).trim();
      const out = await git(["status", "--porcelain=v1", "--untracked-files=all"], root);
      const files = out.split("\n").filter(Boolean).map(l => ({
        code: l.slice(0, 2).trim(),
        path: l.slice(3).split(" -> ").pop(),
      }));
      json(res, { root, branch, files });
    } catch {
      json(res, { repo: false });
    }
    return;
  }

  // Added / deleted line numbers of the current file vs HEAD, for gutter markers.
  if (url.pathname === "/api/git/diff") {
    const added = [], removed = [];
    try {
      const root = (await git(["rev-parse", "--show-toplevel"], dirname(q))).trim();
      const out = await git(["diff", "-U0", "--no-color", "--", relative(root, q)], root);
      for (const line of out.split("\n")) {
        const m = /^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/.exec(line);
        if (!m) continue;
        const start = +m[1], count = m[2] === undefined ? 1 : +m[2];
        for (let i = 0; i < count; i++) added.push(start + i);
        if (count === 0) removed.push(Math.max(start, 1));
      }
    } catch {}
    json(res, { added, removed });
    return;
  }

  // Handoff for an already-open editor tab: Zen needs ~10s to open a new tab,
  // so the launcher just tells the open page which file to load.
  if (url.pathname === "/api/open") {
    if (req.method === "POST") {
      pending = q;
      return res.end("ok");
    }
    const p = pending;
    pending = "";
    return json(res, { path: p });
  }

  if (url.pathname === "/api/timing") {
    log("ready " + url.searchParams.get("ms") + "ms");
    return res.end("ok");
  }

  const path = url.pathname === "/" ? "/index.html" : url.pathname;
  if (path === "/index.html") log("index " + url.search);
  try {
    const buf = await readFile(join(ROOT, path));
    res.setHeader("content-type", TYPES[extname(path)] || "application/octet-stream");
    // Monaco is a few thousand static files; cache and compress them so repeat launches are instant.
    if (path.startsWith("/vs/")) {
      res.setHeader("cache-control", "public, max-age=31536000, immutable");
      if (req.headers["accept-encoding"]?.includes("gzip")) {
        if (!gzCache.has(path)) gzCache.set(path, gzipSync(buf));
        res.setHeader("content-encoding", "gzip");
        res.setHeader("vary", "accept-encoding");
        return res.end(gzCache.get(path));
      }
    } else {
      res.setHeader("cache-control", "no-store");
    }
    res.end(buf);
  } catch {
    res.statusCode = 404;
    res.end("not found");
  }
}).listen(PORT, "127.0.0.1");
