class NiftyConfigGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || 'app'
  end
  
  def manifest
    record do |m|
      m.directory 'config/initializers'

      m.template "load_config.rb", "config/initializers/load_#{file_name}_config.rb"
      if Rails.version <= '2.3.4'
        m.file     "preinitializer.rb", "config/preinitializer.rb"
      end
      m.file     "gemfile", "gemfile"
      m.file     "config.yml",  "config/#{file_name}_config.yml"
    end
  end
  
  def file_name
    @name.underscore
  end
  
  def constant_name
    @name.underscore.upcase
  end

  protected
    def banner
      <<-EOS
Creates config and loader files.

USAGE: #{$0} #{spec.name} [config_name]
EOS
    end
end
