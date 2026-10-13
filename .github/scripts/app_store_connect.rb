# frozen_string_literal: true

require 'base64'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

class AppStoreConnect
  API_HOST = 'api.appstoreconnect.apple.com'
  EDITABLE_STATES = %w[PREPARE_FOR_SUBMISSION DEVELOPER_REJECTED REJECTED METADATA_REJECTED INVALID_BINARY].freeze
  PROCESSING_TIMEOUT_SECONDS = 40 * 60
  WHATS_NEW_LIMIT = 4000

  def initialize(bundle_identifier)
    @bundle_identifier = bundle_identifier
    @key_id = ENV.fetch('ASC_KEY_ID')
    @issuer_id = ENV.fetch('ASC_ISSUER_ID')
    @private_key = OpenSSL::PKey::EC.new(File.read(ENV.fetch('ASC_KEY_PATH')))
  end

  def next_build_number(version)
    builds = collect("/v1/builds?filter[app]=#{app_id}&filter[preReleaseVersion.version]=#{version}" \
                     '&filter[preReleaseVersion.platform]=IOS&limit=200')
    (builds.map { |build| build.dig('attributes', 'version').to_i }.max || 0) + 1
  end

  def create_profile(name, output_path)
    bundle_id = collect("/v1/bundleIds?filter[identifier]=#{@bundle_identifier}&filter[platform]=IOS&limit=200")
                .find { |item| item.dig('attributes', 'identifier') == @bundle_identifier }
    abort "Bundle ID #{@bundle_identifier} is not registered" unless bundle_id
    certificates = collect('/v1/certificates?filter[certificateType]=DISTRIBUTION&limit=200')
    abort 'No Apple Distribution certificate registered' if certificates.empty?
    body = {
      data: {
        type: 'profiles',
        attributes: { name: name, profileType: 'IOS_APP_STORE' },
        relationships: {
          bundleId: { data: { type: 'bundleIds', id: bundle_id['id'] } },
          certificates: { data: certificates.map { |item| { type: 'certificates', id: item['id'] } } }
        }
      }
    }
    profile = request(:post, '/v1/profiles', body).fetch('data')
    File.binwrite(output_path, Base64.decode64(profile.dig('attributes', 'profileContent')))
    puts "PROFILE_ID=#{profile['id']}"
    puts "PROFILE_UUID=#{profile.dig('attributes', 'uuid')}"
  end

  def delete_profile(profile_id)
    request(:delete, "/v1/profiles/#{profile_id}")
  end

  def prepare_release(version, build_number, changelog_path)
    build = wait_for_processed_build(version, build_number)
    declare_exempt_encryption(build)
    store_version = editable_version(version)
    write_whats_new(store_version, version, changelog_path)
    request(:patch, "/v1/appStoreVersions/#{store_version['id']}/relationships/build",
            { data: { type: 'builds', id: build['id'] } })
    puts "Build #{build_number} attached to iOS version #{version} (#{store_version['id']}); not submitted for review"
  end

  private

  def app_id
    @app_id ||= begin
      app = collect("/v1/apps?filter[bundleId]=#{@bundle_identifier}&limit=200")
            .find { |item| item.dig('attributes', 'bundleId') == @bundle_identifier }
      abort "No app with bundle #{@bundle_identifier} in App Store Connect" unless app
      app['id']
    end
  end

  def wait_for_processed_build(version, build_number)
    deadline = Time.now + PROCESSING_TIMEOUT_SECONDS
    loop do
      build = collect("/v1/builds?filter[app]=#{app_id}&filter[version]=#{build_number}" \
                      "&filter[preReleaseVersion.version]=#{version}&filter[preReleaseVersion.platform]=IOS").first
      state = build && build.dig('attributes', 'processingState')
      return build if state == 'VALID'
      abort "Build #{build_number} finished processing as #{state}" if %w[INVALID FAILED].include?(state)
      abort "Build #{build_number} was not processed within #{PROCESSING_TIMEOUT_SECONDS / 60} minutes" if Time.now > deadline
      puts "Waiting for build #{build_number}: #{state || 'not listed yet'}"
      sleep 30
    end
  end

  def declare_exempt_encryption(build)
    return unless build.dig('attributes', 'usesNonExemptEncryption').nil?

    request(:patch, "/v1/builds/#{build['id']}",
            { data: { type: 'builds', id: build['id'], attributes: { usesNonExemptEncryption: false } } })
  end

  def editable_version(version)
    versions = collect("/v1/apps/#{app_id}/appStoreVersions?filter[platform]=IOS&limit=200")
    same = versions.find { |item| item.dig('attributes', 'versionString') == version }
    if same
      state = same.dig('attributes', 'appStoreState')
      abort "iOS version #{version} is already #{state}: bump the version in pubspec.yaml" unless EDITABLE_STATES.include?(state)
      return same
    end
    pending = versions.find { |item| EDITABLE_STATES.include?(item.dig('attributes', 'appStoreState')) }
    abort "iOS version #{pending.dig('attributes', 'versionString')} is still editable: finish or remove it first" if pending
    body = {
      data: {
        type: 'appStoreVersions',
        attributes: { platform: 'IOS', versionString: version, releaseType: 'MANUAL' },
        relationships: { app: { data: { type: 'apps', id: app_id } } }
      }
    }
    request(:post, '/v1/appStoreVersions', body).fetch('data')
  end

  def write_whats_new(store_version, version, changelog_path)
    release = JSON.parse(File.read(changelog_path)).fetch('releases').find { |item| item['version'] == version }
    unless release
      puts "No CHANGELOG.json entry for #{version}: What's New left untouched"
      return
    end
    collect("/v1/appStoreVersions/#{store_version['id']}/appStoreVersionLocalizations").each do |localization|
      language = localization.dig('attributes', 'locale')[0, 2]
      text = whats_new_text(release, language)
      next unless text

      request(:patch, "/v1/appStoreVersionLocalizations/#{localization['id']}",
              { data: { type: 'appStoreVersionLocalizations', id: localization['id'], attributes: { whatsNew: text } } })
    end
  end

  def whats_new_text(release, language)
    summary = release.dig('summary', language)
    return nil unless summary

    lines = release.fetch('changes', []).map do |change|
      "- #{change.dig('title', language)}: #{change.dig('description', language)}"
    end
    [summary, *lines].join("\n\n")[0, WHATS_NEW_LIMIT]
  end

  def collect(path)
    items = []
    while path
      page = request(:get, path)
      items.concat(page.fetch('data'))
      path = page.dig('links', 'next')
    end
    items
  end

  def request(method, path, body = nil)
    uri = URI(path.start_with?('http') ? path : "https://#{API_HOST}#{path}")
    abort 'Refusing to send the token outside App Store Connect' unless uri.host == API_HOST
    verb = { get: Net::HTTP::Get, post: Net::HTTP::Post, patch: Net::HTTP::Patch, delete: Net::HTTP::Delete }.fetch(method)
    http_request = verb.new(uri)
    http_request['Authorization'] = "Bearer #{token}"
    http_request['Content-Type'] = 'application/json'
    http_request.body = JSON.generate(body) if body
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 120) { |http| http.request(http_request) }
    parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
    return parsed if response.is_a?(Net::HTTPSuccess)

    details = (parsed['errors'] || []).map { |error| "#{error['code']}: #{error['detail']}" }
    abort "#{method.to_s.upcase} #{uri.path} failed with HTTP #{response.code}\n#{details.join("\n")}"
  end

  def token
    return @token if @token && Time.now.to_i < @expires_at - 60

    @expires_at = Time.now.to_i + 1200
    header = base64url(JSON.generate(alg: 'ES256', kid: @key_id, typ: 'JWT'))
    payload = base64url(JSON.generate(iss: @issuer_id, exp: @expires_at, aud: 'appstoreconnect-v1'))
    signing_input = "#{header}.#{payload}"
    der = @private_key.sign(OpenSSL::Digest::SHA256.new, signing_input)
    raw = OpenSSL::ASN1.decode(der).value.map { |integer| integer.value.to_s(2).rjust(32, "\x00") }.join
    @token = "#{signing_input}.#{base64url(raw)}"
  end

  def base64url(data)
    Base64.urlsafe_encode64(data).delete('=')
  end
end

command, *arguments = ARGV
client = AppStoreConnect.new(ENV.fetch('BUNDLE_IDENTIFIER'))
case command
when 'next-build-number' then puts client.next_build_number(arguments.fetch(0))
when 'create-profile' then client.create_profile(arguments.fetch(0), arguments.fetch(1))
when 'delete-profile' then client.delete_profile(arguments.fetch(0))
when 'prepare-release' then client.prepare_release(arguments.fetch(0), arguments.fetch(1), arguments.fetch(2))
else abort "Unknown command: #{command.inspect}"
end
