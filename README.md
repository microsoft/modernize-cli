# GitHub Copilot modernization CLI

## What is GitHub Copilot modernization?

[GitHub Copilot modernization](https://aka.ms/ghcp-appmod) provides AI-powered capabilities to help developers modernize Java and .NET applications easily and confidently. Github Copilot modernization cli enables autonomous, end-to-end application modernization—from analyzing applications and generating plans to executing modernization tasks in agentic way.

## Tutorials

- [Quickstart - Modernization Agent | Microsoft Learn](https://learn.microsoft.com/azure/developer/modernize/quickstart)
- [Customization | Microsoft Learn](https://learn.microsoft.com/azure/developer/modernize/customization)
- [Batch Assessment | Microsoft Learn](https://learn.microsoft.com/azure/developer/modernize/batch-assessment)
- [Batch Upgrade | Microsoft Learn](https://learn.microsoft.com/azure/developer/modernize/batch-upgrade)
- [Infrastructure and deployment | Microsoft Learn](https://learn.microsoft.com/azure/developer/modernize/infrastructure-deployment)

## 🖥️ Supported Platforms

- Windows (x64, ARM64)
- Linux (x64, ARM64)
- macOS (Apple Silicon, Intel)

## 🔧 Prerequisites

Minimum requirements:
- [Git](https://git-scm.com/downloads)
- GitHub Copilot subscription with Free, Pro, Pro+, Business and Enterprise plans, See [Copilot plans](https://github.com/features/copilot/plans?ref_cta=Copilot+plans+signup&ref_loc=install-copilot-cli&ref_page=docs).

If you encounter issues with an agent, please open an issue so we can refine the integration.

## Installation

1. Clone this repository:

   ```bash
   gh repo clone microsoft/modernize-cli
   cd modernize-cli
   ```

2. Run the install script:

   **Linux/macOS:**
   ```bash
   sh scripts/install.sh
   ```

   After installation, reload your shell profile to apply the PATH update:
   ```bash
   source ~/.bashrc   # or source ~/.zshrc for Zsh
   ```

   **Windows (PowerShell):**
   ```powershell
   .\scripts\install.ps1
   ```

The scripts automatically download the latest release, install the `modernize` binary to `~/.modernize/bin`, and add it to your PATH.

> [!NOTE]
> **For Linux users:** Requires **glibc 2.27+** (Ubuntu 18.04+, Debian 10+, Fedora 29+, Azure Linux 2.0+).

## Interactive mode

This section guides you through an end-to-end experience of modernizing your application using GitHub Copilot modernization CLI. You'll learn how to understand your application through assessment, create a tailored modernization plan based on your goals, and execute the plan to apply changes to your codebase.

```bash
# Run modernize interactively
modernize
```

> [!NOTE]
> If you haven't authenticated previously through the GitHub CLI (`gh auth login`), the agent prompts you to authenticate before proceeding.

You'll see the main menu:

```
○ How would you like to modernize your Java app?

  > 1. Assess application
       Analyze the project and identify modernization opportunities
    2. Create modernization plan
       Generate a structured plan to guide the agent
    3. Execute modernization plan
       Run the tasks defined in the modernization plan
```

## Commands

### Global options

All commands support these global options:

| Option | Description |
|--------|-------------|
| `--help`, `-h` | Display help information |
| `--no-tty` | Disable interactive prompts (headless mode) |

### assess

Runs assessment and generates a comprehensive analysis report.

#### Syntax

```bash
modernize assess [options]
```

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source <path>` | Path to source project (relative or absolute local path) | `.` (current directory) |
| `--output-path <path>` | Custom output path for assessment results | `.github/modernize/assessment/` |
| `--issue-url <url>` | GitHub issue URL to update with assessment summary | None |
| `--multi-repo` | Enable multi-repo assess. Scans first-level subdirectories for multiple repositories | Disabled |
| `--model <model>` | LLM model to use | `claude-sonnet-4.5` |
| `--delegate <delegate>` | Execution mode: `local` (this machine) or `cloud` (Cloud Coding Agent) | `local` |
| `--wait` | Wait for delegated tasks to complete and generate results (only valid with `--delegate cloud`) | Disabled |
| `--force` | Force restart delegation, ignoring ongoing tasks (only valid with `--delegate cloud`) | Disabled |

#### Examples

Basic assessment of current directory:
```bash
modernize assess
```

Assess with custom output location:
```bash
modernize assess --output-path ./reports/assessment
```

Assess and update GitHub issue with results:
```bash
modernize assess --issue-url https://github.com/org/repo/issues/123
```

Assess specific project directory:
```bash
modernize assess --source /path/to/project
```

Assess multiple repos in current directory:
```bash
modernize assess  --multi-repo
```

#### Output

The assessment generates:

- **Report files**: Detailed analysis in JSON, MD and HTML formats
- **Summary**: Key findings and recommendations
- **Issue updates** (if `--issue-url` provided): GitHub issue comment with summary

### plan create

Creates a modernization plan based on a natural language prompt describing your modernization goals.

#### Syntax

```bash
modernize plan create <prompt> [options]
```

#### Arguments

| Argument | Description |
|----------|-------------|
| `<prompt>` | Natural language description of modernization goals (required) |

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source <path>` | Path to the application source code | Current directory |
| `--plan-name <name>` | Name for the modernization plan | `modernization-plan` |
| `--language <lang>` | Programming language (java, dotnet, python) | Auto-detected |
| `--issue-url <url>` | GitHub issue to reference when creating plan | None |
| `--model <model>` | LLM model to use | `claude-sonnet-4.5` |

#### Examples

Generate a migration plan:
```bash
modernize plan create "migrate from oracle to azure postgresql"
```

Generate an upgrade plan with custom name:
```bash
modernize plan create "upgrade to spring boot 3" --plan-name spring-boot-upgrade
```

Generate a deployment plan:
```bash
modernize plan create "deploy the app to azure container apps" --plan-name deploy-to-aca
```

Full options example:
```bash
modernize plan create "upgrade to .NET 8" \
  --source /path/to/project \
  --plan-name dotnet8-upgrade \
  --language dotnet \
  --issue-url https://github.com/org/repo/issues/456
```

#### Prompt examples

**Framework upgrades:**
- `upgrade to spring boot 3`
- `upgrade to .NET 8`
- `migrate from spring boot 2 to spring boot 3`

**Database migrations:**
- `migrate from oracle to azure postgresql`
- `migrate from SQL Server to azure cosmos db`
- `switch from MySQL to azure database for mysql`

**Cloud migrations:**
- `migrate from on-premises to azure`
- `containerize and deploy to azure container apps`
- `migrate from rabbitmq to azure service bus`

**Deployment:**
- `deploy to azure app service`
- `deploy to azure kubernetes service`
- `set up CI/CD pipeline for azure`

#### Output

The command generates:

- **Plan file** (`.github/modernize/{plan-name}/plan.md`): Detailed modernization strategy including:
  - Context and goals
  - Approach and methodology
  - Clarifications

- **Task list** (`.github/modernize/{plan-name}/tasks.json`): Structured breakdown of executable tasks with:
  - Task descriptions
  - Skills to use
  - Success criteria

> [!TIP]
> You can manually edit both `plan.md` and `tasks.json` after generation to customize the approach before execution.

### plan execute

Executes a modernization plan created by `modernize plan create`.

#### Syntax

```bash
modernize plan execute [prompt] [options]
```

#### Arguments

| Argument | Description |
|----------|-------------|
| `[prompt]` | Optional natural language instructions for execution (e.g., "skip tests") |

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source <path>` | Path to the application source code | Current directory |
| `--plan-name <name>` | Name of the plan to execute | `modernization-plan` |
| `--no-tty` | Run in headless mode (for CI/CD) | Interactive mode |
| `--model <model>` | LLM model to use | `claude-sonnet-4.5` |
| `--delegate <delegate>` | Execution mode: `local` (this machine) or `cloud` (Cloud Coding Agent) | `local` |
| `--wait` | Wait for delegated tasks to complete and generate results (only valid with `--delegate cloud`) | Disabled |
| `--force` | Force restart delegation, ignoring ongoing tasks (only valid with `--delegate cloud`) | Disabled |

#### Examples

Execute the most recent plan interactively:
```bash
modernize plan execute
```

Execute a specific plan:
```bash
modernize plan execute --plan-name spring-boot-upgrade
```

Execute with additional instructions:
```bash
modernize plan execute "skip the test" --plan-name spring-boot-upgrade
```

Execute in headless mode for CI/CD:
```bash
modernize plan execute --plan-name spring-boot-upgrade --no-tty
```

#### Execution behavior

During execution, the agent:

1. **Loads the plan**: Reads the plan and task list from `.github/modernization/{plan-name}/`
2. **Executes tasks**: Processes each task in the task list sequentially:
   - Applies code transformations
   - Validates builds after changes
   - Scans for CVEs
   - Commits changes with descriptive messages
3. **Generates summary**: Provides a report of all changes and results

### Output

- **Commit history**: Detailed commits for each task executed
- **Summary report**: Overview of changes, successes, and any issues encountered
- **Build validation**: Confirmation that the application builds successfully
- **CVE report**: Security vulnerabilities identified and addressed

### upgrade

Runs an end-to-end upgrade workflow — plan, and execute — in a single command.

#### Syntax

```bash
modernize upgrade [options]
```

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source <source>` | Path to source project (relative or absolute local path) | `.` (current directory) |
| `--delegate <delegate>` | Execution mode: `local` (this machine) or `cloud` (Cloud Coding Agent) | `local` |
| `--model <model>` | LLM model to use | `claude-sonnet-4.5` |

#### Examples

Run upgrade on current directory:
```bash
modernize upgrade "Java 17"
```

```bash
modernize upgrade ".NET 10"
```

Run upgrade on a specific project:
```bash
modernize upgrade "Java 17" --source /path/to/project
```

Run upgrade using the Cloud Coding Agent:
```bash
modernize upgrade "Java 17" --delegate cloud
```

### Environment variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MODERNIZE_COLLECT_TELEMETRY` | Enable/disable telemetry collection | `true` |
| `MODERNIZE_LOG_LEVEL` | Logging level (debug, info, warn, error) | `info` |

Example:
```bash
export MODERNIZE_COLLECT_TELEMETRY=false
modernize assess
```

## Feedback

We're thrilled to have you join us on the early journey of the modernization agent. Your feedback is invaluable—please [share your thoughts](https://aka.ms/ghcp-appmod/feedback) with us!

## Disclaimer

Unless otherwise permitted under applicable license(s), users may not decompile, modify, repackage, or redistribute any assets, prompts, or internal tools provided as part of this product without prior written consent from Microsoft.
