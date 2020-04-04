require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNTrtc"
  s.version      = package['version']
  s.summary      = package['description']

  s.homepage     = package['homepage']
  s.license      = package['license']
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = package['author']
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chinsyo/react-native-trtc.git", :tag => "v#{s.version}" }
  s.preserve_paths = 'ios/TXLiteAVSDK_TRTC/**'
  s.vendored_libraries = 'ios/TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.a'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/ios/TXLiteAVSDK_TRTC/**" }
  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
