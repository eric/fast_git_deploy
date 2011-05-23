module FastGitDeploy
  module Rollback
    def self.load_into(configuration)
      configuration.load do
        namespace :deploy do
          namespace :rollback do
            desc "Rolls back the app one revision, restarts mongrel, and writes the revision to the VERSION file (but not revisions.log)"
            task :default do
              transaction do
                strategy.rollback!
                deploy.restart
              end
            end
          end
        end
      end
    end
  end
end