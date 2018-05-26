require "json"

unless ARGV.count == 1
	STDERR.puts("Needs config.json as argv1")
	exit 1
end

# https://github.com/NixOS/ofborg/blob/03312b8176bfd197aeb693721b516c6a25a4611e/ircbot/src/config.rs#L17
$config = JSON.parse(File.read(ARGV.first))

WEBHOOK_EXCHANGE = "github-events"
IRC_EXCHANGE = "exchange-messages"
