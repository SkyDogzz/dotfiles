# stowctl

ncurses TUI for managing the Stow packages in this repo.

## Build

```bash
make
```

## Run

```bash
./stowctl
```

Optional flags:

- `--repo PATH`
- `--target PATH`
- `--ignore a,b,c`

## Keys

- `j` / `k` or arrows: move
- `space`: toggle selection
- `a`: select all
- `c`: clear selection
- `s`: stow mode
- `r`: restow mode
- `u`: unstow mode
- `Enter` or `p`: dry-run preview
- `x`: apply the last preview
- `R`: refresh status
- `q`: quit
