#!/usr/bin/env sh
set -e

GITHUB_REPO="microsoft/modernize-cli"
INSTALL_DIR="${MODERNIZE_INSTALL_DIR:-$HOME/.modernize/bin}"
MIN_GH_VERSION="2.45.0"

# --- Helpers ---

info()    { printf '\033[0;32m[info]\033[0m  %s\n' "$*"; }
warn()    { printf '\033[0;33m[warn]\033[0m  %s\n' "$*" >&2; }
error()   { printf '\033[0;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

version_lt() {
    # Returns 0 (true) if $1 < $2
    awk -v v1="$1" -v v2="$2" 'BEGIN {
        n = split(v1, a, "."); split(v2, b, ".")
        for (i = 1; i <= 3; i++) {
            x = a[i] + 0; y = b[i] + 0
            if (x < y) exit 0
            if (x > y) exit 1
        }
        exit 1
    }'
}

# --- Detect OS and architecture ---

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    linux)  OS="linux"  ;;
    darwin) OS="darwin" ;;
    *)      error "Unsupported OS: $OS" ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)   ARCH="x64"   ;;
    aarch64|arm64)  ARCH="arm64" ;;
    *)              error "Unsupported architecture: $ARCH" ;;
esac

info "Detected platform: ${OS}/${ARCH}"

# --- Check gh CLI version ---

if command -v gh > /dev/null 2>&1; then
    GH_VERSION=$(gh --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -z "$GH_VERSION" ]; then
        warn "Could not determine gh CLI version."
    elif version_lt "$GH_VERSION" "$MIN_GH_VERSION"; then
        warn "gh CLI version $GH_VERSION is below the minimum required version $MIN_GH_VERSION."
        warn "Please update gh CLI: https://cli.github.com/"
        printf 'Continue anyway? [y/N] '
        read -r REPLY
        case "$REPLY" in
            [yY][eE][sS]|[yY]) ;;
            *) error "Installation aborted." ;;
        esac
    else
        info "gh CLI version $GH_VERSION OK"
    fi
else
    warn "gh CLI not found. Please install it from https://cli.github.com/"
fi

# --- Fetch latest release version ---

info "Fetching latest release..."

# Obtain a GitHub token via gh CLI (if available) for authenticated requests.
# This avoids rate-limiting without relying on the deprecated `gh release download`.
GH_TOKEN=""
if command -v gh > /dev/null 2>&1; then
    GH_TOKEN=$(gh auth token 2>/dev/null || true)
fi

if command -v curl > /dev/null 2>&1; then
    RELEASE_JSON=$(curl -fsSL \
        -H "Accept: application/vnd.github+json" \
        ${GH_TOKEN:+-H "Authorization: Bearer $GH_TOKEN"} \
        "https://api.github.com/repos/${GITHUB_REPO}/releases/latest") \
        || error "Failed to fetch release info from GitHub."
elif command -v wget > /dev/null 2>&1; then
    RELEASE_JSON=$(wget -qO- \
        --header="Accept: application/vnd.github+json" \
        ${GH_TOKEN:+--header="Authorization: Bearer $GH_TOKEN"} \
        "https://api.github.com/repos/${GITHUB_REPO}/releases/latest") \
        || error "Failed to fetch release info from GitHub."
else
    error "Neither curl nor wget found. Please install one of them."
fi

TAG=$(printf '%s' "$RELEASE_JSON" | grep '"tag_name"' | head -1 \
    | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
VERSION=$(printf '%s' "$TAG" | sed 's/^v//')

[ -n "$VERSION" ] || error "Could not determine latest version."
info "Latest version: $VERSION"

# --- Download ---

ARCHIVE="modernize_${VERSION}_${OS}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${TAG}/${ARCHIVE}"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

ARCHIVE_PATH="${TMP_DIR}/${ARCHIVE}"

# When a token is present, downloading via the browser URL (github.com/releases/download/...)
# causes GitHub to redirect to a CDN URL that requires auth embedded in the URL's query
# params. curl strips the Authorization header on cross-host redirects, so the CDN returns 404.
# Fix: use the GitHub API asset endpoint with Accept: application/octet-stream, which
# returns a pre-signed CDN URL (auth in query params). curl follows it without needing headers.
if [ -n "$GH_TOKEN" ]; then
    ASSET_API_URL=$(printf '%s' "$RELEASE_JSON" | awk -v archive="$ARCHIVE" '
        /api\.github\.com.*releases\/assets/ {
            match($0, /https:\/\/api\.github\.com[^"]+/)
            last = substr($0, RSTART, RLENGTH)
        }
        index($0, archive) && last != "" { print last; exit }
    ')
fi

info "Downloading $ARCHIVE..."
if [ -n "$ASSET_API_URL" ]; then
    if command -v curl > /dev/null 2>&1; then
        curl -fL --progress-bar \
            -H "Authorization: Bearer $GH_TOKEN" \
            -H "Accept: application/octet-stream" \
            "$ASSET_API_URL" -o "$ARCHIVE_PATH" \
            || error "Download failed."
    else
        wget -q --show-progress \
            --header="Authorization: Bearer $GH_TOKEN" \
            --header="Accept: application/octet-stream" \
            "$ASSET_API_URL" -O "$ARCHIVE_PATH" \
            || error "Download failed."
    fi
else
    if command -v curl > /dev/null 2>&1; then
        curl -fL --progress-bar \
            "$DOWNLOAD_URL" -o "$ARCHIVE_PATH" \
            || error "Download failed."
    else
        wget -q --show-progress \
            "$DOWNLOAD_URL" -O "$ARCHIVE_PATH" \
            || error "Download failed."
    fi
fi

# --- Extract ---

info "Extracting archive..."
mkdir -p "${TMP_DIR}/extracted"
tar -xzf "$ARCHIVE_PATH" -C "${TMP_DIR}/extracted" \
    || error "Failed to extract archive."

# --- Install ---

mkdir -p "$INSTALL_DIR"
cp -r "${TMP_DIR}/extracted/." "${INSTALL_DIR}/" \
    || error "Failed to copy files."
chmod +x "${INSTALL_DIR}/modernize"

info "Installed modernize to ${INSTALL_DIR}/modernize"

# --- Add to PATH ---

add_to_profile() {
    PROFILE_FILE="$1"
    if [ -f "$PROFILE_FILE" ] || [ "$2" = "create" ]; then
        if ! grep -qF "$INSTALL_DIR" "$PROFILE_FILE" 2>/dev/null; then
            printf '\n# Added by modernize installer\nexport PATH="$PATH:%s"\n' \
                "$INSTALL_DIR" >> "$PROFILE_FILE"
            info "Added $INSTALL_DIR to PATH in $PROFILE_FILE"
            PROFILE_UPDATED="$PROFILE_FILE"
        else
            info "$PROFILE_FILE already contains $INSTALL_DIR in PATH"
        fi
    fi
}

case ":${PATH}:" in
    *":${INSTALL_DIR}:"*)
        info "$INSTALL_DIR is already in PATH"
        ;;
    *)
        info "Adding $INSTALL_DIR to PATH..."
        # Detect shell and update the appropriate profile
        CURRENT_SHELL=$(basename "${SHELL:-sh}")
        case "$CURRENT_SHELL" in
            zsh)  add_to_profile "$HOME/.zshrc"  "create" ;;
            bash) add_to_profile "$HOME/.bashrc"       ;;
            *)
                add_to_profile "$HOME/.bashrc"
                add_to_profile "$HOME/.profile" "create"
                ;;
        esac

        if [ -n "$PROFILE_UPDATED" ]; then
            printf '\033[0;33m[info]\033[0m  Run the following to use modernize in this session:\n'
            printf '        source %s\n' "$PROFILE_UPDATED"
        fi
        ;;
esac

printf '\n'
info "Installation complete! Run 'modernize' to get started."
