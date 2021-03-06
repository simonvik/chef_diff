# Encoding: utf-8
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

# Copyright 2013-2014 Facebook
# Copyright 2014-present One.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef_diff/changes/change'
require 'chef_diff/changes/cookbook'
require 'chef_diff/changes/role'
require 'chef_diff/changes/node'
require 'chef_diff/changes/client'
require 'chef_diff/changes/environment'
require 'chef_diff/changes/databag'
require 'chef_diff/changes/user'

module ChefDiff
  # Convenience for dealing with changes
  # Represents a list of diffs between two revisions
  # as a series of Cookbook and Role objects
  #
  # Basically, you always want to use ChefDiff::Changes through this
  # helper class.
  class Changeset
    class ReferenceError < Exception
    end

    def initialize(logger, repo, start_ref, end_ref, locations)
      @logger = logger
      @repo = repo
      @cookbook_dirs = locations[:cookbook_dirs].dup
      @role_dir = locations[:role_dir]
      @node_dir = locations[:node_dir]
      @client_dir = locations[:client_dir]
      @environment_dir = locations[:environment_dir]
      @databag_dir = locations[:databag_dir]
      @user_dir = locations[:user_dir]
      # Figure out which files changed if refs provided
      # or return all files (full upload) otherwise
      if start_ref
        @files = []
        @repo.changes(start_ref, end_ref).each do |file|
          @files << file
        end
      else
        @files = @repo.files
      end
    end

    def cookbooks
      ChefDiff::Changes::Cookbook.find(@files, @cookbook_dirs, @logger)
    end

    def roles
      ChefDiff::Changes::Role.find(@files, @role_dir, @logger)
    end

    def nodes
      ChefDiff::Changes::Node.find(@files, @node_dir, @logger)
    end

    def clients
      ChefDiff::Changes::Client.find(@files, @client_dir, @logger)
    end

    def environments
      ChefDiff::Changes::Environment.find(@files, @environment_dir, @logger)
    end

    def databags
      ChefDiff::Changes::Databag.find(@files, @databag_dir, @logger)
    end

    def users
      ChefDiff::Changes::User.find(@files, @user_dir, @logger)
    end
  end
end
