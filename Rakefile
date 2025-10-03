# Rakefile
require "rubygems"
require "bundler/setup"
require "dotenv"
require "erb"
require "pg"
require "active_record"
require "yaml"

Dotenv.load

def load_database_config(env)
  db_config = YAML.load(ERB.new(File.read("config/database.yml")).result, aliases: true)
  db_config[env]
end

namespace :db do
  desc "Migrate the database"
  task :migrate do
    connection_details = load_database_config("development")
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::MigrationContext.new("db/migrate").migrate
  end

  desc "Create the database"
  task :create do
    connection_details = load_database_config("development")
    admin_connection = connection_details.merge({ "database" => "postgres"})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch("database"))
  end

  desc "Drop the database"
  task :drop do
    connection_details = load_database_config("development")
    admin_connection = connection_details.merge({ "database" => "postgres"})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch("database"))
  end

  desc "Rollback the last migration"
  task :rollback do
    connection_details = load_database_config("development")
    ActiveRecord::Base.establish_connection(connection_details)
    schema_migration = ActiveRecord::SchemaMigration.new(ActiveRecord::Base.connection_pool)
    migration_context = ActiveRecord::MigrationContext.new("db/migrate", schema_migration)
    last_migration = migration_context.migrations.last
    if last_migration
      version = last_migration.version
      puts "Rolling back migration: #{version}"
      migration_context.down(version)
    else
      puts "No migrations to rollback"
    end
  end

  desc "Run a specific migration down by VERSION"
  task :migrate_down, [:version] do |_, args|
    unless args[:version]
      raise "VERSION is required (e.g., rake db:migrate_down VERSION=20250924141449)"
    end
    connection_details = load_database_config("development")
    ActiveRecord::Base.establish_connection(connection_details)
    schema_migration = ActiveRecord::SchemaMigration.new(ActiveRecord::Base.connection_pool)
    migration_context = ActiveRecord::MigrationContext.new("db/migrate", schema_migration)
    puts "Running down migration: #{args[:version]}"
    migration_context.down(args[:version].to_i)
  end

  desc "Display status of migrations"
  task :migrate_status do
    connection_details = load_database_config("development")
    ActiveRecord::Base.establish_connection(connection_details)
    schema_migration = ActiveRecord::SchemaMigration.new(ActiveRecord::Base.connection_pool)
    migration_context = ActiveRecord::MigrationContext.new("db/migrate", schema_migration)
    migrations = migration_context.migrations
    schema_migrations = schema_migration.versions
    puts " Status   Migration ID    Migration Name"
    puts "--------------------------------------------------"
    migrations.each do |migration|
      status = schema_migrations.include?(migration.version.to_s) ? "up" : "down"
      puts " #{status.ljust(8)} #{migration.version}  #{migration.name}"
    end
  end
end