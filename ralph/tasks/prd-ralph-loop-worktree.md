# PRD: Ralph Loop with Git Worktree Integration

## Introduction

Implement a Recursive Agent Loop for Problem Handling (Ralph loop) that uses git worktrees to enable parallel development workflows. The system allows OpenCode to execute iterative problem-solving cycles in isolated worktrees, where the agent can attempt fixes, test them, and iterate until success—all without affecting the main workspace. A real-time visual dashboard provides visibility into loop status, iterations, and progress.

## Goals

- Enable recursive agent-driven problem solving in isolated git worktrees
- Execute multiple parallel Ralph loops across different worktrees simultaneously
- Provide real-time visual feedback on loop status, iterations, and results
- Integrate seamlessly with OpenCode as the execution engine
- Prevent experimental changes from affecting the main development workspace
- Support automatic cleanup and worktree management

## User Stories

### US-001: Create git worktree for Ralph loop execution
**Description:** As a developer, I want Ralph loops to run in dedicated git worktrees so that experimental fixes don't affect my main workspace.

**Acceptance Criteria:**
- [ ] Command creates new worktree in `.ralph-worktrees/[loop-id]/` directory
- [ ] Each worktree uses a unique branch name `ralph/[loop-id]`
- [ ] Worktree is based on current branch HEAD
- [ ] Worktree directory is added to `.gitignore` automatically
- [ ] Typecheck passes

### US-002: Implement core Ralph loop logic
**Description:** As a developer, I want the Ralph loop to recursively attempt problem solving until success or max iterations.

**Acceptance Criteria:**
- [ ] Loop accepts problem description and task instructions
- [ ] Executes attempt via OpenCode in worktree context
- [ ] Analyzes results (success/failure) after each iteration
- [ ] Iterates with learnings from previous attempt if failed
- [ ] Stops on success or after max iterations (default: 5)
- [ ] Returns final status and summary
- [ ] Typecheck passes

### US-003: OpenCode execution engine integration
**Description:** As a system, I need OpenCode to execute all commands and code changes within each Ralph loop worktree.

**Acceptance Criteria:**
- [ ] OpenCode agent spawned with worktree path as working directory
- [ ] Agent receives loop context (iteration number, previous results, task)
- [ ] Agent output captured and analyzed for success/failure
- [ ] Supports running tests, builds, and code modifications
- [ ] Proper error handling if OpenCode execution fails
- [ ] Typecheck passes

### US-004: Basic real-time status dashboard UI
**Description:** As a developer, I want to see real-time status of running Ralph loops so I can monitor progress without interrupting work.

**Acceptance Criteria:**
- [ ] Web-based dashboard accessible via local server (e.g., localhost:3000)
- [ ] Shows list of active Ralph loops with loop ID, status, iteration count
- [ ] Displays current iteration status (running/success/failed)
- [ ] Shows elapsed time for each loop
- [ ] Auto-refreshes every 2 seconds
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Display loop execution logs in UI
**Description:** As a developer, I want to view detailed logs of each Ralph loop iteration so I can understand what the agent is doing.

**Acceptance Criteria:**
- [ ] Clicking a loop ID shows detailed log view
- [ ] Logs grouped by iteration number
- [ ] Shows OpenCode commands executed
- [ ] Displays test/build output
- [ ] Color-coded by status (success=green, error=red, running=blue)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Worktree cleanup after loop completion
**Description:** As a developer, I want completed Ralph loop worktrees cleaned up automatically to save disk space.

**Acceptance Criteria:**
- [ ] Successful loops: worktree removed, changes optionally merged back
- [ ] Failed loops: worktree preserved for manual inspection
- [ ] Command to manually cleanup specific worktree: `ralph cleanup [loop-id]`
- [ ] Command to cleanup all completed worktrees: `ralph cleanup --all`
- [ ] Git worktree and branch both removed
- [ ] Typecheck passes

### US-007: Start Ralph loop via OpenCode slash command
**Description:** As a developer, I want to start a Ralph loop easily from OpenCode using a slash command.

**Acceptance Criteria:**
- [ ] `/ralph [task description]` command available in OpenCode
- [ ] Creates worktree and starts loop with provided task
- [ ] Returns loop ID immediately for tracking
- [ ] Provides dashboard URL for monitoring
- [ ] Works from any directory in the git repository
- [ ] Typecheck passes

### US-008: Basic loop result analysis
**Description:** As a system, I need to determine if a Ralph loop iteration succeeded or failed based on execution results.

**Acceptance Criteria:**
- [ ] Checks exit codes of executed commands (0 = success)
- [ ] Parses test output for pass/fail indicators
- [ ] Detects build failures and compilation errors
- [ ] Extracts error messages for next iteration context
- [ ] Returns structured result: status, message, artifacts
- [ ] Typecheck passes

## Functional Requirements

- FR-1: System must create isolated git worktrees in `.ralph-worktrees/[loop-id]/` for each Ralph loop
- FR-2: Each worktree must use a unique branch named `ralph/[loop-id]` based on current HEAD
- FR-3: Ralph loop must execute up to N iterations (configurable, default 5) until success
- FR-4: OpenCode must be the execution engine for all code changes and commands within worktrees
- FR-5: Loop must pass context from previous iteration failures to inform next attempt
- FR-6: System must provide real-time status dashboard at localhost:3000 showing active loops
- FR-7: Dashboard must display loop ID, current status, iteration count, and elapsed time
- FR-8: Dashboard must auto-refresh every 2 seconds without page reload
- FR-9: Clicking a loop must show detailed execution logs grouped by iteration
- FR-10: Successful loops must cleanup worktree automatically; failed loops preserved
- FR-11: OpenCode slash command `/ralph [task]` must initiate a new Ralph loop
- FR-12: System must analyze execution results (exit codes, test output) to determine success/failure
- FR-13: Multiple Ralph loops can run in parallel across different worktrees

## Non-Goals

- No automatic merging of successful changes to main branch (manual review required)
- No distributed execution across multiple machines
- No integration with external CI/CD systems in MVP
- No authentication or multi-user access to dashboard
- No historical analysis or ML-based learning from past loops
- No support for non-git repositories
- No mobile-responsive dashboard UI in MVP
- No WebSocket-based real-time updates (polling is sufficient for MVP)

## Design Considerations

### UI/UX Requirements

**Dashboard Layout:**
- Simple single-page application
- Left sidebar: List of active/recent Ralph loops
- Main area: Selected loop details and logs
- Top bar: Global actions (cleanup all, settings)

**Color Scheme:**
- Running: Blue (#3B82F6)
- Success: Green (#10B981)
- Failed: Red (#EF4444)
- Neutral: Gray (#6B7280)

**Technology Stack (Suggested):**
- Frontend: React with Vite for fast development
- Styling: Tailwind CSS for rapid UI development
- Backend: Node.js Express server for API
- State: File-based state storage (JSON) for MVP
- No database required initially

### Component Reuse
- Use existing OpenCode agent spawning mechanisms
- Leverage OpenCode's task execution and output capture
- Reuse git command utilities if available in codebase

## Technical Considerations

### Git Worktree Management
- Worktrees created in `.ralph-worktrees/` subdirectory of repository root
- Each worktree is a full working directory with separate HEAD
- Worktree branches are ephemeral and should be deleted after cleanup
- Must handle cases where worktree creation fails (disk space, invalid branch)

### OpenCode Integration Points
- Spawn OpenCode agent with `--workdir` pointing to worktree path
- Pass structured prompts including iteration context
- Capture stdout/stderr for analysis and logging
- Handle agent timeouts and crashes gracefully

### State Management
- Loop state stored in `.ralph-worktrees/state.json`
- State includes: loop ID, status, iteration count, start time, logs
- State persists across Ralph system restarts
- State file excluded from git via `.gitignore`

### Performance Requirements
- Dashboard should load in under 1 second
- Loop status updates reflected in UI within 2 seconds
- System should support at least 10 concurrent Ralph loops
- Worktree creation should complete in under 5 seconds

### Error Handling
- If worktree creation fails, return error immediately (don't start loop)
- If OpenCode crashes, log error and mark iteration as failed
- If max iterations reached, preserve worktree for inspection
- Dashboard should show error messages prominently

## Success Metrics

- Developers can start a Ralph loop with a single slash command
- Loops successfully iterate on failures without manual intervention at least 70% of the time
- Dashboard provides actionable insights within 2 seconds of status change
- Zero interference with main development workspace (no accidental commits to main branch)
- Worktree cleanup reduces disk usage by 90% after loop completion

## Open Questions

1. Should successful Ralph loop changes be automatically committed in the worktree branch, or left as unstaged changes?
2. What should happen if a Ralph loop solves the problem but introduces new test failures elsewhere?
3. Should there be a way to "pause" a running Ralph loop and inspect intermediate state?
4. How should we handle conflicts if the main branch moves forward while a Ralph loop is running?
5. Should the dashboard support filtering/searching loops by task description or status?
6. What's the desired behavior if user manually modifies files in a Ralph loop worktree while it's running?
7. Should there be notifications (desktop, sound) when a Ralph loop completes?
8. What level of OpenCode agent autonomy should be allowed (e.g., can it install packages, modify config files)?
