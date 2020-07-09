

Pod::Spec.new do |s|


  s.name         = "CCLivePushSDK"
  s.version      = '2.3.0'
  s.summary      = "An iOS SDK for CCPUSH Service"

  s.description  = <<-DESC
	It's  an iOS SDK for CCPUSH Service，It helps iOS developers to use CCPUSH easier.
                   DESC
  s.homepage     = "https://github.com/CCVideo"

  s.license      = 'Apache License, Version 2.0'

  s.author             = { "CCPUSH" => "service@bokecc.com" }

  s.platform     = :ios, "9.0"


  s.source       = { :git => "https://github.com/CCVideo/Live_iOS_Push_SDK.git", :tag => s.version.to_s }

  s.vendored_frameworks = 'SDK/*.{framework}'
 s.resource = 'SDK/CCBundle.bundle'

end
