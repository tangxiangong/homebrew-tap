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

The **Update BibCiTeX** workflow checks upstream releases hourly and can also be
run manually from Actions. GitHub may delay scheduled runs. No cross-repository
secret is needed: the workflow reads public upstream assets and uses this tap's
`GITHUB_TOKEN` to commit updates to `main`.

Only newer stable releases containing the final `release.json` publication
marker qualify. The updater downloads both macOS `.app.zip` archives, verifies
their sizes and SHA-256 hashes against the manifest and GitHub asset digests, and
then updates the cask. Drafts, prereleases, incomplete releases and downgrades are
ignored; missing or mismatched assets fail the job without changing the cask.
The repository must allow Actions to push to `main`. GitHub may disable scheduled
workflows after 60 days without repository activity; re-enable the workflow in
Actions if that occurs.

Run the non-UI validation tests with `ruby scripts/update-bibcitex-test.rb`.
