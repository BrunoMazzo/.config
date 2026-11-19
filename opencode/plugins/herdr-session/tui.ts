import { Plugin } from "@opencode/plugin/tui"
import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)

/**
 * Take over OpenCode's `session.new` (the `/new` slash command, the New session
 * palette entry and `<leader>n`) when OpenCode is running inside Herdr.
 *
 * A TUI plugin runs in the terminal process itself, so it has the pane's real
 * HC_TERMINAL_ID, and a command `run` callback submits no prompt -- unlike a
 * custom `commands/*.md` command, whose empty shell block still enqueues an
 * empty user message.
 */
export default Plugin.define({
  id: "herdr.session",
  setup(context) {
    context.keymap.layer(() => ({
      mode: "global",
      // Higher than the built-in layer so our `session.new` wins by id.
      priority: 10,
      commands: [
        {
          id: "session.new",
          title: "New session (Herdr worktree + tab)",
          group: "Session",
          palette: true,
          slash: { name: "new", aliases: ["herdr", "wt"], arguments: true },
          suggested: true,
          // Outside Herdr, let OpenCode's built-in new session show through.
          enabled: () => Boolean(process.env.HC_TERMINAL_ID || process.env.HERDR_APP_HOME),
          run: async (input) => {
            const configHome = process.env.XDG_CONFIG_HOME ?? `${process.env.HOME}/.config`
            const script = `${configHome}/opencode/scripts/herdr-new-session.py`
            try {
              const { stdout } = await execFileAsync("python3", [script, input ?? ""], {
                timeout: 30_000,
                env: process.env,
              })
              const output = stdout.trim()
              if (output) {
                // The helper only writes to stdout when it fails.
                context.ui.toast.show({ title: "Herdr", message: output, variant: "error" })
              } else {
                context.ui.toast.show({
                  title: "Herdr",
                  message: "New session opened in a fresh worktree",
                  variant: "success",
                })
              }
            } catch (error) {
              context.ui.toast.show({
                title: "Herdr",
                message: error instanceof Error ? error.message : String(error),
                variant: "error",
              })
            }
          },
        },
      ],
      bindings: ["session.new"],
    }))
  },
})
