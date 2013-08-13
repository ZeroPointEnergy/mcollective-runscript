module MCollective
  module Agent
    class Runscript<RPC::Agent
    
      action 'run' do
        validate :script, :shellsafe

        command = request[:script]

        unless request[:user] == 'root' 
          command = "sudo -u #{request[:user]} -s \'#{request[:script]}\'"
        end

        reply[:status] = run(command, :stdout => :out, :stderr => :err)
        reply[:out].chomp!
        reply[:err].chomp!
      end

    end
  end
end
