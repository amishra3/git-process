# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'set'
require 'git-process/git_branch'

module GitProc

  class GitBranches
    include Enumerable


    def initialize(lib, opt = {})
      @lib = lib
      branch_opts = {:no_color => true}
      if opt[:remote]
        branch_opts[:remote] = true
      elsif opt[:local]
        branch_opts[:local] = true
      else
        branch_opts[:all] = true
      end
      branch_lines = lib.branch(nil, branch_opts).split("\n")
      @items = SortedSet.new
      branch_lines.each do |bl|
        @items << GitBranch.new(bl[2..-1], bl[0..0] == '*', lib)
      end
    end


    def <<(item)
      @items << item
    end


    def each(&block)
      @items.each { |b| block.call(b) }
    end


    def names
      @items.map { |b| b.name }
    end


    def current
      @items.find { |b| b.current? }
    end


    def parking
      @items.find { |b| b.name == '_parking_' }
    end


    def include?(branch_name)
      @items.any? { |b| b.name == branch_name }
    end


    def [](branch_name)
      branch_name = current.name if branch_name == 'HEAD'
      br = @items.find { |b| b.name == branch_name }
      if br.nil? and branch_name !~ /origin\// and branch_name != '_parking_'
        @lib.logger.warn { "Could not find '#{branch_name}' in #{@items.map { |i| i.name }.join(',')}" }
      end
      br
    end

  end

end
