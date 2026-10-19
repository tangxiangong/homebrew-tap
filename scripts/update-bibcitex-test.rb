require "minitest/autorun"
require_relative "update-bibcitex"

class BibcitexUpdateTest < Minitest::Test
  def release(tag, **overrides)
    { "tag_name" => tag, "draft" => false, "prerelease" => false,
      "assets" => [{ "name" => "release.json" }] }.merge(overrides.transform_keys(&:to_s))
  end

  def test_selects_highest_complete_stable_version_without_downgrade
    releases = [release("v0.7.9"), release("v0.7.10"), release("v0.8.0", assets: []),
                release("v1.0.0-beta.1"), release("v1.0.0", draft: true), release("v2.0.0", prerelease: true)]
    assert_equal "v0.7.10", BibcitexUpdate.select_release(releases, "0.7.1")["tag_name"]
    assert_nil BibcitexUpdate.select_release(releases, "0.7.10")
    assert_nil BibcitexUpdate.select_release(releases, "0.9.0")
  end

  def test_validates_both_archive_bytes_before_accepting_release
    Dir.mktmpdir do |directory|
      candidate = release("v0.7.2")
      manifest = { "version" => "0.7.2", "channel" => "stable", "assets" => {} }
      BibcitexUpdate::ARCHITECTURES.each do |arch|
        name = "BibCiTeX-0.7.2-macos-#{arch}.app.zip"
        File.write(File.join(directory, name), arch)
        digest = Digest::SHA256.hexdigest(arch)
        manifest["assets"][name] = { "sha256" => digest, "size" => arch.bytesize }
        candidate["assets"] << { "name" => name, "digest" => "sha256:#{digest}", "size" => arch.bytesize }
      end
      assert_equal 2, BibcitexUpdate.verify(manifest, candidate, directory).size
      manifest["channel"] = "beta"
      assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, directory) }
      manifest["channel"] = "stable"
      manifest["version"] = "0.7.3"
      assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, directory) }
      manifest["version"] = "0.7.2"
      candidate["assets"].last["digest"] = "sha256:#{'0' * 64}"
      assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, directory) }
      candidate["assets"].last["digest"] = "sha256:#{Digest::SHA256.hexdigest('x86_64')}"
      File.write(File.join(directory, "BibCiTeX-0.7.2-macos-x86_64.app.zip"), "broken")
      assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, directory) }
    end
  end

  def test_validates_universal_archive_without_requiring_split_archives
    Dir.mktmpdir do |directory|
      candidate = release("v0.8.3")
      name = "BibCiTeX-0.8.3-macos-universal.app.zip"
      bytes = "universal"
      digest = Digest::SHA256.hexdigest(bytes)
      File.write(File.join(directory, name), bytes)
      candidate["assets"] << { "name" => name, "digest" => "sha256:#{digest}", "size" => bytes.bytesize }
      manifest = { "version" => "0.8.3", "channel" => "stable",
                   "assets" => { name => { "sha256" => digest, "size" => bytes.bytesize } } }
      assert_equal ["universal"], BibcitexUpdate.architectures(candidate)
      assert_equal({ "universal" => digest }, BibcitexUpdate.verify(manifest, candidate, directory))
      File.write(File.join(directory, name), "corrupted")
      assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, directory) }
    end
  end

  def test_partial_universal_release_does_not_fall_back_to_split_archives
    candidate = release("v0.8.3", assets: [{ "name" => "appcast-universal.xml" }])
    assert_equal ["universal"], BibcitexUpdate.architectures(candidate)
    manifest = { "version" => "0.8.3", "channel" => "stable", "assets" => {} }
    assert_raises(RuntimeError) { BibcitexUpdate.verify(manifest, candidate, "/unused") }
  end

  def test_cask_migrates_to_universal_and_accepts_later_updates
    original = File.read(File.expand_path("../Casks/bibcitex.rb", __dir__))
    checksum = "a" * 64
    updated = BibcitexUpdate.update_cask(original, "0.8.3", { "universal" => checksum })
    assert_includes updated, '  version "0.8.3"'
    assert_includes updated, "  sha256 \"#{checksum}\""
    assert_includes updated, '-macos-universal.app.zip"'
    refute_includes updated, "  arch "
    refute_includes updated, '#{arch}'
    assert_includes updated, '  auto_updates true'
    assert_includes updated, '  app "BibCiTeX.app"'
    next_checksum = "b" * 64
    later = BibcitexUpdate.update_cask(updated, "0.8.4", { "universal" => next_checksum })
    assert_includes later, '  version "0.8.4"'
    assert_includes later, "  sha256 \"#{next_checksum}\""
    refute_includes later, checksum
  end

  def test_split_release_cask_updates_remain_supported
    original = File.read(File.expand_path("../Casks/bibcitex.rb", __dir__))
    updated = BibcitexUpdate.update_cask(original, "0.8.3", { "arm64" => "a" * 64, "x86_64" => "b" * 64 })
    assert_includes updated, '  version "0.8.3"'
    assert_includes updated, '  arch arm: "arm64", intel: "x86_64"'
    assert_includes updated, '-macos-#{arch}.app.zip"'
    assert_includes updated, "  sha256 arm:   \"#{'a' * 64}\",\n         intel: \"#{'b' * 64}\""
  end
end
