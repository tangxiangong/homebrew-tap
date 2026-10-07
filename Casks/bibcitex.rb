cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.7.2"
  sha256 arm:   "5936467d27ad6b171688b38dc0cbdd42bd246b2a8f69ebf2cec88d1cfbe2e6e4",
         intel: "e555e0e176f692764041d5d026ddfbe04c4a1936b5ef15ae280703ba5a9e256d"

  url "https://github.com/tangxiangong/bibcitex/releases/download/v#{version}/BibCiTeX-#{version}-macos-#{arch}.app.zip"
  name "BibCiTeX"
  desc "BibTeX reference search and citation tool"
  homepage "https://github.com/tangxiangong/bibcitex"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "BibCiTeX.app"
end
