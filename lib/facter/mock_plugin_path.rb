Facter.add("mock_plugin_path") do
  setcode do
    Facter::Util::Resolution.exec('rpm -ql mock |grep -v etc | grep "plugins$" 2>/dev/null')
  end
end

