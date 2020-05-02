require_relative "libs"

connect()
channel = $conn.create_channel()
github_queue = channel.queue("", exclusive: true)
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "push.#")
# Disabled in code as it's spammy AF.
#github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "issues.#")
github_queue.bind(channel.topic(WEBHOOK_EXCHANGE, durable: true), routing_key: "pull_request.#")
irc_exchange = channel.direct("", durable: true, passive: true)

log "Waiting for events..."
github_queue.subscribe(block: true) do |delivery_info, metadata, payload|
	# Assuming the routing key to stay `event_type.owner/repo`.
	type, repository = delivery_info[:routing_key].split(".")
	data = JSON.parse(payload)

	# Skip repositories that are private on GitHub.
	next if data["repository"]["private"]

	handler = GithubWebhook.handle(data, type: type)
	reply = handler.to_messages

	if handler.filtered?
		log "Filtering out #{reply.length} messages..."
		reply.map { |m| " [filtered] #{m}" }.each do |m|
			log m
		end
		next
	end

	# Find the repository's channels...
	irc_channels = $channels["per-repository"][repository.downcase] if $channels["per-repository"]
	# Or use the defaults.
	irc_channels ||= $channels["default"]

	reply.each do |msg|
		msg = msg.gsub(/[\n\r]/, "")
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
