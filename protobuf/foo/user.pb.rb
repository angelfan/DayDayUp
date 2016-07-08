# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'
require 'protobuf/rpc/service'

module Foo

  ##
  # Message Classes
  #
  class User < ::Protobuf::Message; end
  class UserRequest < ::Protobuf::Message; end
  class UserList < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class User
    optional :string, :first_name, 1
    optional :string, :last_name, 2
  end

  class UserRequest
    optional :string, :email, 3
  end

  class UserList
    repeated ::Foo::User, :users, 4
  end


  ##
  # Service Classes
  #
  class UserService < ::Protobuf::Rpc::Service
    rpc :find, ::Foo::UserRequest, ::Foo::UserList
  end

end

