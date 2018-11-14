# GEM LIST
if yes?("'Postgres gem' kurmak ister misiniz?")
    gsub_file 'gemfile', "gem 'pg', '~> 0.15'" , "gem 'pg', '~> 0.18'"
    @postgres_installed = true
end
if yes?("'Puma gem' kurmak ister misiniz?")
    gem 'puma'
    @puma_installed = true
end
if yes?("'Devise gem' kurmak ister misiniz?")
    gem "devise"
    @devise_installed = true
end
if yes?("'Simple form' gem kurmak ister misiniz?")
    gem 'simple_form'
    @simple_form_installed = true
end
if yes?("'Font awesome' gem kurmak ister misiniz?")
    gem 'font-awesome-rails'
    @font_awesome_installed = true
end
if yes? ("Heroku deploy icin 'rails_12factor' gem yuklemek ister misiniz?")
    gem_group :production do
        gem 'rails_12factor'
    end
end
# ./GEM LIST

# BUNDLE INSTALL
if yes?('Bundle install?')
    run 'bundle install'
end

#Git initialization
git :init
git add: ".", commit: "-m 'initial commit'"




# IF GEMS INSTALLED


# IF PUMA INSTALLED
    if (@puma_installed == true)
        if yes? ('Config Puma?')

            path = "config/puma.rb"
            
            content = "workers Integer(ENV['WEB_CONCURRENCY'] || 2) unless Gem.win_platform?
            threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
            threads threads_count, threads_count
            
            preload_app!
            
            rackup      DefaultRackup
            port        ENV['PORT']     || 3000
            environment ENV['RACK_ENV'] || 'development'
            
            on_worker_boot do
            # Worker specific setup for Rails 4.1+
            # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
            ActiveRecord::Base.establish_connection
            end"

            File.open(path, "w+") do |f|
            f.write(content)
            end
        end
    end 
# ./ IF PUMA INSTALLED


# IF DEVISE INSTALLED
    if (@devise_installed == true)
        #KULLANICILAR
        generate "devise:install"
        until @user_loop == false
            if yes?("Yeni devise kullanicisi olustur?")
                model_name = ask('devise kullanici adi? bos=kullanici').underscore
                model_name = "kullanici" if model_name.blank?
                generate "devise", model_name
                @user_loop = true
            else
                @user_loop = false
            end
        end
        generate "devise:views"

        # DEVISE ACTION MAILER
        environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
            env: 'development'
    end
# ./IF DEVISE INSTALLED

# IF POSTGRES INSTALLED
    if (@postgres_installed == true)
        if yes?("Postgres izinlerini kurmak ister misiniz?")
            gsub_file 'config/database.yml', "#username: new_app" , "username: postgres"
            gsub_file 'config/database.yml', "username: new_app" , "username: postgres"
            gsub_file 'config/database.yml', "#password:" , "password: 726364546Ali!!!"
            appname = ask("app name?").underscore
            gsub_file 'config/database.yml', "database: new_app_development" , "database: #{appname}_development"
            gsub_file 'config/database.yml', "database: new_app_test" , "database: #{appname}_test"
            gsub_file 'config/database.yml', "database: new_app_production" , "database: #{appname}_production"
        end
    end
# ./IF POSTGRES INSTALLED

# IF FONT AWESOME INSTALLED
    if (@font_awesome_installed)
        inject_into_file 'app/assets/stylesheets/application.css', before: " *= require_tree .\n" do <<-'RUBY'
    *= require font-awesome
            RUBY
        end
    end
# ./IF FONT AWESOME INSTALLED

# SCSS WORKFLOW START

    if yes?("SCSS still dosyalari yuklensin mi?")

        # variables start
            path = "app/assets/stylesheets/_variables.scss"
            content = "/* variables Generated by Ali Kemal */"
            File.open(path, "w+") do |f|
            f.write(content)
            end
            inject_into_file 'app/assets/stylesheets/application.css', after: " */\n" do <<-'RUBY'
        @import "variables";
                RUBY
            end
        # variables end

        # modules start
            path = "app/assets/stylesheets/_modules.scss"
            content = "/* modules Generated by Ali Kemal */"
            File.open(path, "w+") do |f|
            f.write(content)
            end
            inject_into_file 'app/assets/stylesheets/application.css', after: " */\n" do <<-'RUBY'
        @import "modules";
                RUBY
            end
        # modules end

        # components start
            path = "app/assets/stylesheets/_components.scss"
            content = "/* components Generated by Ali Kemal */"
            File.open(path, "w+") do |f|
            f.write(content)
            end
            inject_into_file 'app/assets/stylesheets/application.css', after: " */\n" do <<-'RUBY'
        @import "components";
                RUBY
            end
        # components end



    end

# SCSS WORKFLOW END

# SET TIMEZONE START
    if yes?('Timezone ayarla?')
        @timezone = ask("timezone? bos=istanbul").underscore
        @timezone = "Istanbul" if @timezone.blank?
        gsub_file 'config/application.rb', "# config.time_zone = 'Central Time (US & Canada)'" , "config.time_zone = '#{@timezone}'"
    end
# SET TIMEZONE END

# SET DEFAULT LOCALE START
    if yes?('Locale ayarla?')
        @locale = ask("locale? bos=tr").underscore
        @locale = "tr" if @locale.blank?
        gsub_file 'config/application.rb', "# config.i18n.default_locale = :de", "config.i18n.default_locale = :#{@locale}" 

        path = "config/locales/#{@locale}.yml"
        content = "#{@locale}:
        hello: 'Merhaba Dünya'"
        File.open(path, "w+") do |f|
        f.write(content)
        end
        @locale_ayarla = true
    end
# SET DEFAULT LOCALE END

# SCAFFOLD STYLES START
    if yes?('Otomatik iskelet stilleri devre disi?')
        inject_into_file 'config/application.rb', after: "config.active_record.raise_in_transactional_callbacks = true\n" do <<-'RUBY'

        # Otomatik scaffold.scss engelle.
        config.generators do |g|
            g.orm             :active_record
            g.template_engine :erb
            g.test_framework  :test_unit, :fixture => false
            g.stylesheets     false
            end
        RUBY
        end
    end
# SCAFFOLD STYLES END

# SCAFFOLD TEMPLATES START
    if yes? ('Scaffold gorunumlerini duzenle?')
        # $     bundle show railties     => Path'i gosterir

        # INDEX
            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\index.html.erb',
            "<h1>Listing <%= plural_table_name.titleize %></h1>" , 
            "<h1><%= plural_table_name.titleize %></h1>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\index.html.erb',
            "        <td><%%= link_to 'Show', <%= singular_table_name %> %></td>" , 
            "        <td><%%= link_to 'Goster', <%= singular_table_name %> %></td>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\index.html.erb',
            "        <td><%%= link_to 'Edit', edit_<%= singular_table_name %>_path(<%= singular_table_name %>) %></td>" , 
            "        <td><%%= link_to 'Duzenle', edit_<%= singular_table_name %>_path(<%= singular_table_name %>) %></td>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\index.html.erb',
            "        <td><%%= link_to 'Destroy', <%= singular_table_name %>, method: :delete, data: { confirm: 'Are you sure?' } %></td>" , 
            "        <td><%%= link_to 'Sil', <%= singular_table_name %>, method: :delete, data: { confirm: 'Emin misiniz?' } %></td>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\index.html.erb',
            "<%%= link_to 'New <%= human_name %>', new_<%= singular_table_name %>_path %>" , 
            "<%%= link_to 'Yeni <%= human_name %>', new_<%= singular_table_name %>_path %>"

        # EDIT
            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\edit.html.erb',
            "<h1><h1>Editing <%= singular_table_name.titleize %></h1>" , 
            "<h1><h1><%= singular_table_name.titleize %> Duzenle </h1>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\edit.html.erb',
            "<%%= link_to 'Show', @<%= singular_table_name %> %> |" , 
            "<%%= link_to 'Goster', @<%= singular_table_name %> %> |"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\edit.html.erb',
            "<%%= link_to 'Back', <%= index_helper %>_path %>" , 
            "<%%= link_to 'Geri', <%= index_helper %>_path %>"

        # SHOW
            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\show.html.erb',
            "<%%= link_to 'Edit', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>) %> |" , 
            "<%%= link_to 'Duzenle', edit_<%= singular_table_name %>_path(@<%= singular_table_name %>) %> |"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\show.html.erb',
            "<%%= link_to 'Back', <%= index_helper %>_path %>" , 
            "<%%= link_to 'Geri', <%= index_helper %>_path %>"

        # NEW
            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\new.html.erb',
            "<h1>New <%= singular_table_name.titleize %></h1>" , 
            "<h1>Yeni <%= singular_table_name.titleize %></h1>"

            gsub_file '\Ruby24-x64\lib\ruby\gems\2.4.0\gems\railties-4.2.10\lib\rails\generators\erb\scaffold\templates\new.html.erb',
            "<%%= link_to 'Back', <%= index_helper %>_path %>" , 
            "<%%= link_to 'Geri', <%= index_helper %>_path %>"
    end
# SCAFFOLD TEMPLATES END

# IF SIMPLE_FORM INSTALLED
    if (@simple_form_installed == true)
        generate "simple_form:install"
        if (@locale_ayarla == true)
            path = "config/locales/simple_form.#{@locale}.yml"
            content = "#{@locale}:
            simple_form:"
            File.open(path, "w+") do |f|
            f.write(content)
            end
        end
    end
# ./IF SIMPLE_FORM INSTALLED

# CREATE SCAFFOLDS START
    until @iskelet_loop == false
        if yes?('Yeni iskelet yaratmak ister misiniz? ( Post title:string content:text adet:integer price:decimal )')
            scaffold_attr =ask('Iskelet ozellikleri').underscore
            generate "scaffold #{scaffold_attr}"
        else
            @iskelet_loop = false
        end
    end
# CREATE SCAFFOLDS END

# CREATE MODEL START
    until @model_loop == false
        if yes?('Yeni model yaratmak ister misiniz?')
            model_attr =ask('Model ozellikleri').underscore
            generate "model #{model_attr}"
        else
            @model_loop = false
        end
    end
# CREATE MODEL END

# CREATE CONTROLLER START
    until @controller_loop == false
        if yes?('Yeni controller yaratmak ister misiniz? ( anasayfa index show )')
            controller_attr =ask('Controller ozellikleri').underscore
            generate "controller #{controller_attr}"
        else
            @controller_loop = false
        end
    end
# CREATE CONTROLLER END

# CREATE ROOT
    if yes?("Root ayarlamak ister misiniz?")
        route =ask("Root to?").underscore
        route "root to: '#{route}\#index'"
    end


    if yes?('Database olustur?')
        rake "db:create"
    end

    if yes?('Database migration?')
        rake "db:migrate"
    end
