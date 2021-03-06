class NiftyLayoutGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || 'application'
  end
  
  def manifest
    record do |m|
      m.directory 'app/views/layouts'
      m.directory 'public/stylesheets'
      m.directory 'app/helpers'
      
      m.directory 'public/stylesheets/sass'
      m.template "layout.html.haml", "app/views/layouts/#{file_name}.html.haml"
      m.file     "stylesheet.sass",  "public/stylesheets/sass/#{file_name}.sass"
      m.file "helper.rb", "app/helpers/layout_helper.rb"
      m.file "general.sass", "public/stylesheets/sass/general.sass"
      m.file "layers.sass", "public/stylesheets/sass/layers.sass"
      m.file "nav.sass", "public/stylesheets/sass/nav.sass"
      m.file "forms.sass", "public/stylesheets/sass/forms.sass"
      m.file "table.sass", "public/stylesheets/sass/tables.sass"
    end
  end
  
  def file_name
    @name.underscore
  end

  protected

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--haml", "Generate HAML for view, and SASS for stylesheet.") { |v| options[:haml] = v }
    end

    def banner
      <<-EOS
Creates generic layout, stylesheet, and helper files.

USAGE: #{$0} #{spec.name} [layout_name]
EOS
    end
end
