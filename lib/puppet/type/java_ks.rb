module Puppet
  newtype(:java_ks) do
    @doc = 'Manages entries in a java keystore.  Uses composite namevars to
        accomplish the same alias spread across multiple target keystores.'

    ensurable do

      desc 'Has three states, the obvious present and absent plus latest.  Latest
        will compare the on disk MD5 fingerprint of the certificate and to that
        in keytool to determine if insync? returns true or false.  We redefine
        insync? for this paramerter to accomplish this.'

      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end

      newvalue(:latest) do
        if provider.exists?
          provider.update
        else
          provider.create
        end
      end

      def insync?(is)

        @should.each do |should|
          case should
          when :present
            return true if is == :present
          when :absent
            return true if is == :absent
          when :latest
            unless is == :absent
              return true if provider.latest == provider.current
            end
          end
        end

        return false
      end

      defaultto :present
    end

    newparam(:name) do
      desc 'The alias that is used to identify the entry in the keystore.  We
        are down casing it for you here because keytool will do so for you too.'

      isnamevar

      munge do |value|
        value.downcase
      end
    end

    newparam(:target) do
      desc 'Destination file for the keystore.  We autorequire the parent
        directory for convenience.'

      isnamevar
    end

    newparam(:certificate) do
      desc 'An already signed certificate that we can place in the keystore.  We
        autorequire the file for convenience.'

      isrequired
    end

    newparam(:private_key) do
      desc 'If you desire for an application to be a server and encrypt traffic
        you will need a private key.  Private key entries in a keystore must be
        accompanied by a signed certificate for the keytool provider.'
    end

    newparam(:chain) do
      desc 'It has been found that some java applications do not properly send
        intermediary certificate authorities, in this case you can bundle them
        with the server certificate using this chain parameter.'
    end

    newparam(:password) do
      desc 'The password used to protect the keystore.  If private keys are
        subsequently also protected this password will be used to attempt
        unlocking...P.S. Let me know if you ever need a separate private key
        password parameter...'

      validate do |value|
        raise Puppet::Error, "password is #{value.length} characters long; must be of length 6 or greater" if value.length < 6
      end
    end

    newparam(:password_file) do
      desc 'The path to a file containing the password used to protect the
        keystore. This cannot be used together with :password.'
    end

    newparam(:trustcacerts) do
      desc "When inputing certificate authorities into a keystore, they aren't
        by default trusted so if you are adding a CA you need to set this to true."

      newvalues(:true, :false)

      defaultto :false
    end

    newparam(:path) do
      desc "The search path used for command (keytool, openssl) execution.
        Paths can be specified as an array or as a '#{File::PATH_SEPARATOR}' separated list."

      # Support both arrays and colon-separated fields.
      def value=(*values)
        @value = values.flatten.collect { |val|
          val.split(File::PATH_SEPARATOR)
        }.flatten
      end
    end

    # Where we setup autorequires.
    autorequire(:file) do
      auto_requires = []
      [:private_key, :certificate, :chain].each do |param|
        if @parameters.include?(param)
          auto_requires << @parameters[param].value
        end
      end
      if @parameters.include?(:target)
        auto_requires << ::File.dirname(@parameters[:target].value)
      end
      auto_requires
    end

    # Our title_patterns method for mapping titles to namevars for supporting
    # composite namevars.
    def self.title_patterns
      identity = lambda {|x| x}
      [
        [
          /^([^:]+)$/,
          [
            [ :name, identity ]
          ]
        ],
        [
          /^(.*):(.*)$/,
          [
            [ :name, identity ],
            [ :target, identity ]
          ]
        ]
      ]
    end

    validate do
      if value(:password) and value(:password_file)
        self.fail "You must pass either 'password' or 'password_file', not both."
      end

      unless value(:password) or value(:password_file)
        self.fail "You must pass one of 'password' or 'password_file'."
      end
    end
  end
end
