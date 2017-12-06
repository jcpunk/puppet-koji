Facter.add("koji_plugin_path") do
  setcode do
    Facter::Util::Resolution.exec('rpm -ql koji-hub-plugins |grep -v etc | grep "plugins$" 2>/dev/null')
  end
end

