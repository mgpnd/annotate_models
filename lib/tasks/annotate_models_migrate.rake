# These tasks are added to the project if you install annotate as a Rails plugin.
# (They are not used to build annotate itself.)

# Append annotations to Rake tasks for ActiveRecord, so annotate automatically gets
# run after doing db:migrate.

namespace :db do
  [:migrate, :rollback].each do |cmd|
    annotation_options_task = if Rake::Task.task_defined?('app:set_annotation_options')
                                'app:set_annotation_options'
                              else
                                'set_annotation_options'
                              end

    task cmd do
      Rake::Task[annotation_options_task].invoke
      Annotate::Migration.update_annotations
    end

    namespace cmd do
      [:change, :up, :down, :reset, :redo].each do |t|
        task t do
          Rake::Task[annotation_options_task].invoke
          Annotate::Migration.update_annotations
        end
      end
    end
  end
end

module Annotate
  class Migration
    @@working = false

    def self.update_annotations
      unless @@working || Annotate.skip_on_migration?
        @@working = true

        self.update_models if Annotate.include_models?
        self.update_routes if Annotate.include_routes?
      end
    end

    def self.update_models
      if Rake::Task.task_defined?("annotate_models")
        Rake::Task["annotate_models"].invoke
      elsif Rake::Task.task_defined?("app:annotate_models")
        Rake::Task["app:annotate_models"].invoke
      end
    end

    def self.update_routes
      if Rake::Task.task_defined?("annotate_routes")
        Rake::Task["annotate_routes"].invoke
      elsif Rake::Task.task_defined?("app:annotate_routes")
        Rake::Task["app:annotate_routes"].invoke
      end
    end
  end
end
