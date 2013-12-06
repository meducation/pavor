require 'sinatra'
require 'sinatra/cross_origin'
require 'aws-sdk'

configure do

    config = YAML.load_file("config.yml")
    set :access_key, config["access_key"]
    set :secret_key, config["secret_key"]
    set :region, config["region"]

    enable :cross_origin
    set :allow_methods, [:get]
    # Use http://localhost:3000 for local testing
    set :allow_origin, 'http://dashboard.meducation.net'
end

get '/' do
    cw = AWS::CloudWatch.new(
        :access_key_id => "#{settings.access_key}",
        :secret_access_key => "#{settings.secret_key}",
        :region => "#{settings.region}")

    alarm_names = []
    resp = cw.client.describe_alarms(:state_value => "ALARM")
    resp[:metric_alarms].each do |alarm|
       alarm_names << alarm[:alarm_name]
    end
    output =  { :alarms => alarm_names}
    output.to_json
end
