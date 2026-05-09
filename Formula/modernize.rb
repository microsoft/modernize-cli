class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "0.0.366"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.366/modernize_0.0.366_darwin_x64.tar.gz"
      sha256 "695a61e84b1491e36d0260b979ab90babde84519db3de245a1c8e46ee9eebdf1"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.366/modernize_0.0.366_darwin_arm64.tar.gz"
      sha256 "1b9d9383bcaea28c0dc24208eabf568f455e047fbc8372b461df7819b3e131d5"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.366/modernize_0.0.366_linux_x64.tar.gz"
      sha256 "63054c8cf7517b66555f0df897e9c8d32707366e44c51c01d108e556deeb0d44"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.366/modernize_0.0.366_linux_arm64.tar.gz"
      sha256 "d18568137f8c163973d28f88e8247fd8ffb8286cc503ea5a3456d29260c4e493"
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

