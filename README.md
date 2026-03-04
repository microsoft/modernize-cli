# GitHub Copilot modernization CLI

## What is GitHub Copilot modernization?

[GitHub Copilot modernization](https://aka.ms/ghcp-appmod) provides AI-powered capabilities to help developers modernize Java and .NET applications easily and confidently. Github Copilot modernization cli enables autonomous, end-to-end application modernization—from analyzing applications and generating plans to executing modernization tasks in agentic way.

## 🖥️ Supported Platforms

- Windows (x64, ARM64)
- Linux (x64, ARM64)
- macOS (Apple Silicon, Intel)

## 🔧 Prerequisites

Minimum requirements:
- [Git](https://git-scm.com/downloads)
- GitHub Copilot subscription with Free, Pro, Pro+, Business and Enterprise plans, See [Copilot plans](https://github.com/features/copilot/plans?ref_cta=Copilot+plans+signup&ref_loc=install-copilot-cli&ref_page=docs).

If you encounter issues with an agent, please open an issue so we can refine the integration.

## ⚡ Get Started

### Installation

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

### Prepare sample repo

**Java Sample**
```bash
# Clone the sample Java project repository
git clone https://github.com/Azure-Samples/PhotoAlbum-Java.git

cd PhotoAlbum-Java

# Login to GitHub (required for Copilot authentication)
gh auth login
```

**.NET Sample**
```bash
# Clone the sample DotNET project repository
git clone https://github.com/Azure-Samples/PhotoAlbum.git

cd PhotoAlbum

# Login to GitHub (required for Copilot authentication)
gh auth login
```

### Step-by-Step Guide

This section guides you through an end-to-end experience of modernizing your application using GitHub Copilot modernization CLI. You'll learn how to understand your application through assessment, create a tailored modernization plan based on your goals, and execute the plan to apply changes to your codebase.

```bash
# Run modernize interactively
modernize
```

Enter the main menu:
```
╭─┤ What would you like to do? ├───────────────────────────────────────────────╮
│ > 1. Understand my application                                               │
│   2. Create a modernization plan                                             │
|   3. Execute the modernization plan                                          │
╰──────────────────────────────────────────────────────────────────────────────╯
```
Select 1. Understand my application

Follow the interactive prompts:
1. Enter optional parameters (e.g., output path, issue URL) or press Enter to use defaults
2. Review your selections and press Enter to confirm to start the assessment
3. Wait for the assessment to complete - results will be saved to `.modernize/.appcat/`

Select 2. Create a modernization plan

Follow the interactive prompts:
1. Enter optional parameters (e.g., plan name) or press Enter to use defaults
2. Enter the migration prompt, e.g., `migrate from oracle to azure postgresqldb`
3. Press Enter to create the plan
4. Wait for the plan to be generated - plan file will be saved to path `.github/modernization/{plan-name}/plan.md` and task breakdown list file will be saved to `.github/modernization/{plan-name}/tasks.json`

> [!TIP]
> After the plan is generated, you can manually edit `plan.md` to add clarifications or adjust details, and update `tasks.json` to modify, reorder, add, or remove tasks before executing the plan.

Select 3. Execute the modernization plan

Follow the interactive prompts:
1. Enter the plan name
2. Press Enter to execute the plan
3. Wait for the plan execution to complete - changes will be applied to your project

### Assess multiple repos

`modernize` can also assess multiple repos and generate an aggregated dashboard to have an overview of the applications. 

To enable multi-repo mode, create a `.github/modernize/repos.json` file in the working directory with the following structure:

```json
[
  {
    "name": "PhotoAlbum-Java",
    "url": "https://github.com/Azure-Samples/PhotoAlbum-Java.git"
  },
  {
    "name": "PhotoAlbum",
    "url": "https://github.com/Azure-Samples/PhotoAlbum.git"
  }
]
```

Run `modernize`:
```bash
modernize
```

The console will display the repos in the `repos.json` file:
```
╭─┤ 2 repositories ├───────────────────────────────────────────────────────────╮
│ Name            URL                                                          │
│ contoso         https://github.com/example/contoso.git                       │
│ animalcrossing  https://github.com/example/animalcrossing.git                │
│                                                                              │
│                                                                              │
│                                                                              │
╰──────────────────────────────────────────────────────────────────────────────╯
Ctrl+C Exit · ↑↓ Navigate · Enter Select · Ctrl+A Select All
```

Follow these steps to assess all repositories:
1. Press `Ctrl+A` to select all repositories in the list
2. Press `Enter` to confirm the selection
3. Select **1. Understand my application** from the main menu and press `Enter`
4. `modernize` will automatically clone all selected repositories and run the assessment on each one
5. Once complete, an aggregated summary report will be generated and your browser will open with an interactive dashboard showing the assessment results across all repositories

### Customize the migration using your own skill

`modernize` supports custom skills that allow you to define your own migration patterns and sample code. This is useful when you have organization-specific migration requirements or want to use internal libraries.

Follow these steps to use a custom skill:

1. Clone the sample repository that contains a customized skill:
   ```bash
   git clone https://github.com/qianwens/NewsFeedSite
   cd NewsFeedSite
   ```

2. This repository includes a custom skill at `.github/skills/rabbitmq-to-azureservicebus/SKILL.md` which contains sample code demonstrating how to use the internal JDK to access Azure Service Bus.

3. Run `modernize` in the project directory:
   ```bash
   modernize
   ```

4. Select **2. Create a modernization plan** from the main menu

5. Enter your migration prompt, e.g., `migrate from rabbitmq to azure service bus`

6. `modernize` will automatically detect and use the custom skill from `.github/skills/` to generate a tailored migration plan with your organization's preferred patterns and libraries.

#### Create your own custom skill

To create your own custom skill, reference the sample skill at `.github/skills/rabbitmq-to-azureservicebus/SKILL.md` in the [NewsFeedSite repository](https://github.com/qianwens/NewsFeedSite). This skill demonstrates how to migrate from RabbitMQ messaging to Azure Service Bus using an internal JDK library. It includes:

- **Migration description**: Explains the migration scenario from RabbitMQ to Azure Service Bus
- **Step-by-step instructions**: Guides the agent through dependency updates, configuration changes, and code modifications
- **Sample code snippets**: Provides concrete examples of how to use the internal JDK to connect to Azure Service Bus, send messages, and receive messages
- **Best practices**: Includes recommended patterns for connection management, error handling, and resource cleanup

To create your own skill:
1. Create a new folder under `.github/skills/` in your repository with a descriptive name (e.g., `my-migration-skill`)
2. Add a `SKILL.md` file with the required header and content:

   The `SKILL.md` file **must** include a YAML front matter header with `name` and `description` fields. The agent uses the `description` to determine when to apply the skill based on the user's migration prompt, so make sure the description is concrete and accurately describes the migration scenario.

   ```markdown
   ---
   name: migrate-from-rabbitmq-to-azure-service-bus
   description: Migrate from RabbitMQ with AMQP to Azure Service Bus for messaging.
   ---

   ## Overview
   (Your migration overview here)

   ## Steps
   (Step-by-step instructions here)

   ## Sample Code
   (Code snippets here)
   ```

3. Run `modernize` to create migration plan and it will automatically discover and use your custom skill when the migration prompt matches the skill description

## Commands
#### Assess

Runs AppCAT assessment and generates a summary report.

```bash
modernize assess [options]
```

**Examples:**
```bash
# Basic assessment
modernize assess

# Assessment with result summary updated in github issue
modernize assess --issue-url https://github.com/org/repo/issues/123

# Assessment with custom output path
modernize assess --output-path ./reports/assessment
```

#### Plan Create

Creates a modernization plan based on a prompt

```bash
modernize plan create <prompt> [options]
```

**Examples:**
```bash
# Generate a full migration plan for the entire application
modernize plan create "migrate from on-premises to azure"

# Generate a plan to migrate a specific service
modernize plan create "migrate from oracle to azure postgresql" \
  --plan-name oracle-to-postgresql

# Generate a plan to deploy the application to Azure
modernize plan create "deploy the app to azure container apps" \
  --plan-name deploy-to-aca

# Full options
modernize plan create "upgrade to spring boot 3" \
  --source /path/to/project \
  --plan-name spring-boot-upgrade \
  --language java \
  --issue-url https://github.com/org/repo/issues/456
```

#### Plan Execute

Executes a modernization plan previously created by `modernize plan create`.

```bash
modernize plan execute [prompt] [options]
```

**Examples:**
```bash
# Execute the plan that created
modernize plan execute 

# Execute with specific plan name and prompt
modernize plan execute "skip the test" --plan-name spring-boot-upgrade

# Headless mode for CI/CD 
modernize plan execute "execute plan" --plan-name spring-boot-upgrade --no-tty
```

## Feedback

We're thrilled to have you join us on the early journey of the modernization agent. Your feedback is invaluable—please [share your thoughts](https://aka.ms/ghcp-appmod/feedback) with us!

## Disclaimer

Unless otherwise permitted under applicable license(s), users may not decompile, modify, repackage, or redistribute any assets, prompts, or internal tools provided as part of this product without prior written consent from Microsoft.
