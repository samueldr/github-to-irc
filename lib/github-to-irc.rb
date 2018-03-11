require "bunny"
require "json"
require "date"
require_relative "./webhook.rb"

unless ARGV.count == 1
	STDERR.puts("Needs config.json as argv1")
	exit 1
end

# https://github.com/NixOS/ofborg/blob/03312b8176bfd197aeb693721b516c6a25a4611e/ircbot/src/config.rs#L17
config = JSON.parse(File.read(ARGV.first))

def log(msg)
	puts "[#{DateTime.now.strftime("%F %H:%M:%S")}] <github-to-irc> #{msg}"
end

WEBHOOK_EXCHANGE = "github-events"
IRC_EXCHANGE = "exchange-messages"

log "connecting..."
conn = Bunny.new(
	host:  config["rabbitmq"]["host"],
	vhost: config["rabbitmq"]["vhost"],
	user:  config["rabbitmq"]["username"],
	pass:  config["rabbitmq"]["password"],
	tls:   config["rabbitmq"]["ssl"],
	verify_peer: false,
)

conn.start()
log "connected!"

channel = conn.create_channel()
github_queue = channel.queue()
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "push.#")
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "issues.#")
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "pull_request.#")
irc_exchange = channel.fanout(IRC_EXCHANGE, durable: true, passive: true)

log "Waiting for events..."
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

log "Bye!"
