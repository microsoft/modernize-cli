# Install

## Steps

1) Detect OS (`linux`, `darwin`) and architecture (`x64`, `arm64`)

2) Check the gh CLI version; if below 2.45.0, warn and prompt to continue or abort

3) Obtain a GitHub token via `gh auth token` (if gh CLI is available and authenticated)

4) Fetch the release metadata from the GitHub API, using the token as a Bearer header if available:
   - Default: latest stable release (`api.github.com/repos/.../releases/latest`)
   - With `--prerelease` (shell) / `-Prerelease` (PowerShell): newest release overall including prereleases, via the releases list endpoint (`api.github.com/repos/.../releases?per_page=1`), taking the first (newest) entry

5) Resolve the archive filename from the release metadata based on the detected os-arch

6) Download the archive:
   - If a token is available, use the GitHub API asset endpoint (`api.github.com/repos/.../releases/assets/{id}`) with `Accept: application/octet-stream` — this returns a pre-signed CDN URL that can be followed without forwarding the auth header
   - Otherwise, download directly from `github.com/releases/download/...`

7) Extract the archive (`.tar.gz` on Linux/macOS, `.zip` on Windows) into a temp directory

8) Copy the extracted bundle to the install directory (default: `~/.local/share/modernize` on Linux/macOS, `%LOCALAPPDATA%\\Programs\\modernize` on Windows) and make `modernize` executable

9) Ensure the command directory is in the user's `PATH` (default: `~/.local/bin` on Linux/macOS, install directory on Windows); on Linux/macOS, create `~/.local/bin/modernize` as an entrypoint to the installed bundle