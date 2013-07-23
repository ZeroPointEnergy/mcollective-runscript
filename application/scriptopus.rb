class MCollective::Application::Scriptopus<MCollective::Application
  description 'Deploys scrips from a puppet fileserver and runs them'

  option :script_name,
    :description => 'Name of the script to deploy and run',
    :arguments => ['-s', '--script_name SCRIPT'],
    :required => true

  option :source_path,
    :description => 'the puppet source path. Example \'puppet:///modules/scriptopus/\'',
    :arguments => ['-p', '--source_path PATH'],
    :required => false

  option :destination_path,
    :description => 'where to deploy the script',
    :arguments => ['-d', '--destination_path PATH'],
    :required => false

  def main
    puppet    = rpcclient('puppet')
    runscript = rpcclient('runscript')

    script_name      = configuration[:script_name]
    source_path      = configuration[:source_path] || 'puppet:///modules/scriptopus_scripts/'
    destination_path = configuration[:destination_path] || '/usr/local/sbin/'

    printrpc puppet.resource(
      :type   => 'file',
      :name   => destination_path + script_name,
      :ensure => 'present',
      :source => source_path + script_name,
      :mode   => '0700'
    )

    printrpc runscript.run(:script => destination_path + script_name)

    printrpc puppet.resource(
      :type   => 'file',
      :name   => destination_path + script_name,
      :ensure => 'absent'
    )
    
    printrpcstats

  end

end
