cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.7.1"
  sha256 arm:   "c8a7a596262fd66b26e5f9c1c07f9a7b67b91876d0174ef293c423fb0aa519fb",
         intel: "648d0433616a264b618f9df3343247232d09bba49f02c926986a6a3c0c24f82c"

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
