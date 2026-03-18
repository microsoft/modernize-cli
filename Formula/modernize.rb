class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/galiacheng/modernize-cli"
  version "0.0.246"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_darwin_x64.tar.gz"
      sha256 "4f8f46bfac505479e707211eb5b06cb20d480b1e695656245f5a613d17ff0a55"
    elsif Hardware::CPU.arm?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_darwin_arm64.tar.gz"
      sha256 "8cb36ba5152948086b95478211b0ebaaa7204367b6fae7477a70fa38db83a9d0"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_linux_x64.tar.gz"
      sha256 "1264ecbc0187f5e59822f939702e96850069c28c62f6bd0e13622bae403ec381"
    elsif Hardware::CPU.arm?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_linux_arm64.tar.gz"
      sha256 "a11429f057eadf0d0ae909306907ac7e5dccf859e90d7763abc2d92334c198e4"
    end
  end

  license "Proprietary"

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

