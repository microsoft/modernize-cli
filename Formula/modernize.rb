class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.74"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.74/modernize_1.0.74_darwin_x64.tar.gz"
      sha256 "9a2c1c4b98ad017d5f8c76bdd2b202469d9098a7c71c2c127d42973525815449"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.74/modernize_1.0.74_darwin_arm64.tar.gz"
      sha256 "5d6eefc021a4cfebc2a9774b12cf5170b09bf440f7a5537ccd2983763ae7a8e5"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.74/modernize_1.0.74_linux_x64.tar.gz"
      sha256 "1e1d7dae8530d503f7507f6f9c7df8a5e9d43088d3c3df532b4ea24e27926783"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.74/modernize_1.0.74_linux_arm64.tar.gz"
      sha256 "9a9a35607677eaecb1c7f6478d5286c9a911d8a188185c55024eae1a77b63ba6"
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

