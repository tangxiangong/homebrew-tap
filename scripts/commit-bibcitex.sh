#!/usr/bin/env bash
set -euo pipefail
: "${VERSION:?VERSION is required}"
ruby -c Casks/bibcitex.rb
git diff --check
git status --short
git diff
git add Casks/bibcitex.rb
git diff --staged
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
cat > "$RUNNER_TEMP/commit-message" <<EOF_MESSAGE
chore(cask): update BibCiTeX to $VERSION

Summary:
- Update BibCiTeX version and both architecture checksums

Rationale:
- Follow the newest complete stable upstream release
- Verify downloaded archives against release metadata and GitHub digests

Tests:
- ruby scripts/update-bibcitex-test.rb
- ruby -c Casks/bibcitex.rb
- SHA-256 and size verification for both downloaded archives
- git diff --check

Co-authored-by: Codex <noreply@openai.com>
EOF_MESSAGE
git commit -F "$RUNNER_TEMP/commit-message"
git push origin HEAD:main
