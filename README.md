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
