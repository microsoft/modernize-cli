cask "modernize" do
  arch arm: "arm64", intel: "x64"

  version "1.0.95-rc.1"
  sha256 arm:   "5516691acc6073af51e14e749fed208f56bea63a12300f593dfa647c25b692d2",
         intel: "cc52255fb15e63107440ece069f4abc3a0cbf03c8d632edc9150901b7277b7f1"

  url "https://github.com/microsoft/modernize-cli/releases/download/v#{version}/modernize_#{version}_darwin_#{arch}.tar.gz"
  name "Modernize"
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"

  depends_on formula: "gh"
  depends_on :macos

  binary "modernize"
end
