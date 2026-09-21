class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.76"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.76/modernize_1.0.76_darwin_x64.tar.gz"
      sha256 "d44e2b5047ea6dede896a0e70ab7ad12bd4db9e9b6946157fd8efe03eac8bac4"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.76/modernize_1.0.76_darwin_arm64.tar.gz"
      sha256 "bc3b187623370bafa58ab1a0bfe6eb5b2c239305946ee71d0e30896cc6a65714"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.76/modernize_1.0.76_linux_x64.tar.gz"
      sha256 "adbd88d169fe9b23dff1eb06617644a6892be080f6af03dd0c4f8381ba2d1b5c"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.76/modernize_1.0.76_linux_arm64.tar.gz"
      sha256 "913046665d8538315b012a215d7c6ed2e40e41a4a92fa134c212316eec216ae1"
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

