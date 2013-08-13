require 'csv'

class MCollective::Application::Runscript<MCollective::Application
  description 'Deploys scrips from a puppet fileserver and runs them'

  option :script_name,
    :description => 'Name of the script to deploy and run',
    :arguments   => ['-s', '--script_name SCRIPT'],
    :required    => true

  option :user,  
    :description => 'Run script as another user',
    :arguments   => ['-u', '--user USER' ],
    :default     => 'root',
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
    :required    => false

  option :destination_path,
    :description => 'where to deploy and/or run the script. Defaults to /usr/local/bin/',
    :arguments   => '--destination_path PATH',
    :default     => '/usr/local/bin/',
    :required    => false

  option :keep_script,
    :description => 'don\'t remove scripts that where deployed with puppet after execution.',
    :arguments   => '--keep_script',
    :default     => false,
    :type        => :bool,
    :required    => false

  option :output_csv,
    :description => 'Write Output to CSV file',
    :arguments   => ['-o', '--output_csv FILE'],
    :default     => false,
    :required    => false

   
  def main
    
    # check if the output csv already exists
    csvfile = nil
    sep = ', '
    if configuration[:output_csv]
      if File.exists? configuration[:output_csv]
        raise "ERROR: output file already exists!"
      end
      csvfile = CSV.open(configuration[:output_csv], 'w')
    end

    # get the agents
    puppet    = rpcclient('puppet')
    runscript = rpcclient('runscript')

    # assemble some variables
    script = File.join configuration[:destination_path], configuration[:script_name]
    source = File.join configuration[:source_path], configuration[:script_name]
    user   = configuration[:user]

    # Deploy script from puppet fileserver
    if configuration[:deploy]

      printrpc puppet.resource(
        :type   => 'file',
        :name   => script,
        :ensure => 'present',
        :source => source,
        :mode   => '0700'
      )

    end

    # Run script on nodes
    unless configuration[:output_csv]
      printrpc runscript.run(:script => script, :user => user)
    else
      runscript.run(:script => script, :user => user).each do |resp|
        csv_line = []
        csv_line << resp[:sender]
        csv_line << resp[:data][:status]
        csv_line << resp[:data][:out]
        csv_line << resp[:data][:err]
        csvfile << csv_line
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
