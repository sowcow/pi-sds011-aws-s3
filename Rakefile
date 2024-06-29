require 'json'
require_relative 'generate'
require_relative 'lib'

$target = %'--stack-name air'

# there is no single point of entry because I assume they can fail for whatever reason and could be idempotent
# order of calling is:
# - rake aws (stores secrets)
# - rake pi (secrets get copied into service)
# - rake clean (deletes secrets locally, when/if everything works)

desc 'pi configuration given aws'
task :pi do
  sh 'ansible-playbook -i hosts_pi.ini pi.yml'
end

desc 'aws configuration'
task :aws do
  unless stack_exist?
    sh %'aws cloudformation create-stack #$target --template-body file://aws.yaml --capabilities CAPABILITY_NAMED_IAM'
    wait 'create'
    sh %'aws cloudformation describe-stacks #$target --query "Stacks[0].Outputs" --output json > secret.json'

    array = JSON.parse File.read 'secret.json'
    raise 'something went wrong, probably need to delete stack' unless array
    hash = Hash[array.map { |h| [h['OutputKey'].underscore.upcase, h['OutputValue']] }]
    File.write 'secret.json', JSON.pretty_generate(hash)
  end

  g = Generate.new JSON.parse File.read 'secret.json'
  File.write 'store.service', g.generate(File.read 'store.service')
end

desc 'remove temporary secrets locally'
task :clean do
  return unless File.exist? 'secret.json'
  g = Generate.new JSON.parse File.read 'secret.json'
  File.write 'store.service', g.degenerate(File.read 'store.service')
  File.unlink 'secret.json'
end

desc 'drop AWS resources, data may need to be manually deleted in S3'
task :drop do
  sh %'aws cloudformation delete-stack #$target'
  wait 'delete'
end

# functions

def stack_exist?
  system %'aws cloudformation describe-stacks #$target'
end

def wait operation
  sh %'aws cloudformation wait stack-#{operation}-complete #$target'
end
