Pod::Spec.new do |s|
  s.name             = 'PlayerTesting'
  s.version          = '2.2.0'
  s.summary          = '🚀 Automatically test your streams with the Bitmovin Player.'
  s.description      = '🚀 Automatically test your streams with the Bitmovin Player.'
  s.homepage         = 'https://github.com/bitmovin-engineering/player-ios-testing-framework'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Bitmovin' => 'david.steinacher@bitmovin.com' }
  s.source           = { git: 'https://github.com/bitmovin-engineering/player-ios-testing-framework.git', tag: s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.tvos.deployment_target = '14.0'

  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.9'

  s.dependency 'BitmovinPlayerCore', '~> 3.77.0'
  s.dependency 'Nimble', '~> 12'
  s.dependency 'Quick', '~> 7'
  s.dependency 'OHHTTPStubs/Swift', '~> 9'
end
