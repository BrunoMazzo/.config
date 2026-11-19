#!/usr/bin/env python3
"""
OpenCode `/new` -> fresh git worktree -> new Herdr tab running opencode.

Invoked by `~/.config/opencode/commands/new.md`, a custom command that replaces
OpenCode's built-in `/new` (custom commands may replace built-in ones).

IMPORTANT: print nothing on stdout on success. OpenCode inserts a command's
shell-block output into the prompt it submits, so silence == no stray message.
Errors are printed to stdout on purpose so they are visible in the composer.

Set HERDR_NEW_SESSION_DRY_RUN=1 to print the plan without changing anything.
"""

import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from shutil import which

HOME = Path.home()
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", str(HOME / ".config")))
APP_HOME = Path(os.environ.get("HERDR_APP_HOME", str(CONFIG / "herdr-app")))
DRY_RUN = os.environ.get("HERDR_NEW_SESSION_DRY_RUN") == "1"

HERDR_APP = which("herdr-app") or str(HOME / ".local/bin/herdr-app")
HC = which("hc") or str(HOME / ".local/bin/hc")


def run(argv):
    return subprocess.run(argv, capture_output=True, text=True)


def die(message):
    # stdout, not stderr: this text is what the user sees in OpenCode's composer.
    print(f"herdr-new-session: {message}")
    sys.exit(1)


def git(cwd, *args):
    return run(["git", "-C", str(cwd), *args])


def slug(value):
    """Herdr's worktree folder convention: safe characters only, no leading/trailing dashes."""
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip()).strip("-")
    return cleaned or "session"


def worktrees_root():
    try:
        settings = json.loads((APP_HOME / "settings.json").read_text())
        directory = ((settings.get("worktrees") or {}).get("directory") or "").strip()
        if directory:
            return Path(os.path.expanduser(directory))
    except (OSError, ValueError):
        pass
    return HOME / ".herdr" / "worktrees"


def main(requested_name):
    # --- Are we inside the Herdr app? -------------------------------------
    for exe in (HERDR_APP, HC):
        if not (os.path.isfile(exe) and os.access(exe, os.X_OK)):
            die(f"{exe} not found or not executable (OpenCode is not running inside Herdr)")

    # --- Which Herdr terminal / space / folder is this OpenCode in? -------
    # HC_TERMINAL_ID is set in every Herdr terminal, so it is exact. If the
    # command's shell block runs without that env (e.g. in the background
    # service), fall back to the window's focused terminal.
    # A custom command's shell block runs in OpenCode's *background service*,
    # whose environment is frozen at service start: HC_TERMINAL_ID there can
    # point at a completely different Herdr pane. The one reliable fact is the
    # shell's working directory (the session's project location), so resolve
    # the Herdr terminal by cwd first and only use the env / window focus to
    # break ties when several panes share that directory.
    cwd_hint = os.getcwd()
    listing = run([HC, "ls"])
    live = []
    if listing.returncode == 0:
        try:
            live = json.loads(listing.stdout).get("terminals") or []
        except ValueError:
            pass

    matches = [
        t.get("address") for t in live
        if t.get("state") == "live" and t.get("cwd") == cwd_hint
    ]
    env_id = os.environ.get("HC_TERMINAL_ID") or ""
    focus_id = ""
    if len(matches) != 1:
        status = run([HERDR_APP, "status"])
        if status.returncode == 0:
            try:
                focus_id = json.loads(status.stdout).get("agent") or ""
            except ValueError:
                pass

    terminal = ""
    if len(matches) == 1:
        terminal = matches[0] or ""
    elif len(matches) > 1:
        terminal = env_id if env_id in matches else (focus_id if focus_id in matches else "")
    elif env_id:
        terminal = env_id
    elif focus_id:
        terminal = focus_id
    if not terminal:
        die(f"cannot find the Herdr terminal for {cwd_hint} (no live pane in this folder)")

    info_result = run([HC, "get", terminal])
    if info_result.returncode != 0:
        die(f"hc get {terminal} failed: {info_result.stderr.strip() or info_result.stdout.strip()}")
    try:
        info = json.loads(info_result.stdout)
    except ValueError:
        die(f"hc get {terminal} did not return JSON")

    labels = info.get("labels") or {}
    space = labels.get("herdr.space")
    cwd = (info.get("foreground") or {}).get("cwd") or info.get("cwd")
    if not space:
        die(f"terminal {terminal} is not labelled with herdr.space")
    if not cwd or not Path(cwd).is_dir():
        die(f"terminal {terminal} has no usable working directory")

    # --- Find the repository and pick a free branch / checkout -----------
    common = git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir")
    head = git(cwd, "rev-parse", "HEAD")
    if common.returncode != 0 or head.returncode != 0:
        die(f"{cwd} is not inside a git repository")
    common_dir = common.stdout.strip()
    main_checkout = common_dir[:-5] if common_dir.endswith("/.git") else common_dir
    repo_name = Path(main_checkout).name
    base_sha = head.stdout.strip()

    base = slug(requested_name) if requested_name.strip() else "oc-" + datetime.now().strftime("%Y%m%d-%H%M%S")
    root = worktrees_root()
    number = 1
    while True:
        branch = base if number == 1 else f"{base}-{number}"
        path = root / repo_name / slug(branch)
        branch_taken = git(main_checkout, "branch", "--list", branch).stdout.strip()
        if not path.exists() and not branch_taken:
            break
        number += 1

    plan = {
        "terminal": terminal,
        "space": space,
        "cwd": cwd,
        "repo": main_checkout,
        "base": base_sha,
        "branch": branch,
        "path": str(path),
        "tab.name": branch,
    }
    if DRY_RUN:
        print(json.dumps(plan, indent=2))
        print(f"would run: {HERDR_APP} do tab.new --space {space} --folder {path} "
              f"--argv '[\"opencode\"]' --name {branch} --focus true")
        return

    # --- Create the worktree ---------------------------------------------
    path.parent.mkdir(parents=True, exist_ok=True)
    added = git(main_checkout, "worktree", "add", "-b", branch, str(path), base_sha)
    if added.returncode != 0:
        die(f"git worktree add failed: {added.stderr.strip() or added.stdout.strip()}")

    # --- Open it as a new tab in the same Herdr space ---------------------
    tab = run([
        HERDR_APP, "do", "tab.new",
        "--space", space,
        "--folder", str(path),
        "--argv", json.dumps(["opencode"]),
        "--name", branch,
        "--focus", "true",
    ])
    if tab.returncode != 0:
        # Roll back so a failed tab never leaves an orphan checkout behind.
        git(main_checkout, "worktree", "remove", "--force", str(path))
        git(main_checkout, "branch", "-D", branch)
        die(f"herdr-app tab.new failed: {tab.stdout.strip() or tab.stderr.strip()}")

    # Success: no stdout. The new tab owns a brand-new opencode session in the
    # fresh worktree; OpenCode's shared background service keeps both sessions.


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "")
