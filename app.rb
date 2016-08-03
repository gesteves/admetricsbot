require 'sinatra'
require 'json'
require 'httparty'
require 'dotenv'

configure do
  Dotenv.load
  $stdout.sync = true
end

get '/' do
  'howdy :wave:'
end

post '/endpoint' do
  post_to_slack(request.body.read)
  status 200
  headers "Access-Control-Allow-Origin" => "*"
end


def post_to_slack(text)
  payload = {
    text: "```#{text}```",
    username: 'Ad Metrics Bot',
    icon_emoji: ':thinking_face:'
  }
  HTTParty.post(ENV['INCOMING_WEBHOOK'], body: payload.to_json)
end
