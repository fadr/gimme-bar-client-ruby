#!/usr/bin/env ruby

require 'curb'
require 'yajl'
require 'cgi'

module GimmeBar
	Methods = {
		"getUser"=>{"path"=>"user","method"=>"GET"},
		"getUserById"=>{"path"=>"user\/:user_id","method"=>"GET"},
		"getUserByName"=>{"path"=>"users\/find","method"=>"GET"},
		"createAsset"=>{"path"=>"asset","method"=>"POST"},
		"getAssetById"=>{"path"=>"asset\/:asset_id","method"=>"GET"},
		"updateAsset"=>{"path"=>"asset\/:asset_id","method"=>"POST"},
		"deleteAsset"=>{"path"=>"asset\/:asset_id","method"=>"DELETE"},
		"getAssets"=>{"path"=>"assets","method"=>"GET"},
		"getAssetsByUserId"=>{"path"=>"assets\/user\/:user_id","method"=>"GET"},
		"searchAssets"=>{"path"=>"assets\/search","method"=>"GET"},
		"getCollections"=>{"path"=>"collections","method"=>"GET"},
		"getCollectionsByUserId"=>{"path"=>"collections\/user","method"=>"GET"},
		"getAssetCollections"=>{"path"=>"collections\/asset","method"=>"GET"},
		"getCollectionBySlug"=>{"path"=>"collection\/slug","method"=>"GET"},
		"getCollectionById"=>{"path"=>"collection\/:collection_id","method"=>"GET"},
		"updateCollection"=>{"path"=>"collection\/:collection_id","method"=>"POST"},
		"deleteCollection"=>{"path"=>"collection\/:collection_id","method"=>"DELETE"},
		"createCollection"=>{"path"=>"collection","method"=>"POST"},
		"addAssetsToCollection"=>{"path"=>"collection\/:collection_id\/add","method"=>"POST"},
		"removeAssetsFromCollection"=>{"path"=>"collection\/:collection_id\/remove","method"=>"POST"},
		"getTags"=>{"path"=>"tags","method"=>"GET"},
		"authGenerateReqToken"=>{"path"=>'auth/reqtoken',"method"=>'POST', "unsigned"=> true},
		"authExchangeReqToken"=>{"path"=>'auth/exchange/request',"method"=>'POST',"unsigned"=>true},
		"authExchangeAuthToken"=>{"path"=>'auth/exchange/authorization', "method"=>"POST","unsigned"=>true},
		"getPublicAssetsByUsername"=>{"path"=>'public/assets/:username',"method"=>"GET","unsigned"=>true},
		"getPublicAssetsByCollection"=>{"path"=>'public/assets/:username/:collection',"method"=>'GET',"unsigned"=>true}
	
	}
	
	BaseURL = 'https://gimmebar.com/api'
	APIVersion = '0'

	class Client
		Methods.each do |name, opts|
			define_method(name) do |data={}|
				url = buildURL(opts['path'], data)
				qs = buildQueryString(data)

				url = url + "?"+qs if qs != "" if opts['method'] == 'GET'
				qs = nil if opts['method'] != 'POST' && opts['method'] != 'PUT'
				
				doReq(url, qs, opts['method'], !opts["unsigned"])
			end
		end
		
		attr_accessor :accessToken
		def initialize(accessToken = nil)
			self.accessToken = accessToken
		end
		
		def buildURL(template, params)
			params.each do |name, value|
				regex = Regexp.new(":#{name}(/|$)")
				if template =~ regex
					template = template.gsub(regex, value.to_s)
					params.delete(name)
				end
			end
			return template
		end

		def buildQueryString(opts)
			output = []
			opts.each do |name, value|
				if value.is_a?(Enumerable)
					value.each { |v| output.push([CGI::escape(name.to_s + '[]'), CGI::escape(v.to_s)]) }
				else
					output.push([CGI::escape(name.to_s), CGI::escape(value.to_s)])
				end
			end
			output.collect {|pair| pair.join('=') }.join('&')
		end

		def doReq(path, data, method, signed)
			fullURL = [BaseURL, 'v'+APIVersion, path].join('/');
			args = ["http_#{method.downcase}", fullURL]
			args.push(data) if !data.nil? && !data.empty?
			c = Curl::Easy.send(*args) do |curl|
				curl.headers['User-Agent'] = "Gimmebar/0.0 ruby #{RUBY_VERSION} #{RUBY_PLATFORM}/curb"
				curl.headers['Accept'] = 'application/json'
				curl.headers['Authorization'] = 'Bearer ' + self.accessToken if signed
			end
			Yajl::Parser.parse(c.body_str)
		end
	end
	
end

client = GimmeBar::Client.new('authToken')
