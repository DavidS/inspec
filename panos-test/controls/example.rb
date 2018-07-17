# encoding: utf-8

title 'sample section'

# you add controls here
control 'ccs-1.0' do
  impact 0.7
  title 'client certificate security has to be on'

  describe panos_admin('admin') do
    it { should be_client_certificate_only }
  end
end
