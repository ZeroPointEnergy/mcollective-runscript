metadata :name        => "runscript",
         :description => "Run a script on a remote server",
         :author      => "Andreas Zuber <zuber@puzzle.ch>",
         :license     => "GPLv2",
         :version     => "0.1",
         :url         => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
         :timeout     => 60

action "run", :description => "Runs a script" do
  input :script,
        :prompt      => "Script name",
        :description => "Name and full path of the script we want to run",
        :type        => :string,
        :validation  => '^.*$',
        :optional    => false,
        :maxlength   => 255
 
  output :status,
         :description => "The exit code of the script",
         :display_as  => "Return Value"

  output :out,
         :description => "The Output of the script on stdout",
         :display_as  => "Output Channel"

   output :err,
         :description => "The Output of the script on stderr",
         :display_as  => "Error Channel"

end
