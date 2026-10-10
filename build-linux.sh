#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
expected_branch="${1:-sdf-toggle}"
current_branch="$(git -C "$repo_root" branch --show-current)"

if [[ "$current_branch" != "$expected_branch" ]]; then
    printf 'Expected branch %s, but currently on %s. Switch branches and rerun.\n' \
        "$expected_branch" "${current_branch:-detached HEAD}" >&2
    exit 1
fi

unity="${UNITY_EDITOR:-}"
if [[ -z "$unity" ]]; then
    for candidate in \
        "$HOME/Unity/Hub/Editor/6000.3.13f1/Editor/Unity" \
        "/opt/unity/Editor/Unity" \
        "/opt/Unity/Editor/Unity"; do
        if [[ -x "$candidate" ]]; then
            unity="$candidate"
            break
        fi
    done
fi

if [[ -z "$unity" || ! -x "$unity" ]]; then
    printf 'Unity 6000.3.13f1 was not found. Set UNITY_EDITOR to its executable path.\n' >&2
    exit 1
fi

cd "$repo_root"
"$unity" \
    -batchmode \
    -quit \
    -projectPath "$repo_root" \
    -buildTarget StandaloneLinux64 \
    -executeMethod SimpleEditorUtils.BuildLinuxForTesting \
    -logFile -

player="$repo_root/build/Linux64/ChroMapper"
if [[ ! -x "$player" ]]; then
    printf 'Unity returned without producing an executable at %s\n' "$player" >&2
    exit 1
fi

exec "$player"
