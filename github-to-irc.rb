require "bunny"
require_relative "./webhook.rb"
require "pp"
require "json"

unless ARGV.count == 1
	STDERR.puts("Needs config.json as argv1")
	exit 1
end

# https://github.com/NixOS/ofborg/blob/03312b8176bfd197aeb693721b516c6a25a4611e/ircbot/src/config.rs#L17
config = JSON.parse(File.read(ARGV.first))

$webhook_exchange = "github-events"
$irc_exchange = "exchange-messages"

conn = Bunny.new(
	host:  config["rabbitmq"]["host"],
	vhost: config["rabbitmq"]["vhost"],
	user:  config["rabbitmq"]["user"],
	pass:  config["rabbitmq"]["pass"],
	tls:   config["rabbitmq"]["ssl"],
	verify_peer: false,
)

conn.start()
ch = conn.create_channel()

github_queue = ch.queue("@samueldr.github-events-to-irc:github")
github_queue.bind(ch.topic($webhook_exchange, durable: true), routing_key: "push.#")
github_queue.bind(ch.topic($webhook_exchange, durable: true), routing_key: "issues.#")
github_queue.bind(ch.topic($webhook_exchange, durable: true), routing_key: "pull_request.#")

irc_exchange = ch.fanout($irc_exchange, durable: true)

github_queue.subscribe(block: true) do |delivery_info, metadata, payload|
	type = delivery_info[:routing_key].split(".").first
	data = JSON.parse(payload)
	reply = GithubWebhook.handle(data, type: type)

	reply.each do |msg|
		irc_exchange.publish(JSON.generate({
			target: "#nixos",
			body: msg,
			message_type: "notice",
		}), routing_key: "queue-publish")
	end
end
