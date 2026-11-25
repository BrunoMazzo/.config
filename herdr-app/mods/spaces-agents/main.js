// Workspace spaces and their agents in one list: each space is a header with its
// colored avatar, worktrees under their checkout, and the space's agents on the
// lines below it. After a space's name, the repo its first terminal is in now,
// only where unusual: branch, ahead/behind. Click a space to switch, an agent to
// focus it; right-click a space for its menu, drag to reorder.

import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, machines, panes, agents, terminals, setAgentOrder, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, layout } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// Where a space is now: its first terminal's live folder, else where it was made.
// `ps`: panes(), read once by the caller (each read copies every pane).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}
const RAIL_CELL = 32;
// An agent's title wraps onto up to three lines before the rest is trimmed.
const TITLE_LINE = 16; // px, one line of an agent title
const TITLE_LINES = 3;
const railCell = (el) => h_flex().flex_none().justify_center().child(el);
const where = (s, ps) => JSON.stringify([s.machine ?? null, place(s, ps)]);
const base = (path) => path.replace(/\/+$/, "").split("/").pop();
const safeId = (s) => String(s).replace(/[^A-Za-z0-9_-]+/g, "-");
// Changes made outside Herdr (an editor's save, a commit in another app): looked
// for this often, in repos the list shows, while the window is in front.
const FALLBACK = 60000;

// What a stored color name looks like on an avatar (the same in every mod
// that draws space avatars): one strong color per hue, light and dark alike.
const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };

// A space speaks up only when something in it needs you.
export function glyph(status) {
  return status === "blocked" || status === "done" ? "●" : "·";
}

export function tone(t, status) {
  return t[status] ?? t.unknown;
}

// A sub-agent without a pane isn't in agents(): its raw word, error counting as
// blocked. It's never done: it reports to its parent, and the parent's done is the news.
const kidStatus = (k, listed) => {
  const s = listed.get(k.address) ?? k.status;
  return s === "error" ? "blocked" : s === "done" ? "idle" : s;
};

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

// What the agent itself calls the session: OpenCode's terminal title is
// "OC | <session>", Claude's "Claude | <session>", and so on. Strip the
// harness's short prefix so the line reads as the work, not the program.
function sessionTitle(a) {
  const raw = clean(a.title);
  if (!raw) return null;
  const names = [a.app, a.program?.name, a.app === "opencode" ? "OC" : null]
    .filter((p) => typeof p === "string" && p.length > 0)
    .sort((x, y) => y.length - x.length);
  for (const name of names) {
    const re = new RegExp(`^${escapeRe(name)}\\s*[|·:—–-]\\s*`, "i");
    if (re.test(raw)) return raw.replace(re, "").trim() || null;
  }
  return raw;
}

// The agent line: its session name when the program set one, else the program.
// Terminal titles that are only a folder or a login shell say nothing useful.
function agentTitle(a) {
  const live = clean(a.title);
  const path = /^[~/]|^[A-Za-z]:\\/.test((a.title ?? "").replace(/^[^\p{L}\p{N}~/]+/u, ""));
  const telling = live && live !== a.program?.name && !path && !live.includes("@") && live.toLowerCase() !== a.program?.key;
  return telling ? (sessionTitle(a) ?? a.title) : (a.program?.name ?? a.address);
}

// The agent's icon from the app's program table: a one-color glyph or a picture.
function programIcon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

export default class Spaces extends View {
  init(_props, cx) {
    this.git = {}; // where() -> { name, branch, ahead, behind, repo, linked }, null: not a repo
    this.checked = {}; // where() -> when it was last looked at
    this.unsure = new Set(); // where()s git couldn't answer for (a machine away)
    this.pending = new Set(); // where()s to look at next
    this.busy = {}; // pane -> an agent working or a program in front of its shell
    this.ready = {}; // machine -> its layout was readable at the last look
    this.at = {}; // space -> its where() at the last look
    this.watching = new Set(); // local repos' git folders
    // Spaces made while this runs wait (at most a moment) for their git, so a
    // worktree appears under its repo instead of jumping there.
    this.shown = new Set(spaces().map((s) => s.id));
    this.born = {};
    this.pressed = null;
    this.over = null;
    this.machines = [];
    this.reconnecting = JSON.parse(localStorage.getItem("machines.reconnecting") ?? "{}");
    for (const state of Object.values(this.reconnecting)) state.busy = false;
    this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]"));
    this.foldedProjects = new Set(JSON.parse(localStorage.getItem("projects.folded") ?? "[]"));
    this.agentFolded = new Set(); // agent addresses whose sub-agents are folded away
    this.pinnedSpaces = new Set(JSON.parse(localStorage.getItem("spaces.pinned") ?? "[]")); // first in their project
    this.hoveredSpace = null; // space id under the pointer, for the pin control
    this.bySpace = new Map(); // space id -> its agents, in display order
    this.projectBySpace = new Map(); // space id -> its project key
    this.terms = []; // terminals(), read once per render
    this.listed = new Map(); // agent address -> its status
    this.refreshMachines(cx);
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // Refresh only when the refs could have changed (see `due`).
    cx.timer.every(250, (cx) => this.checkNew(cx));
  }

  checkNew(cx) {
    const now = Date.now();
    const sp = spaces();
    for (const s of sp) if (!this.shown.has(s.id)) this.born[s.id] ??= now;
    const due = this.due(now, sp, panes());
    if (due.size) this.refreshGit(due, cx);
    if (sp.some((s) => !this.shown.has(s.id))) cx.notify();
  }

  // Places whose git could have changed: new ones (a new space, a cd), where a
  // command or an agent's turn just ended (a checkout, a commit, edits), those on
  // a machine that is back, and repos in view whose fallback is due.
  due(now, sp, ps) {
    // Moved there: what it knew of that place may be old.
    const at = {};
    for (const s of sp) at[s.id] = where(s, ps);
    const keys = new Set(Object.values(at).filter((k) => JSON.parse(k)[1]));
    const due = new Set([...keys].filter((k) => !(k in this.git)));
    for (const [id, k] of Object.entries(at)) if (this.at[id] && this.at[id] !== k && keys.has(k)) due.add(k);
    this.at = at;
    const spaceOf = {};
    for (const s of sp) for (const t of s.tabs ?? []) spaceOf[t.id] = s;
    const busy = {};
    for (const p of ps) {
      if (!p.terminal || !spaceOf[p.tab]) continue;
      busy[p.pane] = p.status === "working" || !(p.program?.shell || p.program?.agent);
      if (this.busy[p.pane] && !busy[p.pane]) this.sameRepo(at[spaceOf[p.tab].id], keys).forEach((k) => due.add(k));
    }
    this.busy = busy;
    for (const m of machines()) {
      const ready = m.layout === "ready";
      if (ready && this.ready[m.name] === false) for (const k of keys) if (JSON.parse(k)[0] === m.name) due.add(k);
      this.ready[m.name] = ready;
    }
    if (window().active) {
      for (const k of keys) {
        const asks = this.git[k] || this.unsure.has(k);
        if (asks && !this.folded.has(JSON.parse(k)[0]) && now - (this.checked[k] ?? 0) > FALLBACK) due.add(k);
      }
    }
    return due;
  }

  // `key` and the other places in its repo (a commit there moves their ahead/behind).
  sameRepo(key, keys) {
    const repo = this.git[key]?.repo;
    return [key, ...(repo ? [...keys].filter((k) => this.git[k]?.repo === repo) : [])];
  }

  refreshMachines(cx) {
    cx.spawn(async cx => {
      try { const r = await hc(["machine", "ls", "--json"]); if (r.code === 0) this.machines = (JSON.parse(r.stdout).machines ?? []).filter((m) => !m.temporary); } catch {}
      cx.notify();
    });
  }

  rebuilt(machine) {
    return machine?.state === "unreachable" && /^a different core answers there \("[^"]+"\)$/.test(machine.why ?? "");
  }

  reconnect(machine, cx) {
    const name = machine.name;
    if (this.reconnecting[name]?.busy) return;
    const state = this.reconnecting[name] ??= { machine, removed: false };
    state.busy = true;
    state.error = null;
    localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
    cx.notify();
    cx.spawn(async cx => {
      try {
        const ask = async args => {
          const r = await hc([...args, "--json"]);
          if (r.code !== 0) {
            let error;
            try { error = JSON.parse(r.stdout || r.stderr).error?.message; } catch {}
            throw new Error(error || r.stderr || r.stdout || "Couldn't connect.");
          }
        };
        if (!state.removed) {
          await ask(["machine", "rm", name]);
          state.removed = true;
          localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
        }
        const args = ["machine", "add"];
        if (machine.via) args.push("--via", machine.target);
        else args.push(machine.target);
        args.push("--name", name);
        if (machine.session) args.push("--session", machine.session);
        if (machine.temporary) args.push("--temp");
        await ask(args);
        this.folded.delete(name);
        localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
        delete this.reconnecting[name];
      } catch (e) {
        state.error = String(e.message ?? e);
        state.busy = false;
      }
      localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
      this.refreshMachines(cx);
      cx.notify();
    });
  }

  // One look at a time, each place once however often it was asked for meanwhile.
  refreshGit(keys, cx) {
    for (const k of keys) this.pending.add(k);
    if (this.refreshing) return;
    this.refreshing = true;
    cx.spawn(async (cx) => {
      while (this.pending.size) {
        const keys = [...this.pending];
        this.pending.clear();
        await Promise.all(keys.map((key) => this.check(key, cx)));
      }
      const used = new Set(Object.values(this.git).filter(Boolean).map((g) => JSON.parse(g.repo)).filter(([on]) => !on).map(([, repo]) => repo));
      for (const repo of this.watching) if (!used.has(repo)) this.watching.delete(repo);
      this.refreshing = false;
      cx.notify();
    });
  }

  // One place's git: branch, ahead/behind, its repo.
  async check(key, cx) {
    const [on, cwd] = JSON.parse(key);
    this.checked[key] = Date.now();
    this.unsure.delete(key);
    try {
      // Ref-only reads avoid scanning the worktree or waking its index watch.
      // Two reads: a folder name may itself contain a newline.
      const [r, common] = await Promise.all([
        exec("git", ["rev-parse", "--path-format=absolute", "--show-toplevel"], { cwd, on }),
        exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd, on }),
      ]);
      if (r.code !== 0 || common.code !== 0) {
        // Only git's own "no" is remembered as no repo; anything else is asked again.
        if (!/not a git repository/i.test(r.code !== 0 ? r.stderr : common.stderr)) this.unsure.add(key);
        this.git[key] = null;
        return;
      }
      // The repo's own .git folder names it; a worktree's top differs from it.
      const top = r.stdout.replace(/\n$/, ""), repo = common.stdout.replace(/\n$/, "");
      const [branch, counts] = await Promise.all([
        exec("git", ["symbolic-ref", "-q", "HEAD"], { cwd, on }),
        exec("git", ["rev-list", "--left-right", "--count", "HEAD...@{upstream}"], { cwd, on }),
      ]);
      const name = repo.endsWith("/.git") ? base(repo.slice(0, -5)) : base(repo).replace(/\.git$/, "");
      const [ahead, behind] = counts.code === 0 ? counts.stdout.trim().split(/\s+/).map(Number) : [0, 0];
      const info = { name, root: top, branch: branch.code === 0 ? branch.stdout.trim().replace(/^refs\/heads\//, "") : "(detached)", ahead, behind, repo: JSON.stringify([on, repo]), linked: repo !== `${top}/.git` };
      this.git[key] = info;
      if (!on) this.watch(repo, cx);
    } catch {
      // Couldn't ask (the machine is away): keep what it showed, look again later.
      this.git[key] ??= null;
      this.unsure.add(key);
    }
  }

  watch(repo, cx) {
    if (this.watching.has(repo)) return;
    this.watching.add(repo);
    cx.spawn(async (cx) => {
      try {
        while (this.watching.has(repo)) {
          await watchFolder(repo);
          const mine = JSON.stringify([null, repo]);
          if (this.watching.has(repo)) this.refreshGit(Object.keys(this.git).filter((k) => this.git[k]?.repo === mine), cx);
        }
      } catch { this.watching.delete(repo); }
    });
  }

  menu(w) {
    // A popup is as tall as its items; height is only the most.
    openOverlay({ mod: "space-menu", kind: "popup", width: 220, height: 280, props: { tab: "space", target: { id: w.id } } });
  }

  // A space's project: its git repo when there is one, else its folder.
  projectOf(w, g) {
    if (g) {
      // The project's own checkout, even when only a worktree is open.
      const common = JSON.parse(g.repo)[1];
      return { key: g.repo, name: g.name, root: common.replace(/[\\/]\.git$/, ""), git: true };
    }
    const folder = (w.folder ?? "").replace(/\/+$/, "");
    return { key: `folder:${w.machine ?? ""}:${folder || w.id}`, name: base(folder) || w.name || w.id, root: folder || null, git: false };
  }

  // Spaces grouped by project, a project appearing where its first space does.
  projects(rows) {
    const out = [];
    const by = new Map();
    for (const r of rows) {
      const p = this.projectOf(r.w, r.g);
      r.project = p.key;
      this.projectBySpace.set(r.w.id, p.key);
      let group = by.get(p.key);
      if (!group) {
        group = { ...p, rows: [], main: null, machine: r.w.machine ?? null };
        by.set(p.key, group);
        out.push(group);
      }
      group.rows.push(r);
      if (r.g && !r.g.linked) group.main ??= r;
    }
    // Pinned workspaces lead their project; the rest keep their order.
    for (const group of out) group.rows.sort((x, y) => (this.pinnedSpaces.has(y.w.id) ? 1 : 0) - (this.pinnedSpaces.has(x.w.id) ? 1 : 0));
    return out;
  }

  // Spaces in order, waiting briefly for a new space's git so it lands in its
  // project instead of flashing as its own.
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    return sp.filter((w) => this.shown.has(w.id)).map((w, i) => ({ w, i, g: this.git[where(w, ps)] ?? null }));
  }

  // The rows, under a header per machine once one isn't this computer.
  grouped(t, collapsed) {
    const rows = this.ordered();
    const projects = this.projects(rows);
    // agent.next / agent.prev follow what the sidebar shows, top to bottom.
    setAgentOrder(projects.flatMap((p) => p.rows).flatMap((r) => this.agentsIn(r.w.id).map((a) => a.address)));
    const drawProjects = (list) => list.flatMap((p, i) => [
      ...this.projectEls(p, t, collapsed),
      ...(!collapsed && i < list.length - 1 ? [this.projectSeparator(t)] : []),
    ]);
    const remote = [...new Set([...rows.map(r => r.w.machine).filter(Boolean), ...this.machines.map(m => m.name), ...Object.keys(this.reconnecting)])].sort();
    const loading = m => {
      const layout = machines().find(k => k.name === m)?.layout;
      return layout === "loading" || (!layout && this.machines.some(k => k.name === m && k.state === "connected"))
        || spaces().some(s => (s.machine ?? null) === m && !this.shown.has(s.id));
    };
    const loadingRow = m => h_flex().id(`machine-loading-${m ?? "local"}`).h(28).flex_none().px(collapsed ? 0 : 8).items_center().when(collapsed, el => el.justify_center()).text_size(12).text_color(t.dim).child(collapsed ? "…" : "Loading…");
    if (!remote.length) return loading(null) && !rows.length ? [loadingRow(null)] : drawProjects(projects);
    const machineNames = [null, ...remote];
    return machineNames.flatMap((m) => {
      const mine = rows.filter((r) => (r.w.machine ?? null) === m);
      const repair = this.reconnecting[m];
      const machine = this.machines.find(k => k.name === m) ?? repair?.machine;
      const connected = !m || machine?.state === "connected";
      const rebuilt = this.rebuilt(machine) || !!repair;
      const login = machine?.state === "needs_login" ? `hc machine login ${m}` : null;
      const folded = this.folded.has(m);
      const icon = svg(`mods/workspace-chrome/${m ? "server" : "monitor"}.svg`).size(13).flex_none();
      const badge = div().absolute().right(-3).bottom(-2).size(6).rounded(3).border_1().border_color(t.chrome).bg(connected ? t.ansi2 : t.dim);
      const head = h_flex().id(`machine-${m ?? "local"}`).h(26).flex_none().px(collapsed ? 0 : 8).gap(7).items_center().text_size(11).text_color(t.dim)
        .when(collapsed, el => el.mt(4).w(RAIL_CELL).justify_center().rounded(6).tooltip(login ? `${m} needs a login: run ${login}. Click for Copy.` : m ? `${m} · ${connected ? "connected" : (machine?.state ?? "asleep").replace(/_/g, " ")}` : "This computer"))
        .cursor_pointer().hover(s => s.bg(t.hover))
        .on_click((_e, cx) => {
          if (collapsed && login) { run("app.settings", { section: "machines" }); return; }
          folded ? this.folded.delete(m) : this.folded.add(m);
          localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
          cx.notify();
        })
        .when(!collapsed, el => el.child(icon))
        .when(collapsed, el => el.child(div().relative().flex_none().child(icon).when(Boolean(m), el => el.child(badge))))
        .when(!collapsed, el => el.child(div().flex_1().truncate().child(m ?? "This computer"))
          .when(!connected && !rebuilt && !login, el => el.child(div().flex_none().child((machine?.state ?? "asleep").replace(/_/g, " "))))
          .when(rebuilt, el => el.child(h_flex().flex_none().gap(3).items_center()
            .child(div().max_w(140).truncate().child(repair?.error || "rebuilt ·"))
            .child(div().id(`machine-connect-${m}`).text_color(repair?.error ? t.blocked : t.muted)
              .hover(s => s.text_color(t.foreground))
              .tooltip(repair?.error || "This machine was rebuilt or replaced. Click to connect to the new one.")
              .on_click((_e, cx) => { cx.stop_propagation(); this.reconnect(machine, cx); })
              .child(repair?.busy ? "Connecting…" : "Connect"))))
          .when(connected, el => el.child(div().id(`machine-add-${m ?? "local"}`).flex_none().px(4).rounded(4).hover(s => s.bg(t.hover).text_color(t.foreground))
            .on_click((_e, cx) => { cx.stop_propagation(); run("space.new", { machine: m ?? "" }); }).child("+")))
          .child(div().size(6).rounded(3).flex_none().bg(connected ? t.ansi2 : t.dim))
          .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none()));
      const empty = h_flex().id(`machine-new-${m ?? "local"}`).h(28).flex_none().px(collapsed ? 0 : 8).gap(7).items_center().rounded(7)
        .text_size(12).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_click(() => run("space.new", { machine: m ?? "" }))
        .when(collapsed, el => el.w(RAIL_CELL).rounded(6).justify_center().tooltip(`New space on ${m ?? "this computer"}`)
          .child(h_flex().size(18).rounded(5).border_1().border_color(t.dim).items_center().justify_center()
            .child(svg("mods/workspace-chrome/plus.svg").size(10))))
        .when(!collapsed, el => el.child(svg("mods/workspace-chrome/plus.svg").size(12)).child("New space there"));
      if (!collapsed && rebuilt) return [head];
      const cell = collapsed ? railCell : (el) => el;
      const guidance = !collapsed && login ? [v_flex().px(8).pb(6).gap(3).flex_none()
        .child(div().text_size(11).text_color(t.blocked).child("needs a login: run"))
        .child(h_flex().gap(5).items_center()
          .child(div().flex_1().min_w(0).truncate().tooltip(login).text_size(11).text_color(t.muted).child(login))
          .child(div().id(`machine-login-copy-${m}`).flex_none().px(5).py(2).rounded(4)
            .text_size(11).text_color(t.foreground).bg(t.raised).cursor_pointer().hover(s => s.bg(t.hover))
            .on_click((_e, cx) => { cx.stop_propagation(); cx.write_to_clipboard(login); this.copiedLogin = login; cx.notify(); })
            .child(this.copiedLogin === login ? "Copied" : "Copy")))] : [];
      const mineProjects = this.projects(mine);
      return [cell(head), ...guidance, ...(folded ? [] : mine.length ? drawProjects(mineProjects) : [loading(m) ? loadingRow(m) : cell(empty)])];
    });
  }

  // A project's header, then its workspaces and their agents. A project whose
  // main checkout isn't open yet gets a default cell that opens it.
  projectEls(p, t, collapsed) {
    if (collapsed) return p.rows.map((r) => this.compact(r, t));
    const open = !this.foldedProjects.has(p.key);
    const out = [];
    if (p.git || p.rows.length > 1) out.push(this.projectHeader(p, t));
    if (!open) return out;
    for (const r of p.rows) out.push(this.group(r, t));
    if (p.git && !p.main) out.push(this.defaultWorkspace(p, t));
    return out;
  }

  projectHeader(p, t) {
    const open = !this.foldedProjects.has(p.key);
    const where = p.root ? `${p.name}\n${p.root}` : p.name;
    const count = p.rows.length;
    return v_flex()
      .w_full()
      .flex_none()
      .pt(9)
      .pb(4)
      .child(
        h_flex()
          .id(`project-${safeId(p.key)}`)
          .w_full()
          .h(30)
          .px(6)
          .gap(8)
          .items_center()
          .rounded(8)
          .cursor_pointer()
          .hover((el) => el.bg(t.hover))
          .on_click((_e, cx) => {
            open ? this.foldedProjects.add(p.key) : this.foldedProjects.delete(p.key);
            localStorage.setItem("projects.folded", JSON.stringify([...this.foldedProjects]));
            cx.notify();
          })
          .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(12).flex_none().text_color(t.dim))
          .child(div().size(22).flex_none().rounded(6).bg(t.raised).flex().items_center().justify_center()
            .child(svg("mods/workspace-chrome/folder.svg").size(13).flex_none().text_color(t.muted)))
          .child(div().flex_1().min_w(0).truncate().text_size(13).font_semibold().text_color(t.foreground).tooltip(where).child(p.name))
          .child(div()
            .flex_none()
            .h(20)
            .px(7)
            .rounded(6)
            .bg(t.raised)
            .flex()
            .items_center()
            .text_size(10.5)
            .font_medium()
            .text_color(t.dim)
            .child(count === 1 ? "1 workspace" : `${count} workspaces`)),
      );
  }

  // A clear end to a project, so the next header reads as a new section.
  projectSeparator(t) {
    return v_flex()
      .w_full()
      .flex_none()
      .pt(9)
      .pb(3)
      .child(div().w_full().h(1).bg(t.input));
  }

  // No main checkout open for this project: offer to open one.
  defaultWorkspace(p, t) {
    return h_flex()
      .id(`default-${safeId(p.key)}`)
      .w_full()
      .h(28)
      .px(8)
      .flex_none()
      .gap(7)
      .rounded(7)
      .items_center()
      .text_size(12)
      .text_color(t.dim)
      .cursor_pointer()
      .hover((el) => el.bg(t.hover).text_color(t.foreground))
      .tooltip(`Open the main checkout in a new workspace${p.root ? `\n${p.root}` : ""}`)
      .on_click(() => {
        const args = { machine: p.machine ?? "" };
        if (p.root) args.folder = p.root;
        run("space.new", args);
      })
      .child(svg("mods/workspace-chrome/folder-plus.svg").size(14).flex_none())
      .child(div().flex_1().min_w(0).truncate().child("Default workspace"))
      .child(div().flex_none().text_size(10.5).child("main checkout"));
  }

  // Branch and tracking state on its own line under a named workspace, lined up
  // with the name (past the 18px badge and its 9px gap) so it gets the full width.
  branchLine(g, t) {
    return h_flex()
      .min_w(0)
      .pl(27)
      .gap(5)
      .items_center()
      .text_size(11.5)
      .text_color(t.dim)
      .child(div().min_w(0).truncate().child(g.branch ?? "detached"))
      .when(g.ahead > 0, (el) => el.child(div().flex_none().text_color(t.ansi2).child(`↑${g.ahead}`)))
      .when(g.behind > 0, (el) => el.child(div().flex_none().text_color(t.ansi1).child(`↓${g.behind}`)));
  }

  // Pins a workspace to the top of its project (kept in this mod's storage).
  pinControl(w, pinned, t) {
    return div()
      .id(`space-pin-${w.id}`)
      .size(20)
      .flex_none()
      .flex()
      .items_center()
      .justify_center()
      .rounded(5)
      .text_color(pinned ? t.muted : t.dim)
      .cursor_pointer()
      .hover((el) => el.bg(t.hover).text_color(t.foreground))
      .tooltip(pinned ? "Unpin" : "Pin to the top")
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation()) // not a drag or a select
      .on_click((_e, cx) => {
        cx.stop_propagation();
        pinned ? this.pinnedSpaces.delete(w.id) : this.pinnedSpaces.add(w.id);
        localStorage.setItem("spaces.pinned", JSON.stringify([...this.pinnedSpaces]));
        cx.notify();
      })
      .child(svg(`mods/workspace-chrome/${pinned ? "pin-off" : "pin"}.svg`).size(12));
  }

  // Tracking state after a workspace's name (and the branch, when asked).
  branchTail(g, showBranch, t) {
    const branch = g.branch ?? "detached";
    return h_flex()
      .flex_none()
      .max_w(150)
      .min_w(0)
      .gap(5)
      .justify_end()
      .items_center()
      .text_size(11.5)
      .text_color(t.dim)
      .when(showBranch, (el) => el.child(div().min_w(0).truncate().child(branch)))
      .when(g.ahead > 0, (el) => el.child(div().flex_none().text_color(t.ansi2).child(`\u2191${g.ahead}`)))
      .when(g.behind > 0, (el) => el.child(div().flex_none().text_color(t.ansi1).child(`\u2193${g.behind}`)));
  }

  agentsIn(space) {
    return this.bySpace.get(space) ?? [];
  }

  // Live sub-agents of `addr`, depth first, each with the tree lines in front of it.
  tree(all, addr, lead = []) {
    const kids = all.filter((k) => k.parent === addr && k.state === "live");
    return kids.flatMap((k, i) => {
      const last = i === kids.length - 1;
      return [
        { t: k, lines: [...lead, last ? "└" : "├"] },
        ...this.tree(all, k.address, [...lead, last ? "" : "│"]),
      ];
    });
  }

  status(t, a, compact = false) {
    const color = t[a.status] ?? t.dim;
    if (a.status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
    if (a.status === "blocked" && compact) return div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(10.5).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!").tooltip("Needs you");
    if (a.status === "blocked") return div().flex_none().px(6).h(18).rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
    // Idle: a ring; done: a dot.
    if (a.status === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
    return div().size(7).mx(3).flex_none().rounded(4).bg(a.status === "done" ? color : t.dim + "00");
  }

  subRow(s, t) {
    const k = s.t;
    const st = kidStatus(k, this.listed);
    const pic = programIcon(k.program, 12, t.muted);
    const listed = this.listed.has(k.address);
    return h_flex()
      .id(`sub-${k.address}`)
      .h(24)
      .pl(7)
      .pr(7)
      .flex_none()
      .gap(3)
      .rounded(6)
      .items_center()
      .text_size(12)
      .hover((el) => el.bg(t.hover))
      .on_click(() => (listed ? run("pane.focus", { terminal: k.address }) : run("terminal.peek", { terminal: k.address })))
      .children(s.lines.map((l) => div().self_start().mt(-4).w(9).h(17).mr(3).flex_none()
        .when(Boolean(l), (el) => el.border_l(1.5).border_color(t.input))
        .when(l === "└" || l === "├", (el) => el.border_b(1.5).rounded_bl(6))))
      .when(Boolean(pic), (el) => el.child(div().mr(4).child(pic)))
      .child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(k.name || k.template || k.program?.name || k.address))
      .child(this.status(t, { status: st }, true));
  }

  // One agent, indented under its space. The row carries the session's own title
  // (OpenCode's is "OC | <session>") so the space header does not have to repeat it.
  // It wraps onto up to three lines, then trims; the tooltip keeps the whole title.
  agentRow(a, t) {
    const title = agentTitle(a);
    const tab = this.tabsById?.get(a.tab);
    const subs = this.tree(this.terms, a.address);
    const open = !this.agentFolded.has(a.address);
    const pic = programIcon(a.program, 14, a.focused ? t.foreground : t.muted);
    const full = [a.title, tab?.named ? tab.name : null].filter(Boolean).join(" · ");
    return h_flex()
      .id(`agent-${a.address}`)
      .min_h(27)
      .py(4)
      .px(7)
      .flex_none()
      .gap(7)
      .rounded(7)
      .items_center()
      .text_size(12.5)
      .when(a.focused, (el) => el.bg(t.selected))
      .when(!a.focused, (el) => el.hover((s) => s.bg(t.hover)))
      .cursor_pointer()
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .when(Boolean(pic), (el) => el.child(div().w(14).flex_none().child(pic)))
      .child(div().flex_1().min_w(0).line_height(`${TITLE_LINE}px`)
        .max_h(TITLE_LINE * TITLE_LINES).overflow_hidden().whitespace_normal()
        .text_color(a.focused ? t.foreground : t.muted).tooltip(full || title).child(title))
      .when(subs.length > 0, (el) => el.child(div()
        .id(`agent-fold-${a.address}`)
        .h(16)
        .px(2)
        .flex()
        .items_center()
        .rounded(4)
        .text_size(10.5)
        .text_color(t.dim)
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_click((_e, cx) => {
          cx.stop_propagation();
          open ? this.agentFolded.add(a.address) : this.agentFolded.delete(a.address);
          cx.notify();
        })
        .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(10).flex_none())
        .when(!open, (el) => el.child(String(subs.length)))))
      .child(this.status(t, a, true));
  }

  // A space and the agents that live in it: header row, then one line per agent.
  group(r, t) {
    const header = this.row(r, t);
    const list = this.agentsIn(r.w.id);
    if (!list.length) return header;
    const rows = [];
    for (const a of list) {
      rows.push(this.agentRow(a, t));
      if (!this.agentFolded.has(a.address)) for (const s of this.tree(this.terms, a.address)) rows.push(this.subRow(s, t));
    }
    return v_flex()
      .flex_none()
      .child(header)
      .child(v_flex().flex_none().ml(16).pl(10).border_l(1).border_color(t.border).children(rows));
  }

  row({ w, i, g, project }, t) {
    const on = w.active;
    const fromIndex = this.pressed === null ? -1 : spaces().findIndex(s => s.id === this.pressed);
    const colors = shared("space.colors") ?? {};
    const color = colors[w.id] ?? "ansi6";
    const fill = color.startsWith("#") ? color : (MARK[color] ?? t[color]);
    const branch = g?.branch ?? null;
    // A project header already names the repo, so an unnamed workspace reads as
    // its branch ("main", "feature/x"). A name someone gave it wins.
    const primary = w.named ? w.name : (branch || w.name);
    const showBranch = w.named && Boolean(branch);
    const linked = Boolean(g?.linked);
    const pinned = this.pinnedSpaces.has(w.id);
    const full =[w.name, branch, g?.root].filter(Boolean).join(" · ");
    return v_flex()
      .relative()
      .id(`space-${w.id}`)
      .px(8)
      .h(showBranch ? 44 : 30)
      .gap(1)
      .flex_none()
      .justify_center()
      .rounded(8)
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .when(this.pressed === w.id && this.over !== w.id, (el) => el.opacity(0.5))
      .when(this.pressed !== null && this.over === w.id && this.pressed !== w.id, (el) => el.child(
        div().absolute().left(0).right(0).h(2).bg(t.accent)
          .when(fromIndex < i, line => line.bottom(0))
          .when(fromIndex > i, line => line.top(0)),
      ))
      .on_mouse_down("left", (e, cx) => {
        // Double-click the workspace name to give it any name you like (spaces
        // and punctuation included); a drag still reorders it.
        if (e.click_count === 2) {
          cx.stop_propagation();
          this.pressed = null;
          this.over = null;
          run("space.rename", { id: w.id });
          cx.notify();
          return;
        }
        this.pressed = w.id;
        this.over = w.id;
      })
      .on_mouse_move((_e, cx) => {
        const source = spaces().find(s => s.id === this.pressed);
        const sameProject = source && this.projectBySpace.get(source.id) === project;
        const over = source && (source.machine ?? null) === (w.machine ?? null) && sameProject ? w.id : null;
        if (this.pressed !== null && this.over !== over) {
          this.over = over;
          cx.notify();
        }
      })
      .on_mouse_up("left", (_e, cx) => {
        const from = this.pressed;
        const over = this.over;
        this.pressed = null;
        this.over = null;
        if (from !== null && over === w.id && from !== w.id) {
          const index = spaces().findIndex(s => s.id === w.id);
          if (index !== -1) run("space.move", { id: from, index: index + 1 });
        } else if (from === w.id) run("space.select", { id: w.id });
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w))
      .on_hover((over, cx) => {
        const next = over ? w.id : this.hoveredSpace === w.id ? null : this.hoveredSpace;
        if (next !== this.hoveredSpace) {
          this.hoveredSpace = next;
          cx.notify();
        }
      })
      .child(
        h_flex()
          .gap(9)
          .items_center()
          .when(linked, el => el.child(h_flex().size(18).flex_none().items_center().justify_center().child(svg("mods/workspace-chrome/branch.svg").size(13).flex_none().text_color(t.muted))))
          .when(!linked, el => el.child(h_flex().size(18).flex_none().rounded(5).bg(fill).items_center().justify_center().text_size(10.5).font_bold().text_color("#ffffff").child([...w.name][0]?.toUpperCase() ?? "?")))
          .child(div().flex_1().min_w(0).truncate().font_medium().text_color(t.foreground).tooltip(full || w.name).child(primary))
          .when(Boolean(g) && !showBranch && (g.ahead > 0 || g.behind > 0), el => el.child(this.branchTail(g, false, t)))
          .when(Boolean(w.status), el => el.child(this.status(t, { status: w.status }, true)))
          .when(pinned || this.hoveredSpace === w.id, el => el.child(this.pinControl(w, pinned, t)))
          .child(div()
            .id(`space-menu-${w.id}`)
            .size(20)
            .flex_none()
            .flex()
            .items_center()
            .justify_center()
            .rounded(5)
            .text_color(t.dim)
            .cursor_pointer()
            .hover(s => s.bg(t.hover).text_color(t.foreground))
            .tooltip("Workspace actions")
            .on_click((_e, cx) => { cx.stop_propagation(); this.menu(w); })
            .child(svg("mods/spaces-agents/more.svg").size(13))),
      )
      .when(showBranch, el => el.child(this.branchLine(g, t)));
  }

  compact({ w, i }, t) {
    return railCell(h_flex()
      .id(`space-${w.id}`)
      .relative()
      .w(RAIL_CELL)
      .h(26)
      .rounded(6)
      .justify_center()
      .items_center()
      .when(w.active, (el) => el.bg(t.selected))
      .when(!w.active, (el) => el.hover((s) => s.bg(t.hover)))
      .on_click(() => run("space.select", { id: w.id }))
      .child(div().text_color(w.active ? t.foreground : t.muted).child(String(i + 1)))
      .child(div().absolute().right(5).text_color(tone(t, w.status)).child(glyph(w.status))));
  }

  render() {
    const t = theme();
    const collapsed = narrow();
    const palette = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
    const sp = spaces();
    // Read the agent and terminal lists once for the whole render.
    const allAgents = agents();
    this.terms = terminals();
    this.listed = new Map(allAgents.map((a) => [a.address, a.status]));
    this.tabsById = new Map(sp.flatMap((s) => s.tabs ?? []).map((tab) => [tab.id, tab]));
    this.bySpace = new Map();
    const spaceIds = new Set(sp.map((s) => s.id));
    for (const a of allAgents) {
      let id = a.space;
      // A remote address may carry its machine prefix; its space name still finds it.
      if (!spaceIds.has(id)) {
        const machine = a.address.includes("/") ? a.address.split("/")[0] : null;
        id = sp.find((s) => s.name === a.space_name && (s.machine ?? null) === machine)?.id ?? id;
      }
      const list = this.bySpace.get(id) ?? [];
      list.push(a);
      this.bySpace.set(id, list);
    }
    for (const list of this.bySpace.values()) list.sort((x, y) => (y.pinned ? 1 : 0) - (x.pinned ? 1 : 0));
    const ids = new Set(sp.map(p => p.id));
    // Forget pins of closed workspaces, once every machine's spaces are in.
    if (machines().every(m => m.layout === "ready") && [...this.pinnedSpaces].some(id => !ids.has(id))) {
      this.pinnedSpaces = new Set([...this.pinnedSpaces].filter(id => ids.has(id)));
      localStorage.setItem("spaces.pinned", JSON.stringify([...this.pinnedSpaces]));
    }
    const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
    let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
    for (const p of sp) {
      if (kept[p.id] || p.name === "~") continue;
      const uses = c => Object.values(kept).filter(v => v === c).length;
      kept[p.id] = palette.reduce((best, c) => uses(c) < uses(best) ? c : best);
      changed = true;
    }
    if (changed) setShared("space.colors", kept);
    return v_flex().size_full().min_h(0).bg(t.chrome).text_size(13)
      .child(h_flex().h(31).pl(16).pr(10).items_center().justify_between().text_size(11.5).text_color(t.dim)
        .when(collapsed, el => el.pl(0).pr(0).justify_center())
        .when(!collapsed, el => el.child("Projects & agents"))
        .child(div().id("space-new").size(26).flex_none().flex().items_center().justify_center().rounded(6).hover(s => s.bg(t.hover).text_color(t.foreground))
          .on_click(() => run("space.new")).child(svg("mods/workspace-chrome/plus.svg").size(14))))
      .child(v_flex().flex_1().min_h(0).px(collapsed ? 0 : 8).pb(14).overflow_y_scrollbar().mode("always")
        .on_mouse_up("left", (_e, cx) => { this.pressed = null; cx.notify(); })
        .children(this.grouped(t, collapsed)));
  }
}
