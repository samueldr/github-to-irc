require "date"

# Helps logs to go to the syslog. (I think.)
STDOUT.sync = true
STDERR.sync = true

def log(msg)
	puts "[#{DateTime.now.strftime("%F %H:%M:%S")}] <github-to-irc> #{msg}"
end
