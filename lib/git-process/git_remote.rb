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

require 'git-process/git_config'
require 'addressable/uri'


class String

  def to_boolean
    return false if self == false || self.nil? || self =~ (/(false|f|no|n|0)$/i)
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end

end


class NilClass
  def to_boolean
    false
  end
end


module GitProc

  #
  # Git Remote configuration
  #
  class GitRemote

    # @param [GitProc::GitConfig] gitconfig
    def initialize(gitconfig)
      @gitconfig = gitconfig
    end


    # @return [#info, #warn, #debug, #error]
    def logger
      @logger ||= @gitconfig.logger
    end


    # @return [GitProc::GitConfig]
    def config
      @gitconfig
    end


    # @deprecated
    # @todo Remove
    def server_name
      @server_name ||= self.remote_name
    end


    # @return [Boolean] does this have a remote defined?
    def exists?
      if @has_remote.nil?
        @has_remote = (config.gitlib.command(:remote) != '')
      end
      logger.debug { "Does a remote exist? #{@has_remote}" }
      @has_remote
    end


    #
    # The name of the repository
    #
    # @example
    #   repo_name #=> "jdigger/git-process"
    #
    # @return [String] the name of the repository
    def repo_name
      unless @repo_name
        url = config["remote.#{name}.url"]
        raise GitProcessError.new("There is no #{name} url set up.") if url.nil? or url.empty?
        uri = Addressable::URI.parse(url)
        @repo_name = uri.path.sub(/\.git/, '').sub(/^\//, '')
      end
      @repo_name
    end


    #
    # Returns the "remote name" to use. By convention the most common name is "origin".
    #
    # If the Git configuration "gitProcess.remoteName" is set, that will always be used. Otherwise this
    # simple returns the first name it finds in the list of remotes.
    #
    # @return [String, nil] the remote name, or nil if there are none defined
    def remote_name
      unless @remote_name
        @remote_name = config['gitProcess.remoteName']
        if @remote_name.nil? or @remote_name.empty?
          remotes = self.remote_names
          if remotes.empty?
            @remote_name = nil
          else
            @remote_name = remotes[0]
            raise "remote name is not a String: #{@remote_name.inspect}" unless @remote_name.is_a? String
          end
        end
        logger.debug { "Using remote name of '#{@remote_name}'" }
      end
      @remote_name
    end


    alias :name :remote_name


    #
    # Takes {#remote_name} and combines it with {GitConfig#master_branch}.
    #
    # @example
    #   master_branch_name #=> origin/master
    #
    # @return [String] the complete remote name of the integration branch
    #
    def master_branch_name
      "#{self.name}/#{config.master_branch}"
    end


    alias :remote_integration_branch_name :master_branch_name


    def remote_names
      remote_str = config.gitlib.command(:remote, [:show])
      if remote_str.nil? or remote_str.empty?
        []
      else
        remote_str.split(/\n/)
      end
    end


    #
    # Expands the git configuration server name to a url.
    #
    # Takes into account further expanding an SSH uri that uses SSH aliasing in .ssh/config
    #
    # @param [String] server_name the git configuration server name; defaults to 'origin'
    #
    # @option opts [String] :ssh_config_file the SSH config file to use; defaults to ~/.ssh/config
    #
    # @return the fully expanded URL; never nil
    #
    # @raise [GitHubService::NoRemoteRepository] there is not a URL set for the server name
    # @raise [URI::InvalidURIError] the retrieved URL does not have a schema
    # @raise [GitHubService::NoRemoteRepository] if could not figure out a host for the retrieved URL
    # @raise [::ArgumentError] if a server name is not provided
    #
    # @todo use the netrc gem
    def expanded_url(server_name = 'origin', raw_url = nil, opts = {})
      if raw_url.nil?
        raise ArgumentError.new('Need server_name') unless server_name

        conf_key = "remote.#{server_name}.url"
        url = config[conf_key]

        raise GitHubService::NoRemoteRepository.new("There is no value set for '#{conf_key}'") if url.nil? or url.empty?
      else
        raise GitHubService::NoRemoteRepository.new("There is no value set for '#{raw_url}'") if raw_url.nil? or raw_url.empty?
        url = raw_url
      end

      if /^\S+@/ =~ url
        url.sub(/^(\S+@\S+?):(.*)$/, "ssh://\\1/\\2")
      else
        uri = URI.parse(url)
        host = uri.host
        scheme = uri.scheme

        raise URI::InvalidURIError.new("Need a scheme in URI: '#{url}'") unless scheme

        if scheme == 'file'
          url
        elsif host.nil?
          # assume that the 'scheme' is the named configuration in ~/.ssh/config
          rv = GitRemote.hostname_and_user_from_ssh_config(scheme, opts[:ssh_config_file] ||= "#{ENV['HOME']}/.ssh/config")

          raise GitHubService::NoRemoteRepository.new("Could not determine a host from #{url}") if rv.nil?

          host = rv[0]
          user = rv[1]
          url.sub(/^\S+:(\S+)$/, "ssh://#{user}@#{host}/\\1")
        else
          url
        end
      end
    end


    # @return [void]
    def add_remote(remote_name, url)
      config.gitlib.command(:remote, ['add', remote_name, url])
    end


    alias :add :add_remote


    # @todo use the netrc gem
    #noinspection RubyClassMethodNamingConvention
    def self.hostname_and_user_from_ssh_config(host_alias, config_file)
      if File.exists?(config_file)
        config_lines = File.new(config_file).readlines

        in_host_section = false
        host_name = nil
        user_name = nil

        config_lines.each do |line|
          line.chop!
          if /^\s*Host\s+#{host_alias}\s*$/ =~ line
            in_host_section = true
            next
          end

          if in_host_section and (/^\s*HostName\s+\S+\s*$/ =~ line)
            host_name = line.sub(/^\s*HostName\s+(\S+)\s*$/, '\1')
            break unless user_name.nil?
          elsif in_host_section and (/^\s*User\s+\S+\s*$/ =~ line)
            user_name = line.sub(/^\s*User\s+(\S+)\s*$/, '\1')
            break unless host_name.nil?
          elsif in_host_section and (/^\s*Host\s+.*$/ =~ line)
            break
          end
        end
        host_name.nil? ? nil : [host_name, user_name]
      else
        nil
      end
    end

  end

end
