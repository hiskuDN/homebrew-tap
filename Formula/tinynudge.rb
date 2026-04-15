class Tinynudge < Formula
  desc "Tiny notifier for AI coding agents — banners + sound with click-to-focus"
  homepage "https://github.com/hiskuDN/tinynudge"
  version "1.1.0"

  on_arm do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.0/tinynudge-arm64.tar.gz"
    sha256 "64bccaeb3cec7576293209e6cc52d4dadabfcbdadbbbfc7c98c8a45834d45e16"
  end

  on_intel do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.0/tinynudge-x86_64.tar.gz"
    sha256 "6ce6fd475a7c0fe7697c196234d87a32eff2396aa604fc6402d4ef0cd6b3bc1e"
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
