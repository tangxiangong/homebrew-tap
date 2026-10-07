# Homebrew Tap

## Install BibCiTeX

```sh
brew install --cask tangxiangong/tap/bibcitex
```

Supports Apple Silicon and Intel Macs running macOS 13 or later.
Packages come from the official [BibCiTeX releases](https://github.com/tangxiangong/bibcitex/releases).
The current release is ad-hoc signed and is not notarized. macOS may block first launch; see the upstream installation instructions. This cask does not bypass Gatekeeper or remove quarantine attributes.

## Update

BibCiTeX includes its own updater. To explicitly update through Homebrew:

```sh
brew update
brew upgrade --cask --greedy bibcitex
```

## Maintain

After publishing a stable upstream release, update `version` and both architecture-specific SHA-256 checksums in `Casks/bibcitex.rb`. Download and hash the actual `.app.zip` assets before updating the cask. Keep prereleases out of this cask.

```sh
brew livecheck --cask tangxiangong/tap/bibcitex
brew style Casks/bibcitex.rb
brew audit --cask tangxiangong/tap/bibcitex
```

### Automatic updates

The upstream **Update Homebrew tap** workflow runs immediately after the
**Release** workflow completes successfully. It checks out this tap using a
write-enabled deploy key scoped to this repository and updates the cask. There
is no scheduled polling. The tap's **Update BibCiTeX** workflow remains available
for manual recovery using its own `GITHUB_TOKEN`.

Only newer stable releases containing the final `release.json` publication
marker qualify. The updater downloads both macOS `.app.zip` archives, verifies
their sizes and SHA-256 hashes against the manifest and GitHub asset digests, and
then updates the cask. Drafts, prereleases, incomplete releases and downgrades are
ignored; missing or mismatched assets fail the job without changing the cask.
The repository must allow the deploy key and Actions to push to `main`.

Run the non-UI validation tests with `ruby scripts/update-bibcitex-test.rb`.
