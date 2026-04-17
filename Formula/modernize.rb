class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "0.0.293"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.293/modernize_0.0.293_darwin_x64.tar.gz"
      sha256 "11c57cb57d60322bc0df57601415afd2eaf4e1744acc85a319e7ea7eac7c9dbd"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.293/modernize_0.0.293_darwin_arm64.tar.gz"
      sha256 "ea2d46580236df9986d588fe79caa788c990097c706d6140e7bab23b34f525d4"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.293/modernize_0.0.293_linux_x64.tar.gz"
      sha256 "1ac620cec7d9492eba273ef67c902f51ee59bd13a30608c2c7982f9e391f4d22"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.293/modernize_0.0.293_linux_arm64.tar.gz"
      sha256 "d3a96a9da277536a0b13740c6dc18d1258a23d9186ddaf62bf234c68ab317c76"
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

