import { execSync } from 'child_process';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

/**
 * Creates a unique loop ID for a Ralph loop
 */
export function generateLoopId(): string {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 7);
  return `${timestamp}-${random}`;
}

/**
 * Creates a git worktree for a Ralph loop
 * @param loopId - Unique identifier for the loop
 * @param baseDir - Base directory where worktrees will be created (default: .ralph-worktrees)
 * @returns Path to the created worktree
 */
export function createWorktree(loopId: string, baseDir: string = '.ralph-worktrees'): string {
  // Ensure base directory exists
  if (!existsSync(baseDir)) {
    mkdirSync(baseDir, { recursive: true });
  }

  const worktreePath = join(baseDir, loopId);
  const branchName = `ralph/${loopId}`;

  try {
    // Get current HEAD commit
    const currentHead = execSync('git rev-parse HEAD', { encoding: 'utf-8' }).trim();

    // Create worktree with new branch based on current HEAD
    execSync(`git worktree add -b "${branchName}" "${worktreePath}" "${currentHead}"`, {
      encoding: 'utf-8',
      stdio: 'inherit'
    });

    console.log(`Created worktree at: ${worktreePath}`);
    console.log(`Branch: ${branchName}`);
    
    return worktreePath;
  } catch (error) {
    throw new Error(`Failed to create worktree: ${error instanceof Error ? error.message : String(error)}`);
  }
}

/**
 * Removes a worktree and its associated branch
 * @param loopId - Unique identifier for the loop
 * @param baseDir - Base directory where worktrees are located
 */
export function removeWorktree(loopId: string, baseDir: string = '.ralph-worktrees'): void {
  const worktreePath = join(baseDir, loopId);
  const branchName = `ralph/${loopId}`;

  try {
    // Remove worktree
    execSync(`git worktree remove "${worktreePath}" --force`, {
      encoding: 'utf-8',
      stdio: 'inherit'
    });

    // Delete the branch
    execSync(`git branch -D "${branchName}"`, {
      encoding: 'utf-8',
      stdio: 'inherit'
    });

    console.log(`Removed worktree: ${worktreePath}`);
    console.log(`Deleted branch: ${branchName}`);
  } catch (error) {
    throw new Error(`Failed to remove worktree: ${error instanceof Error ? error.message : String(error)}`);
  }
}

/**
 * Lists all Ralph worktrees
 * @returns Array of loop IDs for existing worktrees
 */
export function listWorktrees(baseDir: string = '.ralph-worktrees'): string[] {
  try {
    const worktreeList = execSync('git worktree list --porcelain', { encoding: 'utf-8' });
    const loopIds: string[] = [];
    
    const lines = worktreeList.split('\n');
    for (const line of lines) {
      if (line.startsWith('worktree ')) {
        const path = line.substring('worktree '.length);
        if (path.includes(baseDir)) {
          const loopId = path.split('/').pop();
          if (loopId) {
            loopIds.push(loopId);
          }
        }
      }
    }
    
    return loopIds;
  } catch (error) {
    return [];
  }
}

/**
 * Checks if a worktree exists for a given loop ID
 * @param loopId - Unique identifier for the loop
 * @param baseDir - Base directory where worktrees are located
 * @returns True if worktree exists, false otherwise
 */
export function worktreeExists(loopId: string, baseDir: string = '.ralph-worktrees'): boolean {
  const worktreePath = join(baseDir, loopId);
  return existsSync(worktreePath);
}
