# frozen_string_literal: true

Puppet::Type.newtype(:java_ks) do
  @doc = 'Manages the entries in a java keystore, and uses composite namevars to
  accomplish the same alias spread across multiple target keystores.'

  ensurable do
    desc 'Has three states: present, absent, and latest.  Latest
      will compare the on disk SHA1 fingerprint of the certificate to that
      in keytool to determine if insync? returns true or false.  We redefine
      insync? for this parameter to accomplish this.'

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
            current = provider.current.split('/')
            latest = provider.latest.split('/')
            return true if latest.to_set.subset?(current.to_set)
          end
        end
      end

      false
    end

    defaultto :present
  end

  newparam(:name) do
    desc 'The alias that is used to identify the entry in the keystore. This will be
    converted to lowercase.'

    isnamevar

    munge do |value|
      value.downcase
    end
  end

  newparam(:target) do
    desc 'Destination file for the keystore.  This will autorequire the parent directory of the file.'

    isnamevar
  end

  newparam(:certificate) do
    desc 'A file containing a server certificate, followed by zero or more intermediate certificate authorities.
      All certificates will be placed in the keystore. This will autorequire the specified file.'
  end

  newparam(:certificate_content) do
    desc 'A string containing a server certificate, followed by zero or more intermediate certificate authorities.
      All certificates will be placed in the keystore.'
  end

  newparam(:storetype) do
    desc 'Optional storetype
      Valid options: <jceks>, <pkcs12>, <jks>'

    newvalues(:jceks, :pkcs12, :jks)
  end

  newparam(:private_key) do
    desc 'If you want an application to be a server and encrypt traffic,
      you will need a private key.  Private key entries in a keystore must be
      accompanied by a signed certificate for the keytool provider. This parameter
      allows you to specify the file name containing the private key. This will autorequire
      the specified file.'
  end

  newparam(:private_key_content) do
    desc 'If you want an application to be a server and encrypt traffic,
      you will need a private key.  Private key entries in a keystore must be
      accompanied by a signed certificate for the keytool provider. This parameter allows you to specify the content
      of the private key.'
  end

  newparam(:private_key_type) do
    desc 'The type of the private key. Usually the private key is of type RSA
      key but it can also be an Elliptic Curve key (EC) or DSA.
      Valid options: <rsa>, <dsa>, <ec>. Defaults to <rsa>'

    newvalues(:rsa, :dsa, :ec)

    defaultto :rsa
  end

  newparam(:chain) do
    desc 'The intermediate certificate authorities, if they are to be taken
      from a file separate from the server certificate. This will autorequire the specified file.'
  end

  newproperty(:password) do
    desc 'The password used to protect the keystore.  If private keys are
      subsequently also protected this password will be used to attempt
      unlocking. Must be six or more characters in length. Cannot be used
      together with :password_file, but you must pass at least one of these parameters.'

    munge do |value|
      value = value.unwrap if value.respond_to?(:unwrap)
      super(value)
    end

    validate do |value|
      value = value.unwrap if value.respond_to?(:unwrap)
      raise Puppet::Error, "password is #{value.length} characters long; must be 6 characters or greater in length" if value.length < 6
    end
  end

  newparam(:password_file) do
    desc 'The path to a file containing the password used to protect the
      keystore. This cannot be used together with :password, but you must pass at least one of these parameters.'
  end

  newparam(:password_fail_reset) do
    desc "If the supplied password does not succeed in unlocking the
      keystore file, then delete the keystore file and create a new one.
      Default: false."

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:destkeypass) do
    desc 'The password used to protect the key in keystore.'

    munge do |value|
      value = value.unwrap if value.respond_to?(:unwrap)
      super(value)
    end

    validate do |value|
      value = value.unwrap if value.respond_to?(:unwrap)
      raise Puppet::Error, "destkeypass is #{value.length} characters long; must be of length 6 or greater" if value.length < 6
    end
  end

  newparam(:trustcacerts) do
    desc "Certificate authorities aren't by default trusted so if you are adding a CA you need to set this to true.
     Defaults to :false."

    newvalues(:true, :false)

    defaultto :false
  end

  newparam(:path) do
    desc "The search path used for command (keytool, openssl) execution.
      Paths can be specified as an array or as a '#{File::PATH_SEPARATOR}' separated list."

    # Support both arrays and colon-separated fields.
    def value=(*values)
      @value = values.flatten.map { |val|
        val.split(File::PATH_SEPARATOR)
      }.flatten
    end
  end

  newparam(:keytool_timeout) do
    desc 'Timeout for the keytool command in seconds.'

    defaultto 120
  end

  newparam(:source_password) do
    munge do |value|
      value = value.unwrap if value.respond_to?(:unwrap)
      super(value)
    end

    desc 'The source keystore password'
  end

  newparam(:source_alias) do
    desc 'The source certificate alias'
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
    [
      [
        %r{^([^:]+)$},
        [
          [:name],
        ],
      ],
      [
        %r{^(.*):([a-z]:(/|\\).*)$}i,
        [
          [:name],
          [:target],
        ],
      ],
      [
        %r{^(.*):(.*)$},
        [
          [:name],
          [:target],
        ],
      ],
    ]
  end

  validate do
    if self[:ensure] != :absent
      unless value(:certificate) || value(:certificate_content)
        raise Puppet::Error, "You must pass one of 'certificate' or 'certificate_content'"
      end

      if value(:certificate) && value(:certificate_content)
        raise Puppet::Error, "You must pass either 'certificate' or 'certificate_content', not both."
      end

      if value(:private_key) && value(:private_key_content)
        raise Puppet::Error, "You must pass either 'private_key' or 'private_key_content', not both."
      end
    end

    if value(:password) && value(:password_file)
      raise Puppet::Error, "You must pass either 'password' or 'password_file', not both."
    end

    unless value(:password) || value(:password_file)
      raise Puppet::Error, "You must pass one of 'password' or 'password_file'."
    end

    if value(:storetype) == :pkcs12 && value(:source_password).nil?
      fail "You must provide 'source_password' when using a 'pkcs12' storetype." # rubocop:disable Style/SignalException : Associated test fails if 'raise' is used
    end
  end
end
