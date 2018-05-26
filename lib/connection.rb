require "bunny"

def connect()
	log "connecting..."
	$conn = Bunny.new(
		host:  $config["rabbitmq"]["host"],
		vhost: $config["rabbitmq"]["vhost"],
		user:  $config["rabbitmq"]["username"],
		pass:  $config["rabbitmq"]["password"],
		tls:   $config["rabbitmq"]["ssl"],
		verify_peer: false,
	)
	channels = $config["github-to-irc"]["channels"]

	$conn.start()
	log "connected!"
end
