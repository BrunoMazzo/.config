# kanban.nvim (local)

A dependency-free Neovim board for the local, file-based ticket system:

```
<repo>/.scratch/<effort>/issues/NN-slug.md
```

Each ticket's `Status:` line decides its column. The board reads the folder,
normalises the messy real-world status strings, and lays the cards out in
columns. It never invents a second source of truth — moving a card rewrites the
`Status:` line in the markdown file itself.

The board opens as a **full-screen tab**: one vertical window per column, each
with a persistent `winbar` header showing the column name and card count. Every
column is its own buffer, so titles are written out **in full** and wrapped by
Neovim (`wrap` + `linebreak` + `breakindent`) — nothing is ever truncated.

## Open it

- `<leader>k` — toggle the board (focuses the board tab if it's already open)
- `:Kanban` — open, auto-detecting `.scratch` by walking up from the cwd
- `:Kanban /path/to/.scratch` — point it at a specific root
- `let g:kanban_root = '/path/to/.scratch'` — permanent override

`setup({ fallback_root = ... })` in `lua/plugins/kanban.lua` is used when no
`.scratch` is found near the cwd (e.g. nvim opened in the dotfiles repo).

## Keys (inside the board)

| Key | Action |
| --- | --- |
| `j` / `k` | jump to the next / previous **card** in the current column (not the next line; a count works, e.g. `3j`) |
| `gj` / `gk` | move by screen line inside a wrapped title |
| `h` / `l` | jump to the previous / next column window |
| `<` / `>` | move the card under the cursor to the neighbouring column |
| `<leader>1` .. `5` | move the card straight to that column (bare digits stay free for counts like `3j`) |
| `<CR>` | open the ticket file for editing (board tab closes) |
| `o` / `O` | open in a vertical / horizontal split |
| `f` | filter the board to one effort |
| `a` | clear the effort filter |
| `r` | re-scan the files (picks up external edits) |
| `q` / `<Esc>` | close the board tab |
| `?` | show this help |

Opening a card uses `:edit`/`:split`, so it is a normal markdown buffer — all
your LSP, treesitter, completion, snacks, opencode.nvim, etc. work on it.
`<leader>k` brings the board back afterwards.

## Columns

| Column | Written `Status:` value | Matched raw values |
| --- | --- | --- |
| Open / Backlog | `open` | `open`, `pending`, `needs-triage`, `needs-info`, `captured`, unknown |
| Ready | `ready-for-agent` | `ready-for-agent`, `ready-for-human`, `ready*` |
| In Progress | `claimed` | `claimed`, `in-progress`, `wip`, `doing` |
| Done | `resolved` | `resolved`, `done`, `complete`, `**complete ...**` |
| Closed | `closed` | `closed ...`, `abandoned`, `**abandoned ...**`, `wontfix`, `folded-into-*` |

Edit `columns` in `setup()` to change the lanes or the values written back:

```lua
kanban.setup({
  columns = {
    { id = "open",     title = "Backlog",  status = "open",     fg = "#89b4fa" },
    { id = "claimed",  title = "Doing",    status = "claimed",  fg = "#fab387" },
    { id = "resolved", title = "Shipped",  status = "resolved", fg = "#a6e3a1" },
  },
})
```

`id` must stay one of `open`, `ready`, `claimed`, `resolved`, `closed` — those
are the keys the status normaliser returns.

## Notes

- Only `*/issues/*.md` files are treated as cards; `map.md`, `spec.md` and
  `research/` notes are deliberately left out.
- `write_status` refuses to overwrite a ticket that is open with unsaved
  changes, and reloads any open unmodified buffers after a write.
- Closing the board tab returns you to the tab you opened it from.
