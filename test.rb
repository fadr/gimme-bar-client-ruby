#!/usr/bin/env ruby

require File.join(".", File.dirname(__FILE__), "gimmebar")

client = GimmeBar::Client.new
if !ENV['GIMMEBAR_ACCESS_TOKEN'].nil?
	client.accessToken = ENV['GIMMEBAR_ACCESS_TOKEN']
	assets = client.getAssets()
	assets["records"].each do |asset|
		puts asset['short_url'] + ' "' + asset['title'] + '" ' + asset['asset_type'] + (asset['private'] ? ' private' : ' public')
	end
elsif !ENV['GIMMEBAR_CLIENT_ID'].nil? && !ENV['GIMMEBAR_REQUEST_TOKEN'].nil?
	data = client.authExchangeReqToken({:client_id=>ENV['GIMMEBAR_CLIENT_ID'], :token=>ENV['GIMMEBAR_REQUEST_TOKEN'], :response_type=>'code'})
	puts("Got authorization token:" + data['code'])
	puts("Requesting access token.")
	data = client.authExchangeAuthToken({:code=>data['code'], :grant_type=>'authorization_code'})
	puts("Got access token:" + data['access_token'])
	puts("You can now call:")
	puts("GIMMEBAR_ACCESS_TOKEN=" + data['access_token'] + " ruby test.rb")
elsif !ENV['GIMMEBAR_CLIENT_ID'].nil? && !ENV['GIMMEBAR_CLIENT_SECRET'].nil?
	
	data = client.authGenerateReqToken({:client_id=> ENV['GIMMEBAR_CLIENT_ID'], :client_secret=> ENV['GIMMEBAR_CLIENT_SECRET'], :type=>'app'})
	puts("Got request token:" + data['request_token'])
	puts('Send the user to:')
	puts(
		'https://gimmebar.com/authorize?client_id=' + ENV['GIMMEBAR_CLIENT_ID'] + '&token=' + data['request_token'] + '&response_type=code'
	)
	puts('... and then run: ')
	puts('GIMMEBAR_CLIENT_ID=' + ENV['GIMMEBAR_CLIENT_ID'] + ' GIMMEBAR_REQUEST_TOKEN=' + data['request_token'] + ' ruby test.rb')
else
	puts("You must set ENV['GIMMEBAR_CLIENT_ID'] and ENV['GIMMEBAR_CLIENT_SECRET']");
	puts("GIMMEBAR_CLIENT_ID=4e1472222eaaaaaaaa00000 GIMMEBAR_CLIENT_SECRET=12345 ruby test.rb");
	
end
