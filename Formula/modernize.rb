class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.91"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.91/modernize_1.0.91_darwin_x64.tar.gz"
      sha256 "4917debaeddfb99e4b4dbd5aa37c01167ad427db6575c5aeba2c5216ab689d72"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.91/modernize_1.0.91_darwin_arm64.tar.gz"
      sha256 "a6a8997ff4121826614941597a1c101b811a7ab4097023b812eaa88bd58154a2"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.91/modernize_1.0.91_linux_x64.tar.gz"
      sha256 "4a086ec18c2a71af4e580751544c7c49ca716c243c35b086fcb9c232482bf3ec"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.91/modernize_1.0.91_linux_arm64.tar.gz"
      sha256 "f8d3f1f1b67c547d7b6f9db25c7c8fa35cf327e96485495b9242cbe75d0bb7c6"
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

