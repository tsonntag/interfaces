require 'logger'
require 'timeout'

require 'logger'
require 'interfaces/password_hider'

module Interfaces

  # Base class for sources, sinks and filters.
  # Basically provides access to params, which is a Hash.
  # Default keys for params are :logger and :password_hider
  class Base
    attr_accessor :logger, :password_hider

    def initialize(params={})
      @params = params
      self.logger = params.delete(:logger){Logger.new(STDOUT)}
      self.password_hider = params.delete(:password_hider){PasswordHider.new}
      validate
    end

    # to be overwritten
    def validate
    end

    def params
      @params.dup
    end

    def dup(_params={})
      self.class.new params.merge(_params)
    end

    def method_missing(name,*args)
      return super unless @params.has_key?(name)
      @params[name]
    end

    def [](key)
      @params[key]
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

    protected

    # to be used by sublasses
    def validate_presence_of(*keys)
      missing = keys.reject{|key| @params.has_key?(key)}
      raise ArgumentError, "#{self}: missing @params #{missing.join(',')}" unless missing.empty?
    end

  end
end
