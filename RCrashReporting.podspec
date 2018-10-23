Pod::Spec.new do |s|
  s.name         = "RCrashReporting"
  s.version      = "0.4.0"
  s.authors      = "Rakuten Ecosystem Mobile"
  s.summary      = "Crash Reporting for mobile applications"
  s.homepage     = "https://github.com/rakutentech/ios-crash-reporting"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/rakutentech/ios-crash-reporting.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.xcconfig     = {
    'CLANG_ENABLE_MODULES'                                  => 'YES',
    'CLANG_MODULES_AUTOLINK'                                => 'YES',
    'GCC_C_LANGUAGE_STANDARD'                               => 'gnu11',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'OTHER_CFLAGS'                                          => "'-DRCR_SDK_VERSION=#{s.version.to_s}'"
  }

  s.source_files = "RCrashReporting/Classes/**/*.{h,m}"
  s.module_map = 'RCrashReporting/RCrashReporting.modulemap'
  s.dependency 'KSCrash/Recording'
end
# vim:syntax=ruby:et:sts=2:sw=2:ts=2:ff=unix:
