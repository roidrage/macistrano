#
#  keychain.rb
#  macistrano
#
#  Created by Pom on 11.05.08.
#  Copyright (c) 2008 Paperplanes Software Development. All rights reserved.
#
require 'osx/cocoa'
OSX.require_framework 'Security'

class Keychain
  include OSX
  
  def self.add_password host
    identifier = build_identifier(host)
    result = OSX::SecKeychainAddGenericPassword(nil, identifier.length, identifier, host.username.length, host.username, host.password.length, host.password, nil)
  end
  
  def self.find_password host
    identifier = build_identifier(host)
    status, *password_data = OSX::SecKeychainFindGenericPassword(nil, identifier.length, identifier, host.username.length, host.username)
    if status == 0
      length = password_data.shift
      host.password = password_data.shift.bytestr(length)
      true
    else
      false
    end
  end
  
  def self.remove_password host
    if find_password(host)
      ref = find_reference(host)
      OSX::SecKeychainItemDelete(ref) == 0
    end
  end
  
  def self.find_reference host
    identifier = build_identifier(host)
    status, *password = OSX::SecKeychainFindGenericPassword(nil, identifier.length, identifier, host.username.length, host.username)
    password[2]
  end
  
  def self.build_identifier(host)
    "Macistrano: #{host.url}"
  end
end
