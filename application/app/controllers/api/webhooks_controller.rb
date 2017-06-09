class Api::WebhooksController < Api::ApplicationController
  before_action :authenticate

  def github_callback
    event_name = request.headers.fetch('X-GitHub-Event')
    payload = JSON.parse(request_body)
    action = PullRequest::Actions.build(event_name: event_name, payload: payload)

    if action
      pid = fork do
        fork do
          action.handle
        end
      end
      Process.waitpid(pid)
    end

    head :ok
  end

  private

  def authenticate
    head :unauthorized unless valid_signature?
  end

  def valid_signature?
    github_signature = request.headers['X-Hub-Signature']
    return false unless github_signature

    signature = "sha1=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Settings.github.webhook_secret, request_body)}"
    Rack::Utils.secure_compare(signature, github_signature)
  end

  def request_body
    @request_body ||= request.body.read
  end
end
