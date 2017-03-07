module AwsAccess
  def ec2
    @ec2 ||= Aws::EC2::Client.new(region: Settings.aws.region)
  end

  def ecs
    @ecs ||= Aws::ECS::Client.new(region: Settings.aws.region)
  end
end