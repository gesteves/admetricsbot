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

get '/endpoint' do
  status 400
  'Did you mean to make a POST request?'
end

post '/endpoint' do
  body = request.body.read
  begin
    JSON.parse(body)
    post_to_slack(body)
    code = 200
    response = 'ok'
  rescue JSON::ParserError => e
    code = 400
    response = 'Looks like that’s not valid json!'
  rescue => e
    code = 500
    response = 'Uh oh, something bad happened.'
  end
  status code
  headers "Access-Control-Allow-Origin" => "*"
  body response
end


def post_to_slack(text)
  payload = {
    text: "```#{text}```",
    username: 'Ad Metrics Bot',
    icon_emoji: ':thinking_face:'
  }
  HTTParty.post(ENV['INCOMING_WEBHOOK'], body: payload.to_json)
end
