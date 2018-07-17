# encoding: utf-8

require 'puppet/resource_api/io_context'
module Puppet::Provider; end
module Puppet::Provider::PanosAdmin; end

module Inspec::Resources
  class InspecContext < Puppet::ResourceApi::IOContext
    def initialize(connection)
      super({
        name: 'panos_admin',
        docs: <<-EOS,
            This type provides Puppet with the capabilities to manage "administrator" user accounts on Palo Alto devices.
          EOS
        base_xpath: '/config/mgt-config/users',
        features: ['remote_resource'],
        attributes:   {
          ensure:      {
            type:    'Enum[present, absent]',
            desc:    'Whether this resource should be present or absent on the target system.',
            default: 'present',
          },
          name:        {
            type:      'String',
            desc:      'The username.',
            behaviour: :namevar,
          },
          password_hash:    {
            type:      'Optional[String]',
            desc:      'Provide a password hash.',
            xpath:     'phash/text()',
          },
          client_certificate_only: {
            type:     'Optional[Boolean]',
            desc:     'When set to true, certificate profile for web access.',
            xpath:    'client-certificate-only/text()',
          },
          ssh_key:    {
            type:      'Optional[String]',
            desc:      'Provide the users public key in plain text',
            xpath:     'public-key/text()',
          },
          role:       {
            type:     'Enum["superuser", "superreader", "devicereader", "custom"]',
            desc:     'Specify the access level for the administrator',
            xpath:    'local-name(permissions/role-based/*[1])',
          },
          role_profile:    {
            type:     'Optional[String]',
            desc:     'Specify the role profile for the user',
            xpath:    'permissions/role-based/custom/profile/text()',
          },
        },
        autobefore: {
          panos_commit: 'commit',
        }
      },
      $stderr)
      @connection = connection
    end

    def device
      @connection
    end
  end

  class PanosAdmin < Inspec.resource(1)
    name 'panos_admin'
    supports platform: 'panos'
    desc 'a palo alto admin.'
    example "
      describe panos_admin('admin') do
        it { should be_ccs_only }
      end
    "

    def initialize(user, options = {})
      @user = user
    end

    def client_certificate_only?
      $LOAD_PATH.unshift('/home/david/git/puppetlabs-panos/lib')
      require 'puppet/provider/panos_admin/panos_admin'

      provider = Puppet::Provider::PanosAdmin::PanosAdmin.new
      result = provider.get(InspecContext.new(inspec.backend.connection)).find {|p| p[:name] == @user }

      # require 'pry';binding.pry
      # no user, no violation
      return true unless result

      return result[:client_certificate_only] == true
    end

    def to_s
      "PANOS Admin #{@user}"
    end
  end
end
