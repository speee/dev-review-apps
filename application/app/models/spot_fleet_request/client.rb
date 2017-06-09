# frozen_string_literal: true
module SpotFleetRequest
  class Client
    include AwsAccessible

    def create
      spot_instance = SpotInstance.new
      request_config = RequestConfig.new(spot_instance)
      response = ec2.request_spot_fleet(request_config.to_hash)
      Rails.logger.info "spot fleet request is accepted! request_id: #{response.spot_fleet_request_id}"
    end

    def describe(spot_fleet_request_id)
      response = ec2.describe_spot_fleet_requests({ spot_fleet_request_ids: [ spot_fleet_request_id ] })
      Rails.logger.info response
    end

    def cancel(spot_fleet_request_id)
      response = ec2.cancel_spot_fleet_requests({ spot_fleet_request_ids: [ spot_fleet_request_id ], terminate_instances: true })
      Rails.logger.info response
    end
  end
end
