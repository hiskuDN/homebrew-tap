class Tinynudge < Formula
  desc "Tiny notifier for AI coding agents — banners + sound with click-to-focus"
  homepage "https://github.com/hiskuDN/tinynudge"
  version "1.1.0"

  on_arm do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.0/tinynudge-arm64.tar.gz"
    sha256 "0a25c8505c74a395370127d8898fc5d530af73bc1553e53f119f873385e57b3b"
  end

  on_intel do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.0/tinynudge-x86_64.tar.gz"
    sha256 "9d400e4bab1ab8b68da238143d892223bf354210932bc3061586693621eed147"
  end

  def install
    prefix.install "tinynudge.app"
  end

  def caveats
    <<~EOS
      tinynudge.app has been installed to:
        #{prefix}/tinynudge.app

      The installer (./install.sh) will find it automatically.
      Or add it to your Applications folder:
        cp -r #{prefix}/tinynudge.app ~/Applications/tinynudge.app
    EOS
  end

  test do
    assert_predicate prefix/"tinynudge.app/Contents/MacOS/tinynudge", :executable?
  end
end
