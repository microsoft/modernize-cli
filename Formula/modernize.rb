class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.77"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.77/modernize_1.0.77_darwin_x64.tar.gz"
      sha256 "30e993df401d7214073e812987e244d6c980eb271456f2ad97a106b2b88e09bf"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.77/modernize_1.0.77_darwin_arm64.tar.gz"
      sha256 "3ab5e1bf5105e4aac868c78f4e2089c505b0d6a1b460cdd48104eb26034beb16"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.77/modernize_1.0.77_linux_x64.tar.gz"
      sha256 "a5dea7295cf9058ef62560eb8241b0074461df14f76f3bf3f4991841d9c30a3a"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.77/modernize_1.0.77_linux_arm64.tar.gz"
      sha256 "1dcd4a0e46d9f4a89d5165fd80a0eb95163272da918c1325aa5a74bd69d32c9d"
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

