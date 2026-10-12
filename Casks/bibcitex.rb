cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.8.1"
  sha256 arm:   "cb2b54d4756ce7c9150887261f1074e0c557ca29ca3233872ed12042779755d2",
         intel: "b804729587b0cedd0bea3ada9a45be054826bf3166fb46c276a189304305be12"

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
