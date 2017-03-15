require "rubygems"
require "bundler/setup"
require "sinatra"
require File.join(File.dirname(__FILE__), "config", "environment")

module DokkuDaemonAPI
  class App < Sinatra::Base
    set :logger, Logger.new(STDOUT)
    include Helpers::ApplicationHelper

    before do
      content_type :json
      authenticate!
    end

    get '/commands' do
      Command.all.to_json
    end

    post '/commands' do
      command = Command.create(command: params[:cmd])

      if command.valid?
        CommandRunner.perform_async(command.id)
        command.to_json
      else
        {status: :error, messages: command.errors.collect{|field,msg| "#{field} #{msg}"}}.to_json
      end
    end

    get '/commands/:token' do
      command = Command.first(token: params[:token])

      if command
        command.to_json
      else
        {status: :error, message: :not_found}.to_json
      end
    end
  end
end
