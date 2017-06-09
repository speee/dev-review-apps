class Task < ApplicationRecord
  include AwsAccessible

  belongs_to :task_definition
  has_many :endpoints, dependent: :destroy

  validates :arn, presence: true
  validates :task_definition, presence: true
  validates :pr_number,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    uniqueness: { scope: :task_definition }
  validates :endpoints, presence: true

  after_initialize :build_endpoints, if: -> { new_record? && endpoints.blank? }

  class << self
    def find_by_revieee_target(revieee_target)
      joins(:task_definition)
        .merge(TaskDefinition.where(repository: revieee_target.repository))
        .find_by(pr_number: revieee_target.pr_number)
    end
  end

  def stop
    ecs.stop_task(
      cluster: Settings.aws.ecs.cluster_name,
      task: arn,
    )
  end

  private

  def build_endpoints
    return unless task_resource
    task_resource[:containers].each do |c|
      port = c[:network_bindings].map(&:host_port).first
      next unless port
      endpoints.build(ip: private_ip, port: port)
    end
  end

  def private_ip
    @private_ip ||= ec2.describe_instances(
      instance_ids: [instance_id]
    ).dig(:reservations, 0, :instances, 0, :private_ip_address)
  end

  def instance_id
    @instance_id ||= ecs.describe_container_instances(
      cluster: Settings.aws.ecs.cluster_name,
      container_instances: [task_resource.dig(:container_instance_arn)]
    ).dig(:container_instances, 0, :ec2_instance_id)
  end

  def task_resource
    @task_resource ||= ecs.wait_until(
      :tasks_running,
      tasks: [arn],
      cluster: Settings.aws.ecs.cluster_name,
    ).dig(:tasks, 0)
  end
end
