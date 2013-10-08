name             "cdh"
maintainer       "DiUS Computing"
maintainer_email "csmith@dius.com.au"
description      ""
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '0.0.0'

%w{ ubuntu debian }.each do |os|
  supports os
end

depends 'apt'