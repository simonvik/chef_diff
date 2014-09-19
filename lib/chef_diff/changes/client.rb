# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

# Copyright 2013-present Facebook
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

# rubocop:disable ClassVars
module ChefDiff
  module Changes
    # Changeset aware client
    class Client < Change
      def self.name_from_path(path, client_dir)
        re = "^#{client_dir}/([^/]+/)*(.+)\.json"
        debug("[client] Matching #{path} against #{re}")
        m = path.match(re)
        if m
          info("Name is #{m[2]}")
          return m[2]
        end
        nil
      end

      def initialize(file, client_dir)
        @status = file[:status] == :deleted ? :deleted : :modified
        @name = self.class.name_from_path(file[:path], client_dir)
      end

      # Given a list of changed files
      # create a list of client objects
      def self.find(list, client_dir, logger)
        @@logger = logger
        return [] if list.nil? || list.empty?
        list.
          select { |x| self.name_from_path(x[:path], client_dir) }.
          map do |x|
            ChefDiff::Changes::Client.new(x, client_dir)
          end
      end
    end
  end
end
