class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.95-rc.1"

  if Hardware::CPU.intel?
    url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.95-rc.1/modernize_1.0.95-rc.1_linux_x64.tar.gz"
    sha256 "83e4b94a221acab0a7899fdc851e8c87d68e6deb597140181170e3bada57fdf0"
  elsif Hardware::CPU.arm?
    url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.95-rc.1/modernize_1.0.95-rc.1_linux_arm64.tar.gz"
    sha256 "f8b9a7b13ce5b645b8f7fd66d05a757986be9c3102e1eeb7b9c84147eefb2a27"
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

