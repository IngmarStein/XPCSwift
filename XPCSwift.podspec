Pod::Spec.new do |s|

  s.name         = "XPCSwift"
  s.version      = "0.0.5"
  s.summary      = "Type safe Swift wrapper for libxpc"

  s.description  = <<-DESC
                   XPCSwift makes it easy to use xpc\_object\_t in a type safe manner.
                   DESC

  s.homepage     = "https://github.com/IngmarStein/XPCSwift"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = { "Ingmar Stein" => "IngmarStein@gmail.com" }
  s.social_media_url   = "https://twitter.com/IngmarStein"
  s.platform     = :osx, "10.9"
  s.source       = { :git => "https://github.com/IngmarStein/XPCSwift.git", :tag => "0.0.5" }

  s.source_files  = "XPCSwift/**/*.{h,swift}"
  s.public_header_files = "XPCSwift/**/*.h"

  s.requires_arc = true

end
