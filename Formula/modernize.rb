class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.211/modernize_0.0.211_darwin_x64.tar.gz"
      sha256 "472e12f37471f25de62431200b7466629a210a9d99854f979bc1c9bf988f1ee8"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.211/modernize_0.0.211_darwin_arm64.tar.gz"
      sha256 "04f23f2c57525a851ab270e3ae1c54fd5cfefd261279d711bba6c5e251df89c2"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.211/modernize_0.0.211_linux_x64.tar.gz"
      sha256 "3b417f9df6cbedc2976655d2ca1ad4f867f49acd8e58ed18c5a1c027912e64cf"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.211/modernize_0.0.211_linux_arm64.tar.gz"
      sha256 "a587212eb4378f94fc3a4f827aa72f8aa70d97b758b107130a8e7f3562a83dac"
    end
  end

  version "0.0.211"

  license :cannot_represent
  # Proprietary — see https://github.com/microsoft/modernize-cli/blob/HEAD/LICENSE.txt

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