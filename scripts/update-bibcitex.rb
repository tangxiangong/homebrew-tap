require "json"
require "digest"
require "open3"
require "tmpdir"

module BibcitexUpdate
  REPOSITORY = "tangxiangong/bibcitex".freeze
  ARCHITECTURES = %w[arm64 x86_64].freeze

  def self.version(value)
    match = /\A(?:v)?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\z/.match(value)
    match && match.captures.map(&:to_i)
  end

  def self.select_release(releases, current)
    releases.select do |release|
      candidate = version(release.fetch("tag_name"))
      !release["draft"] && !release["prerelease"] && candidate &&
        (candidate <=> version(current)) == 1 &&
        release.fetch("assets").any? { |asset| asset["name"] == "release.json" }
    end.max_by { |release| version(release.fetch("tag_name")) }
  end

  def self.verify(manifest, release, directory)
    number = release.fetch("tag_name").delete_prefix("v")
    raise "Manifest version or channel mismatch" unless manifest["version"] == number && manifest["channel"] == "stable"

    ARCHITECTURES.map do |architecture|
      name = "BibCiTeX-#{number}-macos-#{architecture}.app.zip"
      asset = release.fetch("assets").find { |item| item["name"] == name }
      raise "Missing release asset #{name}" unless asset
      metadata = manifest.fetch("assets").fetch(name)
      path = File.join(directory, name)
      digest = Digest::SHA256.file(path).hexdigest
      raise "Size mismatch for #{name}" unless File.size(path) == metadata.fetch("size") && File.size(path) == asset.fetch("size")
      raise "Checksum mismatch for #{name}" unless digest == metadata.fetch("sha256") && "sha256:#{digest}" == asset.fetch("digest")
      digest
    end
  end

  def self.gh(*arguments)
    output, error, status = Open3.capture3("gh", *arguments)
    raise "GitHub request failed: #{error}" unless status.success?
    output
  end

  def self.run
    path = File.expand_path("../Casks/bibcitex.rb", __dir__)
    original = File.read(path)
    current = original.match(/^  version "([^"]+)"$/)&.captures&.first
    raise "Unsupported cask version" unless current && version(current)
    pages = JSON.parse(gh("api", "--paginate", "--slurp", "repos/#{REPOSITORY}/releases?per_page=100"))
    release = select_release(pages.flatten(1), current)
    unless release
      puts "No newer complete stable release"
      return
    end
    number = release.fetch("tag_name").delete_prefix("v")
    Dir.mktmpdir("bibcitex-tap-") do |directory|
      patterns = ["release.json", *ARCHITECTURES.map { |arch| "BibCiTeX-#{number}-macos-#{arch}.app.zip" }]
      gh("release", "download", release.fetch("tag_name"), "--repo", REPOSITORY, "--dir", directory,
         *patterns.flat_map { |pattern| ["--pattern", pattern] })
      manifest = JSON.parse(File.read(File.join(directory, "release.json")))
      arm, intel = verify(manifest, release, directory)
      checksum = /^  sha256 arm:   "[0-9a-f]{64}",\n         intel: "[0-9a-f]{64}"$/
      raise "Unexpected cask checksum layout" unless original.match?(checksum)
      updated = original.sub(/^  version "[^"]+"$/, "  version \"#{number}\"")
                        .sub(checksum, "  sha256 arm:   \"#{arm}\",\n         intel: \"#{intel}\"")
      File.write(path, updated)
      puts "Updated BibCiTeX #{current} -> #{number}"
      File.open(ENV.fetch("GITHUB_OUTPUT"), "a") { |file| file.puts("version=#{number}") } if ENV["GITHUB_OUTPUT"]
    end
  end
end

BibcitexUpdate.run if $PROGRAM_NAME == __FILE__
