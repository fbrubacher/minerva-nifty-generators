class NiftyScaffoldGenerator < Rails::Generator::Base
  attr_accessor :name, :attributes, :controller_actions
  
  def override_base
    Rails::Generator::GeneratedAttribute.class_eval do 
       def field_type
        @field_type ||= case type
          when :integer, :float, :decimal   
            if /_id$/.match(name) 
              :select
            else
              :text_field
            end
          when :date            
            :calendar_date_select
          when :datetime 
            :calendar_date_select
          when :string                      then :text_field
          when :text                        then :text_area
          when :boolean                     then :check_box
          else
            :text_field
        end      
      end
    end
  end

  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.empty?
    
    @name = @args.first
    @controller_actions = []
    @attributes = []
    
    @args[1..-1].each do |arg|
      if arg == '!'
        options[:invert] = true
      elsif arg.include? ':'
        override_base
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":"))
      else
        @controller_actions << arg
        @controller_actions << 'create' if arg == 'new'
        @controller_actions << 'update' if arg == 'edit'
      end
    end
    
    @controller_actions.uniq!
    @attributes.uniq!
    
    if options[:invert] || @controller_actions.empty?
      @controller_actions = all_actions - @controller_actions
    end
    
    if @attributes.empty?
      options[:skip_model] = true # default to skipping model if no attributes passed
      if model_exists?
        model_columns_for_attributes.each do |column|
          @attributes << Rails::Generator::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new('name', 'string')
      end
    end
  end
  
  def manifest
    record do |m|
      unless options[:skip_model]
        m.directory "app/models"
        m.template "model.rb", "app/models/#{singular_name}.rb"
        unless options[:skip_migration]
          m.migration_template "migration.rb", "db/migrate", :migration_file_name => "create_#{plural_name}"
        end
        
        m.directory "test/unit"
        m.template "tests/#{test_framework}/model.rb", "test/unit/#{singular_name}_test.rb"
        m.directory "test/factories"
        m.template "factories.rb", File.join('test/factories', "#{plural_name}.rb")
      end
      
      unless options[:skip_controller]
        m.directory "app/controllers"
        m.template "controller.rb", "app/controllers/#{plural_name}_controller.rb"
        
        m.directory "app/helpers"
        m.template "helper.rb", "app/helpers/#{plural_name}_helper.rb"
        
        m.directory "app/views/#{plural_name}"
        controller_actions.each do |action|
          if File.exist? source_path("views/haml/#{action}.html.haml")
            m.template "views/haml/#{action}.html.haml", "app/views/#{plural_name}/#{action}.html.haml"
          end
        end
      
        if form_partial?
          m.template "views/haml/_form.html.haml", "app/views/#{plural_name}/_form.html.haml"
        end
      
        m.route_resources plural_name
        
        if rspec?
          m.directory "spec/controllers"
          m.template "tests/#{test_framework}/controller.rb", "spec/controllers/#{plural_name}_controller_spec.rb"
        else
          m.directory "test/functional"
          m.template "tests/#{test_framework}/controller.rb", "test/functional/#{plural_name}_controller_test.rb"
        end
      end
    end
  end
  
  def form_partial?
    actions? :new, :edit
  end
  
  def all_actions
    %w[index show new create edit update destroy]
  end
  
  def action?(name)
    controller_actions.include? name.to_s
  end
  
  def actions?(*names)
    names.all? { |n| action? n.to_s }
  end
  
  def singular_name
    name.underscore
  end
  
  def plural_name
    name.underscore.pluralize
  end
  
  def class_name
    name.camelize
  end
  
  def plural_class_name
    plural_name.camelize
  end
  
  def controller_methods(dir_name)
    controller_actions.map do |action|
      read_template("#{dir_name}/#{action}.rb")
    end.join("  \n").strip
  end
  
  def render_form
    if form_partial?
      "= render :partial => 'form'"
    else
      read_template("views/haml/_form.html.haml")
    end
  end
  
  def items_path(suffix = 'path')
    if action? :index
      "#{plural_name}_#{suffix}"
    else
      "root_#{suffix}"
    end
  end
  
  def item_path(suffix = 'path')
    if action? :show
      "@#{singular_name}"
    else
      items_path(suffix)
    end
  end
  
  def item_path_for_spec(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns[:#{singular_name}])"
    else
      items_path(suffix)
    end
  end
  
  def item_path_for_test(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns(:#{singular_name}))"
    else
      items_path(suffix)
    end
  end
  
  def model_columns_for_attributes
    class_name.constantize.columns.reject do |column|
      column.name.to_s =~ /^(id|created_at|updated_at)$/
    end
  end
  
  def rspec?
    test_framework == :rspec
  end
  
protected
  
  def test_framework
    options[:test_framework] ||= default_test_framework
  end
  
  def default_test_framework
    File.exist?(destination_path("spec")) ? :rspec : :testunit
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--skip-timestamps", "Don't add timestamps to migration file.") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--invert", "Generate all controller actions except these mentioned.") { |v| options[:invert] = v }
    opt.on("--haml", "Generate HAML views instead of ERB.") { |v| options[:haml] = v }
    opt.on("--testunit", "Use test/unit for test files.") { options[:test_framework] = :testunit }
    opt.on("--rspec", "Use RSpec for test files.") { options[:test_framework] = :rspec }
    opt.on("--shoulda", "Use Shoulda for test files.") { options[:test_framework] = :shoulda }
  end
  
  # is there a better way to do this? Perhaps with const_defined?
  def model_exists?
    File.exist? destination_path("app/models/#{singular_name}.rb")
  end
  
  def read_template(relative_path)
    ERB.new(File.read(source_path(relative_path)), nil, '-').result(binding)
  end
  
  def banner
    <<-EOS
Creates a controller and optional model given the name, actions, and attributes.

USAGE: #{$0} #{spec.name} ModelName [controller_actions and model:attributes] [options]
EOS
  end
end

module Rails
  module Generator
    class GeneratedAttribute
      def default_for_factory
        @default ||= case type
          when :integer                     then 1
          when :float                       then 1.5
          when :decimal                     then "9.99"
          when :datetime, :timestamp, :time then 'Time.now'
          when :date                        then 'Date.today'
          when :string                      then '"MyString"'
          when :text                        then '"MyText"'
          when :boolean                     then false
          else
            ""
        end      
      end
    end
  end
end

