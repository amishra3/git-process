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

require 'git-process/github_configuration'
require 'octokit'
require 'octokit/repository'


module GitHub

  class PullRequest
    attr_reader :gitlib, :repo, :remote_name, :client, :configuration

    MAX_RESEND = 5

    def initialize(lib, remote_name, repo, opts = {})
      @gitlib = lib
      @repo = repo
      @remote_name = remote_name
      @configuration = GitHubService::Configuration.new(gitlib.config, :user => opts[:user], :password => opts[:password])
    end


    def client
      @client ||= @configuration.create_client
    end


    def pull_requests(opts = {})
      @pull_requests ||= client.pull_requests(repo, opts)
    end


    # Create a pull request
    #
    # @see https://developer.github.com/v3/pulls/#create-a-pull-request
    # @param base [String] The branch (or git ref) you want your changes
    #                      pulled into. This should be an existing branch on the current
    #                      repository. You cannot submit a pull request to one repo that requests
    #                      a merge to a base of another repo.
    # @param head [String] The branch (or git ref) where your changes are implemented.
    # @param title [String] Title for the pull request
    # @param body [String] The body for the pull request (optional). Supports GFM.
    # @return [Sawyer::Resource] The newly created pull request
    # @example
    #   @client.create_pull_request("master", "feature-branch",
    #     "Pull Request title", "Pull Request body")
    def create(base, head, title, body)
      logger.info { "Creating a pull request asking for '#{head}' to be merged into '#{base}' on #{repo}." }
      begin
        return client.create_pull_request(repo, base, head, title, body)
      rescue Octokit::UnprocessableEntity => exp
        pull = pull_requests.find { |p| p[:head][:ref] == head and p[:base][:ref] == base }
        if pull
          logger.warn { "Pull request already exists. See #{pull[:html_url]}" }
        else
          logger.warn { "UnprocessableEntity: #{exp}" }
        end
        return pull
      end
    end


    def logger
      @gitlib.logger
    end


    def pull_request(pr_number)
      client.pull_request(repo, pr_number)
    end


    #
    # Find the pull request (PR) that matches the 'head' and 'base'.
    #
    # @param [String] base what the PR is merging into
    # @param [String] head the branch of the PR
    #
    # @return [Hash]
    # @raise [NotFoundError] if the pull request does not exist
    #
    def get_pull_request(base, head)
      find_pull_request(base, head, true)
    end


    #
    # Find the pull request (PR) that matches the 'head' and 'base'.
    #
    # @param [String] base what the PR is merging into
    # @param [String] head the branch of the PR
    # @param [boolean] error_if_missing should this error-out if the PR is not found?
    #
    # @return [Hash, nil]
    # @raise [NotFoundError] if the pull request does not exist and 'error_if_missing' is true
    #
    def find_pull_request(base, head, error_if_missing = false)
      logger.info { "Looking for a pull request asking for '#{head}' to be merged into '#{base}' on #{repo}." }

      json = pull_requests
      pr = json.find { |p| p[:head][:ref] == head and p[:base][:ref] == base }

      raise NotFoundError.new(base, head, repo, json) if error_if_missing && pr.nil?

      pr
    end


    def close(*args)
      pull_number = if args.size == 2
                      get_pull_request(args[0], args[1])[:number]
                    elsif args.size == 1
                      args[0]
                    else
                      raise ArgumentError.new('close(..) needs 1 or 2 arguments')
                    end

      logger.info { "Closing a pull request \##{pull_number} on #{repo}." }

      send_close_req(pull_number, 1)
    end


    class NotFoundError < StandardError
      attr_reader :base, :head, :repo


      def initialize(base, head, repo, pull_requests_json)
        @base = base
        @head = head
        @repo = repo

        @pull_requests = pull_requests_json.map do |p|
          {:head => p[:head][:ref], :base => p[:base][:ref]}
        end

        msg = "Could not find a pull request for '#{head}' to be merged with '#{base}' on #{repo}."
        msg += "\n\nExisting Pull Requests:"
        msg = pull_requests.inject(msg) { |a, v| "#{a}\n  #{v[:head]} -> #{v[:base]}" }

        super(msg)
      end


      def pull_requests
        @pull_requests
      end

    end


    private


    def send_close_req(pull_number, count)
      begin
        client.patch("repos/#{Octokit::Repository.new(repo)}/pulls/#{pull_number}", {:state => 'closed'})
      rescue Octokit::UnprocessableEntity => exp
        if count > MAX_RESEND
          raise exp
        end
        logger.warn { "Retrying closing a pull request \##{pull_number} on #{repo} - try \##{count + 1}" }
        send_close_req(pull_number, count + 1)
      end
    end

  end

end
