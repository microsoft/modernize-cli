class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.95"

  if Hardware::CPU.intel?
    url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.95/modernize_1.0.95_linux_x64.tar.gz"
    sha256 "18e14c2a206d8b69af9d140cef200802e9e4fbd68330fb86141d4e9425a7c3f3"
  elsif Hardware::CPU.arm?
    url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.95/modernize_1.0.95_linux_arm64.tar.gz"
    sha256 "a587b272375f4c51ebf740e88400f486ce938abdfdc270c1dea1a1b2328b3ffc"
  end

  license "Proprietary"
  depends_on :linux
  depends_on "gh"

  def install
    libexec.install "modernize"
    libexec.install "runtimes"
    bin.install_symlink libexec/"modernize"
  end

  test do
    version_output = shell_output "#{bin}/modernize --version"
    assert_equal 0, $CHILD_STATUS.exitstatus
    assert_match version.to_s, version_output
  end
end

