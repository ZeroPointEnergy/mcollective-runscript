module MCollective
  module Agent
    class Runscript<RPC::Agent
    
      action 'run' do
        validate :script, :shellsafe

        reply[:status] = run(request[:script], :stdout => :out, :stderr => :err)
        reply[:out].chomp!
        reply[:err].chomp!
      end

    end
  end
end
