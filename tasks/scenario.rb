# Scenario dedicated Rake task
#
#

# Override OAR resources (tasks/jobs.rb)
# We uses 2 nodes (1 puppetserver and 1 controller) and a subnet for floating public IPs
#
XP5K::Config[:jobname]    ||= '[mesos]'
XP5K::Config[:site]       ||= 'rennes'
XP5K::Config[:walltime]   ||= '1:00:00'
XP5K::Config[:cluster]    ||= ''
XP5K::Config[:masters]    ||= 1
XP5K::Config[:slaves]     ||= 1

oar_cluster = ""
oar_cluster = "and cluster='" + XP5K::Config[:cluster] + "'" if !XP5K::Config[:cluster].empty?

nodes = XP5K::Config[:masters].to_i + XP5K::Config[:slaves].to_i + 1

resources = [] << 
[ 
  "#{oar_cluster}nodes=#{nodes}",
  "walltime=#{XP5K::Config[:walltime]}"
].join(",")

@job_def[:resources] = resources
@job_def[:roles] << XP5K::Role.new({
  name: 'masters',
  size: XP5K::Config[:masters].to_i
})

@job_def[:roles] << XP5K::Role.new({
  name: 'slaves',
  size: XP5K::Config[:slaves].to_i
})

#
role 'all' do
  roles 'puppetserver', 'masters', 'slaves'
end

# Define OAR job (required)
#
xp.define_job(@job_def)


# Define Kadeploy deployment (required)
#
xp.define_deployment(@deployment_def)


namespace :scenario do

  desc 'Main task called at the end of `run` task'
  task :main do
    Rake::Task['scenario:hiera:update'].execute
    Rake::Task['puppet:modules:upload'].execute

    puppetserver = roles('puppetserver').first
    on roles('masters') do
        cmd = "/opt/puppetlabs/bin/puppet agent -t --server #{puppetserver}"
        cmd += " --debug" if ENV['debug']
        cmd += " --trace" if ENV['trace']
        cmd
    end
    on roles('slaves') do
        cmd = "/opt/puppetlabs/bin/puppet agent -t --server #{puppetserver}"
        cmd += " --debug" if ENV['debug']
        cmd += " --trace" if ENV['trace']
        cmd
    end

  end

  namespace :hiera do
    desc 'Update the common hiera data'
    task :update do
      file = "scenarios/#{XP5K::Config[:scenario]}/hiera/generated/common.yaml"
      common = YAML.load_file(file)
      masters = roles('masters')
      slaves = roles('slaves')
      common['mesos::masters'] = masters
      common['mesos::slaves'] = slaves
      common['hadoop::dfs::namenode'] = masters.first
      common['hadoop::dfs::datanodes'] = slaves
      # hard coded for now
      common['hadoop::dfs::replication'] = 1
      common['hadoop::url'] =  "http://www.eu.apache.org/dist/hadoop/common/hadoop-1.2.1/hadoop-1.2.1.tar.gz"

      File.open(file, 'w') do |file|
        file.puts common.to_yaml
      end
      id = 1
      masters.each do |master|
        file = "scenarios/#{XP5K::Config[:scenario]}/hiera/generated/nodes/#{master}.yaml"
        node = YAML.load_file(file)
        node["mesos::zookeeper::myid"] = id.to_s
        id = id + 1
        File.open(file, 'w') do |file|
          file.puts node.to_yaml
        end
      end

    end

  end
end


