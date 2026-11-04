# Ralph Wiggum - Long-running AI Agent Loop

An automated AI agent loop that can run tasks iteratively using amp or claude.

## Setup

```bash
npm install
```

## Usage

### Run directly with tsx (development):
```bash
npm run dev [-- --tool amp|claude|opencode] [max_iterations]
# or
npm run ralph [-- --tool amp|claude|opencode] [max_iterations]
```

### Build and run:
```bash
npm run build
npm start [-- --tool amp|claude|opencode] [max_iterations]
# or
node dist/ralph.js [--tool amp|claude|opencode] [max_iterations]
```

### Examples:
```bash
# Run with amp (default) for 10 iterations (default)
npm run ralph

# Run with claude for 20 iterations
npm run ralph -- --tool claude 20

# Run with opencode for 15 iterations
npm run ralph -- --tool opencode 15

# Run with amp for 5 iterations
npm run ralph -- --tool=amp 5
```

## Options

- `--tool amp|claude|opencode` - Choose which AI tool to use (default: amp)
- `max_iterations` - Maximum number of iterations to run (default: 10)

## Tool-specific Prompt Files

- **amp**: Uses `prompt.md`
- **claude**: Uses `CLAUDE.md`
- **opencode**: Uses `prompt.md`

## Legacy Bash Script

The original bash script `ralph.sh` is still available and can be used:
```bash
./ralph.sh [--tool amp|claude] [max_iterations]
```
