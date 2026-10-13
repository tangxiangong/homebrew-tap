cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.8.2"
  sha256 arm:   "81e50be9291b645b8c282bde17d25d8bf654984cb127da0c585b906da54a25e5",
         intel: "981e2eb17cf002c28eb06dfc6970ab7a50a4cec0ce3f729b194843a5d2547708"

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
