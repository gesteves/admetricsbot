require 'sinatra'
require 'json'
require 'httparty'
require 'dotenv'

configure do
  Dotenv.load
  $stdout.sync = true
end

get '/' do
  'Good luck with your interview!'
end

get '/metrics' do
  status 400
  'Did you mean to make a POST request?'
end

post '/metrics' do
  body = request.body.read
  begin
    JSON.parse(body)
    post_to_slack(body)
    code = 200
    response = 'Woo! It worked!'
  rescue JSON::ParserError
    code = 400
    response = 'Oops, looks like that’s not valid json!'
  rescue
    code = 500
    response = 'Uh oh, something bad happened!'
  end
  status code
  headers "Access-Control-Allow-Origin" => "*"
  body response
end

get '/ads/:id' do
  @ad_id = params[:id].gsub('-','_').to_sym
  headlines = {
    ad_1: 'This is a classy ad',
    ad_2: 'This is a cool ad',
    ad_3: 'This is a great ad'
  }

  @headline = headlines[@ad_id]

  headers "Access-Control-Allow-Origin" => "*"
  if @headline.nil?
    status 404
    'Ad not found!'
  else
    status 200
    erb :ad
  end
end


def post_to_slack(text)
  payload = {
    text: "```#{text}```",
    username: 'Ad Metrics Bot',
    icon_emoji: ':thinking_face:'
  }
  HTTParty.post(ENV['INCOMING_WEBHOOK'], body: payload.to_json)
end
