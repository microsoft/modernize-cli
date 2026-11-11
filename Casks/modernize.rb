cask "modernize" do
  arch arm: "arm64", intel: "x64"

  version "1.0.95"
  sha256 arm:   "3a24c4ce1b0a0eae291c8e818388c966e5fc9b5fb05e17e5d091a6577e821608",
         intel: "a9f3a510d184b2c3760d873df0013a67564535dab9396e52e6c7a7ccd7969b5d"

  url "https://github.com/microsoft/modernize-cli/releases/download/v#{version}/modernize_#{version}_darwin_#{arch}.tar.gz"
  name "Modernize"
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/microsoft/modernize-cli"

  depends_on formula: "gh"
  depends_on :macos

  binary "modernize"
end
