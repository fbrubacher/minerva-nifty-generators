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
      m.file     "js_css_settings.yml",  "config/js_css_settings.yml"
      m.file     "javascripts/lightwindow.js",  "public/javascripts/lightwindow.js"
      m.file     "javascripts/multifile.js",  "public/javascripts/multifile.js"
      m.file     "javascripts/tablesort.js",  "public/javascripts/tablesort.js"
      m.file     "javascripts/underscore.js",  "public/javascripts/underscore.js"
      m.file     "javascripts/fastinit.js",  "public/javascripts/fastinit.js"
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
