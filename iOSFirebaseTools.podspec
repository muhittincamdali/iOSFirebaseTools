Pod::Spec.new do |s|
  s.name             = 'iOSFirebaseTools'
  s.version          = '1.0.0'
  s.summary          = 'Firebase integration toolkit for iOS with Analytics and Crashlytics.'
  s.description      = <<-DESC
    iOSFirebaseTools provides a Firebase integration toolkit for iOS. Features include
    Analytics helpers, Crashlytics integration, Remote Config management, Cloud Messaging
    setup, Firestore utilities, and Authentication helpers.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/iOSFirebaseTools'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/iOSFirebaseTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation'
end
