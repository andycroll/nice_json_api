# frozen_string_literal: true

require 'uri'

require 'nice_json_api/version'
require 'nice_json_api/internal/inflector'

module NiceJsonApi
  # Response from a friendly API
  class Response
    def initialize(url, method: :get, body: nil, auth: nil)
      @url = url
      @method = method
      @body = body
      @auth = auth
    end

    def body
      raw.body
    end

    def body_hash
      JSON.parse(body) || {}
    rescue JSON::ParserError
      {}
    end

    def code
      raw.code
    end

    def message
      raw.message
    end

    def raw
      @raw ||= fetch(initial_uri, method: @method, body: @body, auth: @auth)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def fetch(uri, method: :get, body: nil, limit: 10, auth: nil)
      return NullResponse.new('404', '{}', 'Too Many Redirects') if limit.zero?

      case response = SingleRequest.new(uri,
                                        method: method,
                                        body: body,
                                        auth: auth).response
      when Net::HTTPRedirection, Net::OpenTimeout
        fetch(response['location'], method: method, body: body, limit: --limit, auth: auth)
      else
        response
      end
    rescue Errno::ECONNREFUSED
      NullResponse.new('404', '{}', 'Host not found')
    rescue Errno::EHOSTUNREACH
      fetch(uri, method: method, body: body, limit: --limit, auth: auth)
    end
    # rubocop:enable Metrics/MethodLength

    def initial_uri
      @url = "https://#{@url}" unless @url[0..3] == 'http'
      URI(@url)
    end

    # Do a single html request
    class SingleRequest
      def initialize(uri, method: :get, body: nil, auth: nil)
        @uri = URI(uri)
        @method = method
        @body = body
        @auth = Hash(auth)
      end

      def response
        Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: ssl?) do |http|
          http.request(req)
        end
      end

      private

      def auth_header
        if @auth.key?(:user)
          "Basic #{Base64.strict_encode64("#{@auth[:user]}:#{@auth[:password]}")}"
        elsif @auth.key?(:bearer)
          "Bearer #{@auth[:bearer]}"
        end
      end

      def headers
        {
          'Accept' => 'application/json',
          'Authorization' => auth_header,
          'Content-Type' => @body ? 'application/json' : nil,
          'User-Agent' => "NiceJsonApi Ruby #{VERSION}"
        }.reject { |_, v| v.nil? }
      end

      def klass
        NiceJsonApi::Internal::Inflector.constantize("Net::HTTP::#{@method.to_s.capitalize}")
      end

      def manual_header
        return {} unless @auth.key?(:header)
        { @auth[:header][:name] => @auth[:header][:value] }
      end

      def req
        @req ||= begin
          req = klass.new(@uri)
          req.body = @body.to_json if @body
          headers.merge(manual_header).each { |header, value| req[header] = value }
          req
        end
      end

      def ssl?
        @uri.scheme == 'https'
      end
    end

    NullResponse = Struct.new(:code, :body, :message)
  end
end
