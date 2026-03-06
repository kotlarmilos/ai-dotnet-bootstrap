# CI Feedback Loop

The most critical piece of AI-native infrastructure. Without this, agents are blind — they can change code but can't see if it works.

## The Loop

```
Agent writes code
    ↓
Push to PR branch
    ↓
CI runs (build, test, lint)
    ↓
Agent reads CI results     ← You're setting this up
    ↓
Agent diagnoses + fixes
    ↓
Push again → repeat until green
```

## Three Components

### 1. copilot-setup-steps.yml (Build Environment)

**What**: A GitHub Actions workflow that pre-builds the repo so GitHub's remote Copilot Coding Agent has a working environment.

**Why**: Without this, remote Copilot starts from scratch every time — no SDK, no restored packages, no built dependencies. With this, it starts ready to code.

**Template**: `assets/core/copilot-setup-steps.yml`

**Fill in**:
- `{{DOTNET_VERSION}}` — From `global.json` (e.g., `9.0.100`)
- `{{RESTORE_COMMAND}}` — e.g., `dotnet restore Solution.sln`
- `{{BUILD_COMMAND}}` — e.g., `dotnet build Solution.sln`

**Extra steps to add** (if applicable):
- `dotnet tool restore` — if the repo uses dotnet tools
- Workload install — if the repo targets mobile/WASM
- Node.js setup — if the repo has a JS/TS frontend

### 2. pr-build-status Skill (Read CI Results)

**What**: A skill that agents invoke to understand why CI failed on a PR.

**Why**: This is the "eyes" of the feedback loop. When an agent pushes a change and CI fails, it needs to:
1. Know which jobs failed
2. Read the failure logs
3. Extract the actual error (not 10,000 lines of build output)

**Template**: `assets/core/pr-build-status.md`

**Fill in**:
- `{{CI_SYSTEM}}` — `azure-pipelines` or `github-actions`
- `{{PIPELINE_NAMES}}` — Names of CI pipelines/workflows

**For Azure Pipelines**, the skill needs:
- Organization URL (`{{ORG}}`) and project name (`{{PROJECT}}`)
- A PAT token in `AZDO_PAT` environment variable
- REST API calls to get build status and failed task logs

```bash
# List builds for a PR
curl -s "https://dev.azure.com/{{ORG}}/{{PROJECT}}/_apis/build/builds?branchName=refs/pull/PR_NUM/merge&api-version=7.0" \
  -H "Authorization: Basic $(echo -n :$AZDO_PAT | base64)" | jq '.value[] | {id, status, result}'

# Get build timeline (shows failed tasks)
curl -s "https://dev.azure.com/{{ORG}}/{{PROJECT}}/_apis/build/builds/BUILD_ID/timeline?api-version=7.0" \
  -H "Authorization: Basic $(echo -n :$AZDO_PAT | base64)" | jq '.records[] | select(.result == "failed") | {name, issues}'

# Get task log (actual error output)
curl -s "https://dev.azure.com/{{ORG}}/{{PROJECT}}/_apis/build/builds/BUILD_ID/logs/LOG_ID?api-version=7.0" \
  -H "Authorization: Basic $(echo -n :$AZDO_PAT | base64)" | tail -100
```

**For GitHub Actions**, the skill uses:
```bash
# List recent runs for a PR branch
gh run list --branch BRANCH --limit 5 --json databaseId,status,conclusion,name

# Get failed jobs from a run
gh run view RUN_ID --json jobs --jq '.jobs[] | select(.conclusion == "failure") | .name'

# Get failure logs (the key command)
gh run view RUN_ID --log-failed 2>&1 | tail -100
```

### 3. ci-doctor Workflow (Optional — Auto-Diagnosis)

**What**: An agentic GitHub Actions workflow that automatically investigates CI failures on the default branch.

**Why**: When CI fails on `main` (not a PR), someone needs to investigate. This workflow:
1. Triggers on CI failure
2. Reads the failure logs
3. Searches for similar past failures
4. Creates a diagnostic issue with root cause analysis

**This is optional** because:
- It requires GitHub Models access (free for public repos)
- Not every team wants automated issue creation
- It's most valuable for repos with frequent CI failures

**Ask the user**: "Would you like automatic CI failure investigation? This creates GitHub Issues when CI fails on main."

## How Agents Use the Loop

### Local Agent (Copilot CLI)

```
User: "Fix issue #123"
Agent: [reads issue, writes fix, runs tests locally]
Agent: [pushes to PR branch]
Agent: [waits for CI]
Agent: [invokes pr-build-status skill]
Agent: "CI failed — test X is failing because Y. Let me fix that."
Agent: [fixes, pushes again]
```

### Remote Agent (Copilot Coding Agent)

```
GitHub assigns issue to Copilot
Copilot: [starts with copilot-setup-steps environment]
Copilot: [reads copilot-instructions.md to understand repo]
Copilot: [writes fix, runs tests in environment]
Copilot: [creates PR]
CI runs → if failure → Copilot reads results → iterates
```

### Built-in GitHub PR Review

GitHub's built-in AI PR review can use the CI status to provide more informed reviews:
- Sees which checks passed/failed
- Can reference test results in review comments
- `copilot-instructions.md` teaches it the repo's context

## Verification

After setting up all three components, verify:

```bash
# copilot-setup-steps.yml exists and has correct SDK version
grep "dotnet-version" .github/workflows/copilot-setup-steps.yml

# pr-build-status skill exists
cat .github/skills/pr-build-status/SKILL.md | head -5

# Test the CI reading commands work
gh run list --limit 1  # Should return recent runs
```
