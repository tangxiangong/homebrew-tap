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
end
