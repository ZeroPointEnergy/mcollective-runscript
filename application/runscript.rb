class MCollective::Application::Runscript<MCollective::Application
  description 'Deploys scrips from a puppet fileserver and runs them'

  option :script_name,
    :description => 'Name of the script to deploy and run',
    :arguments   => ['-s', '--script_name SCRIPT'],
    :type        => :string,
    :required    => true

  option :show_stdout,
    :description => 'Show stdout of script run',
    :arguments   => '--show_stdout',
    :default     => false,
    :type        => :bool,
    :required    => false

  option :deploy,
    :description => 'Deploy the script from the puppet fileserver before execution',
    :arguments   => '--deploy',
    :default     => false,
    :type        => :bool,
    :required    => false

  option :source_path,
    :description => 'the puppet source path. Example \'puppet:///modules/scriptpool/\'',
    :arguments   => '--source_path PATH',
    :default     => 'puppet:///modules/scriptpool/',
    :type        => :string,
    :required    => false

  option :destination_path,
    :description => 'where to deploy the script',
    :arguments   => '--destination_path PATH',
    :default     => '/usr/local/bin/',
    :type        => :string,
    :required    => false

  options :keep_script,
    :description => 'don\'t remove scripts that where deployed with puppet after execution.',
    :arguments   => '--keep_script',
    :default     => false,
    :type        => :bool,
    :required    => false


  def print_result(node, result)
    puts
    puts "Hostname          : " + node
    puts "Return Value      : " + result[:status]
    puts
    unless result[:out].empty?
      puts "Error Channel   :"
      puts result[:out]
    end
    unless result[:err].empty?
      puts "Message Channel :"
      puts result[:err]
    end
  end


  def main
    puppet    = rpcclient('puppet')
    runscript = rpcclient('runscript')

    script = File.join configuration[:destination_path], configuration[:script_name]
    source = File.join configuration[:source_path], configuration[:script_name]

    # Deploy script from puppet fileserver
    if configoration[:deploy]

      printrpc puppet.resource(
        :type   => 'file',
        :name   => script,
        :ensure => 'present',
        :source => source,
        :mode   => '0700'
      )

    end

    # Run script on nodes
    runscript.run(:script => script).each do |node, result|
      if configuration[:show_stdout] or result[:status]
        print_result(node, result)
      end
    end

    # Remove script if we don't want to keep it and 
    # it was deployed with puppet
    if configuration[:deploy]
      unless configuration[:keep_script]

        printrpc puppet.resource(
          :type   => 'file',
          :name   => script,
          :ensure => 'absent'
        )

      end
    end
    
    printrpcstats

  end

end
