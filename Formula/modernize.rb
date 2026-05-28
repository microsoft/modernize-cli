class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.15"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.15/modernize_1.0.15_darwin_x64.tar.gz"
      sha256 "be8baee33adf710be34a752f51bad565b6eea3fafac63a75476f8c47d9097277"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.15/modernize_1.0.15_darwin_arm64.tar.gz"
      sha256 "119794438ff58eac021d22850e8f9e0dfc78ec77badca478c41ecab78544d24b"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.15/modernize_1.0.15_linux_x64.tar.gz"
      sha256 "e359d7b5893a804bdd39126bba73a675610d988aa2b955831a0345d035845097"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.15/modernize_1.0.15_linux_arm64.tar.gz"
      sha256 "3ae2390fbb91d47a6aaa5561f7a341fe6bd98b8073eb962b0578726c954b4979"
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

