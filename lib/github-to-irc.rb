require_relative "libs"

connect()
channel = $conn.create_channel()
github_queue = channel.queue()
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "push.#")
# Disabled in code as it's spammy AF.
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "issues.#")
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "pull_request.#")
irc_exchange = channel.fanout(IRC_EXCHANGE, durable: true, passive: true)

log "Waiting for events..."
github_queue.subscribe(block: true) do |delivery_info, metadata, payload|
	# Assuming the routing key to stay `event_type.owner/repo`.
	type, repository = delivery_info[:routing_key].split(".")
	data = JSON.parse(payload)
	reply = GithubWebhook.handle(data, type: type)

	# Find the repository's channels...
	irc_channels = channels["per-repository"][repository.downcase] if channels["per-repository"]
	# Or use the defaults.
	irc_channels ||= channels["default"]

	reply.each do |msg|
		log msg.inspect
		irc_channels.each do |c|
			irc_exchange.publish(JSON.generate({
				target: c,
				body: msg,
				message_type: "notice",
			}), routing_key: "queue-publish")
		end
	end
end

log "Bye!"
