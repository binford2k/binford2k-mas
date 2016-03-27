require 'spec_helper'
describe 'mas' do

  context 'with defaults for all parameters' do
    it { should contain_class('mas') }
  end
end
