require 'active_attr'
require 'logger'
require 'timeout'

module Interfaces

  # Base class for sources, sinks and filters.
  # Basically provides access to params, which is a Hash.
  # Default keys for params are :logger and :password_hider
  class Base
    include ActiveAttr::Model
    include ActiveModel::Validations
    include ActiveAttr::Logger

    attribute :password_hider, default: PasswordHider.new

    def initialize args = nil
      super
      self.class.logger = Logger.new(STDOUT) unless self.class.logger?
      raise ArgumentError, "#{errors.full_message}" unless valid? 
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
