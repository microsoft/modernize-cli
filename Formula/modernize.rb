class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "1.0.93"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.93/modernize_1.0.93_darwin_x64.tar.gz"
      sha256 "82e913a282dcfde15d30011c54bf93b2b0369a929cf88485c51b75f9d40575f7"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.93/modernize_1.0.93_darwin_arm64.tar.gz"
      sha256 "7282e0cb4350e74410a7c5a7d2956d4cedbe119ef9fbfa4cafa48857d3e20c96"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.93/modernize_1.0.93_linux_x64.tar.gz"
      sha256 "5ad247208b98b937a772ecec3bb0aa1bb35bda45d63eebf6f0b6e4e2f3105236"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v1.0.93/modernize_1.0.93_linux_arm64.tar.gz"
      sha256 "8b401854da923d28c0db99a5ffbf82b8cc541de1c210dc0a8da5a7e86f877001"
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

