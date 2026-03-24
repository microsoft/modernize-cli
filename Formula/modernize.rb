class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "0.0.252"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.252/modernize_0.0.252_darwin_x64.tar.gz"
      sha256 "b631eb339a0ba39f5f60dab3d9bbe59590832289402361541d4c0908f3bb8d58"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.252/modernize_0.0.252_darwin_arm64.tar.gz"
      sha256 "5a81d3c46436fa219104768cfb62b04eaf6ca17ade2e56477be9605c4685bff1"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.252/modernize_0.0.252_linux_x64.tar.gz"
      sha256 "b211a6a76223afc6ca4cd7ffddd9405482f772282278c405e3b07704700ef167"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.252/modernize_0.0.252_linux_arm64.tar.gz"
      sha256 "114d9a2fcaf6631905f530ce7b1487fec043fccaaf21fbcf0eb717f997588950"
    end
  end

  license "Proprietary"
  depends_on "gh"

  def install
    libexec.install "modernize"
    libexec.install "runtimes"
    bin.install_symlink libexec/"modernize"
  end

  test do
    version_output = shell_output "#{bin}/modernize --version"
    assert_equal 0, $CHILD_STATUS.exitstatus
    assert_match "modernize", version_output
  end
end

