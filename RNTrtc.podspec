require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNTrtc"
  s.version      = package['version']
  s.summary      = package['description']

  s.homepage     = package['homepage']
  s.license      = package['license']
  s.author       = package['author']
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chinsyo/react-native-trtc.git", :tag => "v#{s.version}" }
  s.source_files = "ios/**.{h,m}"
  s.public_header_files = "**/*.h"
  s.requires_arc = true

  s.library      = "z"
  s.dependency "React"
  s.dependency "TXLiteAVSDK_TRTC"

end

  
