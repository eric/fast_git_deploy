current_dir = File.dirname(__FILE__)

load "#{current_dir}/fast_git_deploy/setup.rb"
load "#{current_dir}/fast_git_deploy/rollback.rb"

set(:revision_log) { "#{deploy_to}/revisions.log" }
set(:version_file) { "#{current_path}/REVISION" }

set :migrate_target, :current

namespace :deploy do
  task :cold do
    git_setup.cold
  end

  desc <<-DESC
    Deploy and run pending migrations. This will work similarly to the \
    `deploy' task, but will also run any pending migrations (via the \
    `deploy:migrate' task) prior to updating the symlink. Note that the \
    update in this case it is not atomic, and transactions are not used, \
    because migrations are not guaranteed to be reversible.
  DESC
  task :migrations do
    set :migrate_target, :current
    update_code
    migrate
    symlink
    restart
  end

  desc "Updates code in the repos by fetching and resetting to the latest in the branch"
  task :update_code, :except => { :no_release => true } do
    run [
      "cd #{current_path}",
      "git fetch",
      "git reset --hard origin/#{branch}"
    ].join(" && ")
  end

  desc "Instead of symlinking, set the revisions file.  This allows us to go back to previous versions."
  task :symlink, :except => { :no_release => true } do
    set_revisions
  end

  task :set_revisions, :except => { :no_release => true } do
    set_version_file
    update_revisions_log
  end

  task :set_version_file, :except => { :no_release => true } do
    run [
      "cd #{current_path}",
      "git rev-list origin/#{branch} | head -n 1 > #{version_file}"
    ].join(" && ")
  end

  task :update_revisions_log, :except => { :no_release => true } do
    run "echo `date +\"%Y-%m-%d %H:%M:%S\"` $USER $(cat #{version_file}) #{File.basename(release_path)} >> #{deploy_to}/revisions.log"
  end
end