require "bunny"
require_relative "./webhook.rb"
require "pp"
require "json"

$vhost = "ofborg"
$user = "webhook"
$pass = "webhook"
$exchange = "github-events"

conn = Bunny.new(vhost: $vhost, user: $user, pass: $pass)
conn.start()
ch = conn.create_channel()
q = ch.queue("github-events-to-irc")
q.bind(ch.topic($exchange, durable: true), routing_key: "push.#")
q.bind(ch.topic($exchange, durable: true), routing_key: "issues.#")
q.bind(ch.topic($exchange, durable: true), routing_key: "pull_request.#")

q.subscribe(block: true) do |delivery_info, metadata, payload|
	type = delivery_info[:routing_key].split(".").first
	data = JSON.parse(payload)
	reply = GithubWebhook.handle(data, type: type)
end
