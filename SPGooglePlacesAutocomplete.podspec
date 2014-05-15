Pod::Spec.new do |s|
  s.name         = "SPGooglePlacesAutocomplete"
  s.version      = "1.0.2"
  s.summary      = "An objective-c wrapper around the Google Places autocomplete API. Includes sample application emulating the Maps app."
  s.homepage     = "https://github.com/chrischentickbox/SPGooglePlacesAutocomplete"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Matej Bukovinski" => "matej@bukovinski.com", "Chris Chen" => "chrischen79@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/chrischentickbox/SPGooglePlacesAutocomplete.git", :tag => '1.0.2'}
  s.source_files  = 'Library/*.{h,m}'
  s.frameworks = 'CoreLocation'
  s.requires_arc = true
end
