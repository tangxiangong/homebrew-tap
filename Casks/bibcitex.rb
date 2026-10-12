cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.8.1"
  sha256 arm:   "d7b69ee454de96e7f914000f087316ace120949b9c842a890431767934a57ac7",
         intel: "89c366003f2159b5251d64af8613c477b407b7e6d8dd44d8044a7f3dc8c7a59d"

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
