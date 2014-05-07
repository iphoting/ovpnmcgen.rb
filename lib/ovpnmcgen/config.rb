require 'app_configuration'

module Ovpnmcgen
  @@config_file_name = '.ovpnmcgen.rb.yml'

  # attr_accessor :config, :config_file_name

  def configure(filename = @@config_file_name)

    @@config = AppConfiguration.new filename do
      prefix 'og'
    end

    # @@config = AppConfiguration[:ovpnmcgen]
  end

  def config
    @@config
  end

  module_function :configure, :config
end
