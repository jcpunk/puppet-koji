require 'spec_helper'
describe 'koji' do

  context 'with defaults for all parameters' do
    it { should contain_class('koji') }
  end
end
