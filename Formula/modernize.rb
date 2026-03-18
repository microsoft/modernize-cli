class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"
  version "0.0.246"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_darwin_x64.tar.gz"
      sha256 "b18a7de04f36cb0236f122af0417110f9b2a7f7daa03ef6a130e8d837de7754e"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_darwin_arm64.tar.gz"
      sha256 "786c7ae517a19c329702e977c0e871e3b503b31a87bc04f8024fabb18f6c7629"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_linux_x64.tar.gz"
      sha256 "fdc582131e933f8fbe978da7601c9d2cdf40044305adc93c668ab501dee11f58"
    elsif Hardware::CPU.arm?
      url "https://github.com/microsoft/modernize-cli/releases/download/v0.0.246/modernize_0.0.246_linux_arm64.tar.gz"
      sha256 "426b254c7808d8cdd482468b754815872993a85b4b9b2ed14871438700aa15fa"
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