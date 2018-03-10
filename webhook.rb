module GithubWebhook
	# A couple helper functions.
	module Helpers
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

		# Could (in one fell swoop) shorten all URLs.
		# TODO : https://blog.github.com/2011-11-10-git-io-github-url-shortener/
		def git_io(url)
			url
		end
	end

	def self.handle(event, type:)
		type = type.split("_").map(&:capitalize).join().to_sym
		return [] unless GithubWebhook.constants(false).include?(type)
		klass = GithubWebhook.const_get(type)
		instance = klass.new(event)
		instance.to_messages
	end

	# Handlers for events.
	class Event
		include Helpers

		def initialize(event)
			@event = event
		end

		# Defaults to an empty list.
		def to_messages()
			[]
		end
	end

	class Push < Event
		def sender
			@event["sender"]
		end

		def author
			to_author(@event["sender"])
		end

		def repository
			@event["repository"]["name"]
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
			["[#{repository}] #{author} pushed #{count} commits to #{branch}`: #{url}"] +
				commits[0...3].map do |commit|
					commit_author = to_author(commit["author"])
					id = git_id(commit["id"])
					message = ellipsize(commit["message"], 120)
					" → #{id} by #{commit_author}: #{message}"
				end
		end
	end

	class IssueLike < Event
		def action
			@event["action"]
		end

		def repository
			@event["repository"]["name"]
		end

		def number
			_self["number"]
		end

		def url
			git_io(_self["html_url"])
		end

		def title
			_self["title"]
		end

		def author
			to_author(_self["user"])
		end

	end

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
				["[#{repository}] #{author} #{action} issue ##{number} → #{title} → #{url}"]
			else
				[]
			end
		end
	end

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
				["[#{repository}] #{author} #{status} pull request ##{number} → #{title} → #{url}"]
			else
				[]
			end
		end
	end
end
