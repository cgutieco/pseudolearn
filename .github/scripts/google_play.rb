# frozen_string_literal: true

require 'base64'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

class GooglePlay
  API_HOST = 'androidpublisher.googleapis.com'
  TOKEN_URI = URI('https://oauth2.googleapis.com/token')
  SCOPE = 'https://www.googleapis.com/auth/androidpublisher'
  RELEASE_STATUSES = %w[completed draft].freeze
  RELEASE_NOTES_LIMIT = 500
  RELEASE_NOTES_LOCALES = { 'es' => 'es-419', 'en' => 'en-US' }.freeze

  def initialize(package_name)
    @package_name = package_name
    @credentials = JSON.parse(File.read(ENV.fetch('GOOGLE_PLAY_SERVICE_ACCOUNT_PATH')))
  end

  def next_version_code
    within_discarded_edit do |edit_id|
      bundles = request(:get, "#{edit_path(edit_id)}/bundles").fetch('bundles', [])
      (bundles.map { |bundle| bundle['versionCode'].to_i }.max || 0) + 1
    end
  end

  def upload(bundle_path, track, status, release_name, changelog_path)
    abort "Unknown release status #{status}: use #{RELEASE_STATUSES.join(' or ')}" unless RELEASE_STATUSES.include?(status)
    edit_id = request(:post, "/androidpublisher/v3/applications/#{@package_name}/edits", {}).fetch('id')
    version_code = upload_bundle(edit_id, bundle_path)
    release = { name: release_name, versionCodes: [version_code.to_s], status: status }
    notes = release_notes(release_name.split(' ').first, changelog_path)
    release[:releaseNotes] = notes unless notes.empty?
    request(:put, "#{edit_path(edit_id)}/tracks/#{track}", { track: track, releases: [release] })
    request(:post, "#{edit_path(edit_id)}:commit")
    puts "Version code #{version_code} released to the #{track} track as #{status}"
  rescue StandardError, SystemExit
    discard(edit_id) if edit_id
    raise
  end

  private

  def within_discarded_edit
    edit_id = request(:post, "/androidpublisher/v3/applications/#{@package_name}/edits", {}).fetch('id')
    yield edit_id
  ensure
    discard(edit_id) if edit_id
  end

  def discard(edit_id)
    request(:delete, edit_path(edit_id), nil, tolerate_failure: true)
  end

  def edit_path(edit_id)
    "/androidpublisher/v3/applications/#{@package_name}/edits/#{edit_id}"
  end

  def upload_bundle(edit_id, bundle_path)
    uri = URI("https://#{API_HOST}/upload#{edit_path(edit_id)}/bundles?uploadType=media")
    http_request = Net::HTTP::Post.new(uri)
    http_request['Authorization'] = "Bearer #{token}"
    http_request['Content-Type'] = 'application/octet-stream'
    http_request['Content-Length'] = File.size(bundle_path).to_s
    File.open(bundle_path, 'rb') do |file|
      http_request.body_stream = file
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 600, write_timeout: 600) do |http|
        http.request(http_request)
      end
      return checked(response, :post, uri).fetch('versionCode')
    end
  end

  def release_notes(version, changelog_path)
    release = JSON.parse(File.read(changelog_path)).fetch('releases').find { |item| item['version'] == version }
    return [] unless release

    RELEASE_NOTES_LOCALES.filter_map do |language, locale|
      summary = release.dig('summary', language)
      { language: locale, text: summary[0, RELEASE_NOTES_LIMIT] } if summary
    end
  end

  def request(method, path, body = nil, tolerate_failure: false)
    uri = URI("https://#{API_HOST}#{path}")
    verb = { get: Net::HTTP::Get, post: Net::HTTP::Post, put: Net::HTTP::Put, delete: Net::HTTP::Delete }.fetch(method)
    http_request = verb.new(uri)
    http_request['Authorization'] = "Bearer #{token}"
    http_request['Content-Type'] = 'application/json'
    http_request.body = JSON.generate(body) if body
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 120) { |http| http.request(http_request) }
    return {} if tolerate_failure && !response.is_a?(Net::HTTPSuccess)

    checked(response, method, uri)
  end

  def checked(response, method, uri)
    parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
    return parsed if response.is_a?(Net::HTTPSuccess)

    abort "#{method.to_s.upcase} #{uri.path} failed with HTTP #{response.code}\n#{parsed.dig('error', 'message')}"
  end

  def token
    return @token if @token && Time.now.to_i < @expires_at - 60

    issued_at = Time.now.to_i
    @expires_at = issued_at + 3600
    header = base64url(JSON.generate(alg: 'RS256', typ: 'JWT'))
    claims = { iss: @credentials.fetch('client_email'), scope: SCOPE, aud: TOKEN_URI.to_s, iat: issued_at, exp: @expires_at }
    signing_input = "#{header}.#{base64url(JSON.generate(claims))}"
    signature = OpenSSL::PKey::RSA.new(@credentials.fetch('private_key')).sign(OpenSSL::Digest::SHA256.new, signing_input)
    response = Net::HTTP.post_form(TOKEN_URI, grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                                              assertion: "#{signing_input}.#{base64url(signature)}")
    abort "Google OAuth token request failed with HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    @token = JSON.parse(response.body).fetch('access_token')
  end

  def base64url(data)
    Base64.urlsafe_encode64(data).delete('=')
  end
end

command, *arguments = ARGV
client = GooglePlay.new(ENV.fetch('PACKAGE_NAME'))
case command
when 'next-version-code' then puts client.next_version_code
when 'upload'
  abort 'usage: upload <bundle> <track> <completed|draft> <release name> <CHANGELOG.json>' unless arguments.size == 5
  client.upload(*arguments)
else abort "Unknown command: #{command.inspect}"
end
