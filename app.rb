require "sinatra"
require "sinatra/reloader"# if development?

require_relative "./webhook.rb"

also_reload "#{__dir__}/webhook.rb"

after_reload do
	puts "reloaded"
end

require "pp"

set :bind, "0.0.0.0"

get "/" do
	"Hello world?"
end

post "/hook" do
	type = request.env["HTTP_X_GITHUB_EVENT"]
	push = JSON.parse(request.body.read)
	reply = GithubWebhook.handle(push, type: type)

	#pp push
	pp reply

	"null"
end
