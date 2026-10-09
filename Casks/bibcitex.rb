cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.7.3"
  sha256 arm:   "8a3d575e0f9ce41a2f14502cdd252a8935dedd4def9fe80b9f63be50ed4e96a8",
         intel: "f936c136c866f59cc6869590c47c8038ad1c455cf57814b150dae3133c77bcc8"

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
