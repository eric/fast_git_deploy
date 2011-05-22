require 'capistrano'
require 'fast_git_deploy/deploy'
require 'fast_git_deploy/rollback'
require 'fast_git_deploy/setup'

module FastGitDeploy
  VERSION = '0.1.0'
end

if Capistrano::Configuration.instance
  FastGitDeploy::Deploy.load_into(Capistrano::Configuration.instance)
  FastGitDeploy::Rollback.load_into(Capistrano::Configuration.instance)
  FastGitDeploy::Setup.load_into(Capistrano::Configuration.instance)
end
