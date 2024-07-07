require 'json'
require_relative 'generate'
require_relative 'lib'

$target = %'--stack-name air'

# there is no single point of entry because I assume they can fail for whatever reason and could be idempotent
# order of calling is:
# - rake aws (stores secrets)
# - rake pi (secrets get copied into service)
# - rake clean (deletes secrets locally, when/if everything works)
# (after some data accumulated is S3)
# - rake pull (pulls data locally and renders)
# - rake render (makes png and pdf)

desc 'pi configuration given aws'
task :pi do
  sh 'ansible-playbook -i hosts_pi.ini pi.yml'
end

desc 'aws configuration'
task :aws do
  unless stack_exist?
    sh %'aws cloudformation create-stack #$target --template-body file://aws.yaml --capabilities CAPABILITY_NAMED_IAM'
    wait 'create'
  end
  Rake::Task["secrets"].invoke
end

task :secrets do
  sh %'aws cloudformation describe-stacks #$target --query "Stacks[0].Outputs" --output json > secret.json'
  array = JSON.parse File.read 'secret.json'
  raise 'something went wrong, probably need to delete stack' unless array
  hash = Hash[array.map { |h| [h['OutputKey'].underscore.upcase, h['OutputValue']] }]
  File.write 'secret.json', JSON.pretty_generate(hash)

  g = Generate.new JSON.parse File.read 'secret.json'
  File.write 'store.service', g.generate(File.read 'store.service')
end

desc 'remove temporary secrets locally'
task :clean do
  next unless File.exist? 'secret.json'
  g = Generate.new JSON.parse File.read 'secret.json'
  File.write 'store.service', g.degenerate(File.read 'store.service')
  File.unlink 'secret.json'
end

desc 'drop AWS resources, data may need to be manually deleted in S3'
task :drop do
  sh %'aws cloudformation delete-stack #$target'
  wait 'delete'
end

task :pull do
  str = `aws cloudformation describe-stacks #$target --query "Stacks[0].Outputs" --output json`
  xs = JSON.load str
  bucket_name = xs.find { |x| x['OutputKey'] == 'BucketName' }.fetch 'OutputValue'
  sh %'aws s3 sync s3://#{bucket_name} ./local_data'

  files = Dir['local_data/*.csv'].sort_by { |x| x.scan(/\d+/).map &:to_i }
  omg = []
  files.each { |f| omg.push File.read(f).lines.map(&:strip) }
  File.write 'local_data/all.csv', omg.flatten.join(?\n)
end

task :render do
  sh 'Rscript render.R'
end

# functions

def stack_exist?
  system %'aws cloudformation describe-stacks #$target'
end

def wait operation
  sh %'aws cloudformation wait stack-#{operation}-complete #$target'
end
