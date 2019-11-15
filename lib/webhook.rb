require "net/http"
require "uri"

# Namespace for the webhook data to irc bit.
module GithubWebhook
	# A couple helper functions.
	module Helpers
		GIT_IO_ENDPOINT = URI("https://git.io/")

		# Converts a "author-like" object to a name to print.
		# It currently favours the github username.
		def to_author(author)
			# When an account is given
			return "@" + author["login"] if author["login"]

			# Commits have a username key
			if author["username"]
				"@" + author["username"]
			elsif author["name"]
				author["name"]
			else
				# When no known key can be used?
				# FIXME : log this?
				"(?)"
			end
		end

		# Returns an ellipsized string when the string is long.
		def ellipsize(msg, length)
			return msg unless msg.length > length
			"#{msg[0...length]}…"
		end

		# Shortens a git id.
		def git_id(id)
			id[0...8]
		end

		# Translates github URLs into git.io URLs.
		def git_io(url)
			begin
				http = Net::HTTP.new(GIT_IO_ENDPOINT.host, GIT_IO_ENDPOINT.port)
				http.use_ssl = true
				params = {url: url}
				response = http.post(GIT_IO_ENDPOINT, URI.encode_www_form(params))
				return response["Location"]
			rescue
				return url
			end
		end
	end

	# Given event data and type, uses the proper class and
	# returns an array of messages.
	def self.handle(event, type:)
		type = type.split("_").map(&:capitalize).join().to_sym
		return [] unless GithubWebhook.constants(false).include?(type)
		klass = GithubWebhook.const_get(type)
		instance = klass.new(event)
		instance.to_messages
	end

	# Generic Event.
	class Event
		include Helpers

		def initialize(event)
			@event = event
		end

		# Defaults to an empty list.
		def to_messages()
			[]
		end

		def sender()
			to_author(@event["sender"])
		end
	end

	# Push event.
	class Push < Event
		def author
			sender
		end

		def repository
			@event["repository"]["name"]
		end

		def repo_fullname
			@event["repository"]["full_name"]
		end

		def branch
			@event["ref"].gsub(/^refs\/heads\//, "")
		end

		def url
			git_io(@event["compare"])
		end

		def commits
			@event["commits"]
		end

		def count
			commits.length
		end

		def to_messages()
			# Starts with a description of the event.
			# Handles 1-commit long push events differently,
			# Then keeps at most the three first commits.
			if commits.length == 1 then
				commit = commits.first
				commit_author = to_author(commit["author"])
				message = commit["message"].split("\n").first.strip
				message = ellipsize(message, 120)

				# It's possible a push event is done by someone else than the author.
				if commit_author == author then
					["[#{repository}] #{author} pushed to #{branch} « #{message} »: #{url}"]
				else
					["[#{repository}] #{author} pushed commit from #{commit_author} to #{branch} « #{message} »: #{url}"]
				end
			else
				["[#{repository}] #{author} pushed #{count} commits to #{branch}: #{url}"]
			end
		end
	end

	# Pull Requests and Issues looks alike.
	class IssueLike < Event
		def action
			@event["action"]
		end

		def repository
			@event["repository"]["name"]
		end

		def repo_fullname
			@event["repository"]["full_name"]
		end

		def number
			_self["number"]
		end

		def url
			git_io(_self["html_url"])
		end

		def title
			ellipsize(_self["title"], 120)
		end

		def author
			to_author(_self["user"])
		end
	end

	# Issues event.
	class Issues < IssueLike
		def _self
			issue
		end

		def issue
			@event["issue"]
		end

		def to_messages
			case action
			when "opened", "closed", "reopened"
				["[#{repository}] #{sender} #{action} issue ##{number} → #{title} → #{url}"]
			else
				[]
			end
		end
	end

	# Pull Request event.
	class PullRequest < IssueLike
		def _self
			pull_request
		end

		def pull_request
			@event["pull_request"]
		end

		def to_messages
			status =
				case action
				when "closed"
					if pull_request["merged"] == true
						"merged"
					else
						"closed"
					end
				else
					action
				end

			case action
			when "opened", "closed", "reopened"
				["[#{repository}] #{sender} #{status} pull request ##{number} → #{title} → #{url}"]
			else
				[]
			end
		end
	end
end
