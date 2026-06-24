class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.62"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.62/modernize_1.0.62_darwin_x64.tar.gz"
      sha256 "9379c12a839772057c0dd980e061cc8c7f3f6d57e83c5e89d2422d26aac40506"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.62/modernize_1.0.62_darwin_arm64.tar.gz"
      sha256 "7712fac9e1e2871083204bfb848cb34f84f7a9aa67127d63699110ef0dd22dae"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.62/modernize_1.0.62_linux_x64.tar.gz"
      sha256 "bc9e63b6b6e08566d7612c5b7e52369545dd680a5ff86a815975fbc4da339080"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.62/modernize_1.0.62_linux_arm64.tar.gz"
      sha256 "ac01a66565475ff36ce843fc6e0023bf7e193a08dc04252ae4ff8241e94c0f7a"
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

