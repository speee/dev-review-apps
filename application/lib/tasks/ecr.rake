namespace :ecr do
  namespace :group do
    desc 'Create Iam Group (rails ecr:group:create[group_name])'
    task :create, [:name] => :environment do |task, args|
      group = Ecr::IamGroup.create(args.name)
      pp group
    end
  end

  namespace :user do
    desc 'Create Iam User to use ECR (rails ecr:user:create[user_name])'
    task :create, [:name] => :environment do |task, args|
      user = Ecr::IamUser.create(args.name)
      response = user.create_access_key
      pp user, response
    end

    desc 'Add specified Iam User to Iam Group (rails ecr:user:join_group[user_name, group])'
    task :join_group, [:user_name, :group_name] => :environment do |task, args|
      group = Ecr::IamGroup.new(args.group_name)
      user = Ecr::IamUser.new(args.user_name)
      pp user.join(group)
    end
  end

  namespace :repository do
    desc 'Create ECR Repository. if you set user_arn parameter, this task set access_policy to Repository (rails ecr:repository:create[name, user_arn(option)] )'
    task :create, [:name, :user_arn] => :environment do |task, args|
      repository = Ecr::Repository.create(args.name)
      pp repository.name, repository.registry_id

      next if args.user_arn.nil?
      response = repository.allow_access(args.user_arn)
      pp response
    end

    desc 'Allow user access To ECR ( rails ecr:repository:allow_access[user_arn, registry_id, repository_name])'
    task :allow_access, [:user_arn, :registry_id, :repository_name] => :environment do |task, args|
      repository = Ecr::Repository.new(args.repository_name, args.registry_id)
      pp repository.allow_access(args.user_arn)
    end
  end
end
