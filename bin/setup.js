#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const PKG_ROOT = path.join(__dirname, '..');
const DEST = process.cwd();

const G = '\x1b[32m';
const Y = '\x1b[33m';
const R = '\x1b[0m';

function copyRecursive(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const d = path.join(dest, entry.name);
    entry.isDirectory() ? copyRecursive(s, d) : fs.copyFileSync(s, d);
  }
}

// 1. Copy wiki/
const wikiDest = path.join(DEST, 'wiki');
if (fs.existsSync(wikiDest)) {
  console.log(`· wiki/ already exists — skipping (delete to reinstall)`);
} else {
  copyRecursive(path.join(PKG_ROOT, 'wiki'), wikiDest);
  console.log(`${G}✓${R} Created wiki/`);
}

// 2. Handle CLAUDE.md — append if exists, create if not
const WIKI_BLOCK = `
# Wiki

This project uses an LLM wiki at \`./wiki/\` as its living context layer.

**On session start:** read \`wiki/_snapshot.md\` first (fast bootstrap), then
\`wiki/_active/now.md\` and recent entries from \`wiki/log.md\`. If unfamiliar with the
wiki conventions, also read \`wiki/HOWTO.md\`. Drill into other pages only as needed.

**While working:** update the wiki immediately when anything significant happens — do not batch updates for later. Triggers: a decision is made, a preference is stated, a pitfall is found, a task changes, a discovery occurs. Write the \`wiki/log.md\` entry at the moment it happens, not at session end. Use supersession, not deletion, for contradictions.

**On session end:** rewrite \`wiki/_snapshot.md\` to reflect current state if anything changed. Run \`/wiki-lint\` only when the user asks for it.

**Slash commands**: \`/wiki-update\` — write a wiki entry; \`/wiki-lint\` — run the lint
checklist; \`/wiki-snapshot\` — refresh the snapshot mid-session. The SessionStart hook
in \`.claude/settings.json\` auto-bootstraps context at the start of each session.

**If you are a subagent** (spawned via API, orchestration tool, or CI — not an
interactive CC session): hooks will not fire. Treat these instructions as your hooks.
Read \`wiki/_snapshot.md\` at the start of your first response. Write updates to the wiki
before your final response. Append a \`log.md\` entry for any wiki change made.
`;

const claudePath = path.join(DEST, 'CLAUDE.md');
if (fs.existsSync(claudePath)) {
  const existing = fs.readFileSync(claudePath, 'utf8');
  if (existing.includes('wiki/_snapshot.md')) {
    console.log(`· CLAUDE.md already has wiki instructions — skipping`);
  } else {
    fs.appendFileSync(claudePath, '\n---\n' + WIKI_BLOCK);
    console.log(`${G}✓${R} Appended wiki instructions to CLAUDE.md`);
  }
} else {
  fs.writeFileSync(claudePath, WIKI_BLOCK.trimStart());
  console.log(`${G}✓${R} Created CLAUDE.md`);
}

// 3. Optional provider files — copy only if absent
for (const file of ['AGENTS.md', 'GEMINI.md', '.cursorrules']) {
  const dest = path.join(DEST, file);
  const src = path.join(PKG_ROOT, file);
  if (fs.existsSync(src) && !fs.existsSync(dest)) {
    fs.copyFileSync(src, dest);
    console.log(`${G}✓${R} Created ${file}`);
  } else if (fs.existsSync(dest)) {
    console.log(`· ${file} already exists — skipping`);
  }
}

console.log('');
console.log('Done. Next steps:');
console.log('  1. Fill in wiki/_snapshot.md with your project state');
console.log('  2. Start a Claude Code session — wiki bootstraps automatically');
console.log('');
console.log(`${Y}Tip:${R} install the CC plugin for slash commands (/wiki-lint, /wiki-update, /wiki-snapshot):`);
console.log('  /plugin marketplace add Alekra1/llm-wiki');
console.log('  /plugin install wiki@llm-wiki');
console.log('');
console.log(`Re-run anytime: npx @alekra1/llm-wiki`);
