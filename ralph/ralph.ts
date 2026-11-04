#!/usr/bin/env node
// Ralph Wiggum - Long-running AI agent loop
// Usage: ./ralph.ts [--tool amp|claude|opencode] [max_iterations]

import { readFileSync, writeFileSync, existsSync, mkdirSync, copyFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

// Get script directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

interface Config {
  tool: 'amp' | 'claude' | 'opencode';
  maxIterations: number;
}

function parseArguments(): Config {
  const args = process.argv.slice(2);
  let tool: 'amp' | 'claude' | 'opencode' = 'amp'; // Default to amp for backwards compatibility
  let maxIterations = 10;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === '--tool' && args[i + 1]) {
      tool = args[i + 1] as 'amp' | 'claude' | 'opencode';
      i++; // Skip next argument
    } else if (arg.startsWith('--tool=')) {
      tool = arg.split('=')[1] as 'amp' | 'claude' | 'opencode';
    } else if (/^\d+$/.test(arg)) {
      // Assume it's max_iterations if it's a number
      maxIterations = parseInt(arg, 10);
    }
  }

  // Validate tool choice
  if (tool !== 'amp' && tool !== 'claude' && tool !== 'opencode') {
    console.error(`Error: Invalid tool '${tool}'. Must be 'amp', 'claude', or 'opencode'.`);
    process.exit(1);
  }

  return { tool, maxIterations };
}

function archivePreviousRun(
  prdFile: string,
  progressFile: string,
  archiveDir: string,
  lastBranchFile: string
): void {
  if (!existsSync(prdFile) || !existsSync(lastBranchFile)) {
    return;
  }

  try {
    const prdContent = readFileSync(prdFile, 'utf-8');
    const prd = JSON.parse(prdContent);
    const currentBranch = prd.branchName || '';
    const lastBranch = readFileSync(lastBranchFile, 'utf-8').trim();

    if (currentBranch && lastBranch && currentBranch !== lastBranch) {
      // Archive the previous run
      const date = new Date().toISOString().split('T')[0];
      // Strip "ralph/" prefix from branch name for folder
      const folderName = lastBranch.replace(/^ralph\//, '');
      const archiveFolder = join(archiveDir, `${date}-${folderName}`);

      console.log(`Archiving previous run: ${lastBranch}`);
      mkdirSync(archiveFolder, { recursive: true });
      
      if (existsSync(prdFile)) {
        copyFileSync(prdFile, join(archiveFolder, 'prd.json'));
      }
      if (existsSync(progressFile)) {
        copyFileSync(progressFile, join(archiveFolder, 'progress.txt'));
      }
      
      console.log(`   Archived to: ${archiveFolder}`);

      // Reset progress file for new run
      const progressHeader = `# Ralph Progress Log\nStarted: ${new Date().toLocaleString()}\n---\n`;
      writeFileSync(progressFile, progressHeader);
    }
  } catch (error) {
    // Silently handle errors in archiving
  }
}

function trackCurrentBranch(prdFile: string, lastBranchFile: string): void {
  if (!existsSync(prdFile)) {
    return;
  }

  try {
    const prdContent = readFileSync(prdFile, 'utf-8');
    const prd = JSON.parse(prdContent);
    const currentBranch = prd.branchName || '';
    
    if (currentBranch) {
      writeFileSync(lastBranchFile, currentBranch);
    }
  } catch (error) {
    // Silently handle errors
  }
}

function initializeProgressFile(progressFile: string): void {
  if (!existsSync(progressFile)) {
    const progressHeader = `# Ralph Progress Log\nStarted: ${new Date().toLocaleString()}\n---\n`;
    writeFileSync(progressFile, progressHeader);
  }
}

function runTool(tool: 'amp' | 'claude' | 'opencode', scriptDir: string): string {
  try {
    let output: string;
    
    if (tool === 'amp') {
      const promptFile = join(scriptDir, 'prompt.md');
      const prompt = readFileSync(promptFile, 'utf-8');
      output = execSync(`echo "${prompt.replace(/"/g, '\\"')}" | amp --dangerously-allow-all`, {
        encoding: 'utf-8',
        stdio: ['pipe', 'pipe', 'inherit']
      });
    } else if (tool === 'claude') {
      // Claude Code: use --dangerously-skip-permissions for autonomous operation, --print for output
      const claudeFile = join(scriptDir, 'CLAUDE.md');
      output = execSync(`claude --dangerously-skip-permissions --print < "${claudeFile}"`, {
        encoding: 'utf-8',
        shell: '/bin/bash',
        stdio: ['pipe', 'pipe', 'inherit']
      });
    } else {
      // OpenCode: use run command with dir parameter
      const promptFile = join(scriptDir, 'prompt.md');
      const prompt = readFileSync(promptFile, 'utf-8');
      output = execSync(`opencode run --dir "${scriptDir}" "${prompt.replace(/"/g, '\\"')}"`, {
        encoding: 'utf-8',
        shell: '/bin/bash',
        stdio: ['pipe', 'pipe', 'inherit']
      });
    }
    
    return output;
  } catch (error) {
    // Return empty string on error (command may fail but we continue)
    return '';
  }
}

function main(): void {
  const { tool, maxIterations } = parseArguments();
  
  const scriptDir = __dirname;
  const prdFile = join(scriptDir, 'prd.json');
  const progressFile = join(scriptDir, 'progress.txt');
  const archiveDir = join(scriptDir, 'archive');
  const lastBranchFile = join(scriptDir, '.last-branch');

  // Archive previous run if branch changed
  archivePreviousRun(prdFile, progressFile, archiveDir, lastBranchFile);

  // Track current branch
  trackCurrentBranch(prdFile, lastBranchFile);

  // Initialize progress file if it doesn't exist
  initializeProgressFile(progressFile);

  console.log(`Starting Ralph - Tool: ${tool} - Max iterations: ${maxIterations}`);

  for (let i = 1; i <= maxIterations; i++) {
    console.log('');
    console.log('===============================================================');
    console.log(`  Ralph Iteration ${i} of ${maxIterations} (${tool})`);
    console.log('===============================================================');

    // Run the selected tool with the ralph prompt
    const output = runTool(tool, scriptDir);

    // Check for completion signal
    if (output.includes('<promise>COMPLETE</promise>')) {
      console.log('');
      console.log('Ralph completed all tasks!');
      console.log(`Completed at iteration ${i} of ${maxIterations}`);
      process.exit(0);
    }

    console.log(`Iteration ${i} complete. Continuing...`);
    
    // Sleep for 2 seconds
    execSync('sleep 2');
  }

  console.log('');
  console.log(`Ralph reached max iterations (${maxIterations}) without completing all tasks.`);
  console.log(`Check ${progressFile} for status.`);
  process.exit(1);
}

main();
