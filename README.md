# GitHub Copilot modernization CLI

## What is GitHub Copilot modernization CLI?

[GitHub Copilot modernization](https://aka.ms/ghcp-appmod) provides AI-powered capabilities to help users modernize Java and .NET applications easily and confidently.

Organizations modernizing multiple applications need consistency, repeatability, and the ability to define standards that apply across every dev team and repository. The [GitHub Copilot Modernization Agent](https://aka.ms/ghcp-modernization-agent) is built for these requirements.

Delivered through the Modernize CLI, the modernization agent enables agentic, end-to-end application modernization through intelligent workflow orchestration. It provides architects and app owners with a platform to define modernization standards once - via customizable, reusable skills - and apply them consistently across multiple applications and repositories. It offers a unified CLI and TUI experience for hands-on modernization of individual applications.

## Learn More

For detailed documentation, tutorials, and additional resources, visit the [GitHub Copilot Modernization Agent documentation](https://aka.ms/ghcp-modernization-agent).

## 🖥️ Supported Platforms

- Windows (x64, ARM64)
- Linux (x64, ARM64)
- macOS (Apple Silicon, Intel)

## 🔧 Prerequisites

Minimum requirements:
- [Git](https://git-scm.com/downloads)
- [GitHub CLI (gh)](https://cli.github.com/) v2.45.0 or later
- GitHub Copilot subscription with Free, Pro, Pro+, Business and Enterprise plans, See [Copilot plans](https://github.com/features/copilot/plans?ref_cta=Copilot+plans+signup&ref_loc=install-copilot-cli&ref_page=docs).

## Installation

### Linux / macOS

**Option 1 — Homebrew:**
```bash
brew tap microsoft/modernize https://github.com/microsoft/modernize-cli
brew install modernize
```

**Option 2 — Shell script:**
```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.sh | sh
```

After installation, reload your shell profile to apply the PATH update:
```bash
source ~/.bashrc   # or source ~/.zshrc for Zsh
```

> [!NOTE]
> **For Linux users:** Requires **glibc 2.27+** (Ubuntu 18.04+, Debian 10+, Fedora 29+, Azure Linux 2.0+).

### Windows

**Option 1 — PowerShell one-liner:**
```powershell
iex (irm https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.ps1)
```

**Option 2 — MSI installer:**

Download and run the latest MSI from the [Releases page](https://github.com/microsoft/modernize-cli/releases/latest).

The installer places the `modernize` command in `%LOCALAPPDATA%\Programs\modernize` and adds it to your PATH automatically.

---

The scripts automatically download the latest release, install the modernize bundle to `~/.local/share/modernize` (Linux/macOS) or `%LOCALAPPDATA%\Programs\modernize` (Windows), place the `modernize` command in `~/.local/bin` (Linux/macOS), and add the command directory to your PATH.

## Use the interactive mode

The easiest way to get started is using the interactive mode. First, authenticate with the GitHub CLI:

```bash
gh auth login
```

Then, run the modernization agent:

```bash
modernize
```

You'll be guided through the end-to-end modernization experience via the main menu:

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
| `--model <model>` | LLM model to use | `claude-sonnet-4.6` |
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
modernize assess --multi-repo
```

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
| `--language <lang>` | Programming language (`java` or `dotnet`) | Auto-detected |
| `--overwrite` | Overwrite an existing plan with the same name | Disabled |
| `--model <model>` | LLM model to use | `claude-sonnet-4.6` |

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
| `--language <lang>` | Programming language (`java` or `dotnet`) | Auto-detected |
| `--model <model>` | LLM model to use | `claude-sonnet-4.6` |
| `--delegate <delegate>` | Execution mode: `local` (this machine) or `cloud` (Cloud Coding Agent) | `local` |
| `--force` | Force execution even when a CCA job is in progress | Disabled |

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

### upgrade

Runs an end-to-end upgrade workflow — plan, and execute — in a single command.

#### Syntax

```bash
modernize upgrade [<prompt>] [options]
```

#### Arguments

| Argument | Description |
|----------|-------------|
| `[<prompt>]` | Target version (e.g., `Java 17`, `Spring Boot 3.2`, `.NET 10`). Defaults to latest LTS. |

#### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source <source>` | Path to source project (relative or absolute local path) | `.` (current directory) |
| `--delegate <delegate>` | Execution mode: `local` (this machine) or `cloud` (Cloud Coding Agent) | `local` |
| `--model <model>` | LLM model to use | `claude-sonnet-4.6` |

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

### help

Provides help and information commands.

#### Syntax

```bash
modernize help [command]
```

#### Commands

| Command | Description |
|---------|-------------|
| `models` | List available LLM models and their multipliers |

#### Examples

List available models:
```bash
modernize help models
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
