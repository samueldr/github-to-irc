module GithubWebhook

	def self.handle(event, type:)
		type = type.to_sym

		pp type
		return [] unless Handlers.respond_to?(type)

		val = Handlers.send(type, event)
		# Always return an array
		val ||= []
		val
	end

	# Handlers for events.
	module Handlers
		# A couple helper functions.
		module Helpers
			# Converts a "author-like" object to a name to print.
			# It currently favours the github username.
			def self.authorize(author)
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
			def self.ellipsize(msg, length)
				return msg unless msg.length > length
				"#{msg[0...length]}…"
			end

			# Shortens a git id.
			def self.git_id(id)
				id[0...8]
			end

			# Could (in one fell swoop) shorten all URLs.
			# TODO : https://blog.github.com/2011-11-10-git-io-github-url-shortener/
			def self.url(url)
				url
			end
		end

		def self.issues(event)
			action = event["action"]
			issue  = event["issue"]
			repository = event["repository"]["name"]

			number = issue["number"]
			url    = Helpers.url(issue["html_url"])
			title  = issue["title"]

			author = Helpers.authorize(issue["user"])

			case action
			when "opened", "closed", "reopened"
				["[#{repository}] #{author} #{action} issue ##{number} → #{title} → #{url}"]
			end
		end

		def self.pull_request(event)
			action = event["action"]
			repository = event["repository"]["name"]
			pull_request  = event["pull_request"]

			number = pull_request["number"]
			url    = Helpers.url(pull_request["html_url"])
			title  = pull_request["title"]

			author = Helpers.authorize(pull_request["user"])

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
			end
		end

		def self.push(event)
			sender = event["sender"]
			author = Helpers.authorize(event["sender"])
			repository = event["repository"]["name"]
			branch = event["ref"].gsub(/^refs\/heads\//, "")
			url = Helpers.url(event["compare"])

			commits = event["commits"]
			count = commits.length

			["[#{repository}] #{author} pushed #{count} commits to #{branch}`: #{url}"] +
				commits[0...3].map do |commit|
					commit_author = Helpers.authorize(commit["author"])
					id = Helpers.git_id(commit["id"])
					message = Helpers.ellipsize(commit["message"], 120)
					" → #{id} by #{commit_author}: #{message}"
				end
		end
	end
end
