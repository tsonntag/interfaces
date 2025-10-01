require 'active_attr'
require 'active_model'
require 'logger'
require 'timeout'

module Interfaces

  # Base class for sources, sinks and filters.
  # Default keys for params are :logger and :password_hider
  class Base
    include ActiveAttr::Model
    include ActiveModel::Validations
    include ActiveAttr::Logger

    attribute :password_hider, default: PasswordHider.new

    def initialize args = {}
      self.logger = args.delete(:logger){Logger.new(STDOUT)}
      super
      raise ArgumentError, "#{errors.full_messages}" unless valid? 
    end

    def dup _attributes={}
      self.class.new attributes.merge(_attributes)
    end

    def to_s
      "#{self.class.name.split(/::/).last}"
    end

    def hide(s)
      password_hider.hide s
    end

    def unmask(s)
      password_hider.unmask s
    end

  end
end
