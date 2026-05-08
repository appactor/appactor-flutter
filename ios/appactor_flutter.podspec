#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint appactor_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'appactor_flutter'
  s.version          = '0.0.8'
  s.summary          = 'AppActor Flutter SDK — server-authoritative in-app purchase management.'
  s.description      = <<-DESC
AppActor Flutter plugin wrapping the native AppActorPlugin SDK for iOS.
                       DESC
  s.homepage         = 'https://github.com/appactor/appactor-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AppActor' => 'dev@appactor.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  s.dependency 'AppActorPlugin', '0.1.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
