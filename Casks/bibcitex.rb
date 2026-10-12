cask "bibcitex" do
  arch arm: "arm64", intel: "x86_64"

  version "0.8.0"
  sha256 arm:   "9e6f8984509a36c36614f3116282fbc411dd19565d6305fd7bebcf6658a095aa",
         intel: "144c248beb49c588010e54090224b25d742778b848642be3cb975f9ea2f836c1"

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
