require 'puppet/util/filetype'
Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  # Keytool can only import a keystore if the format is pkcs12.  Generating and
  # importing a keystore is used to add private_key and certifcate pairs.
  def to_pkcs12
    output = ''
    cmd = [
      command(:openssl),
      'pkcs12', '-export', '-passout', 'stdin',
      '-in', @resource[:certificate],
      '-inkey', @resource[:private_key],
      '-name', @resource[:name]
    ]
    tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
    tmpfile.write(@resource[:password])
    output = Puppet::Util.execute(
      cmd,
      :stdinfile  => tmpfile.path,
      :failonfail => true,
      :combine    => true
      )
    tmpfile.remove
    return output
  end

  # Where we actually to the import of the file created using to_pkcs12.
  def import_ks
    tmppk12 = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
    tmppk12.write(to_pkcs12)
    cmd = [
      command(:keytool),
      '-importkeystore', '-srcstoretype', 'PKCS12',
      '-destkeystore', @resource[:target],
      '-srckeystore', tmppk12.path,
      '-alias', @resource[:name]
    ]
    cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
    tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
    if File.exists?(@resource[:target])
      tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
    else
      tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}\n#{@resource[:password]}")
    end
    Puppet::Util.execute(
      cmd,
      :stdinfile  => tmpfile.path,
      :failonfail => true,
      :combine    => true
    )
    tmppk12.remove
    tmpfile.remove
  end

  def exists?
    cmd = [
      command(:keytool),
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    begin
      tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
      tmpfile.write(@resource[:password])
      Puppet::Util.execute(
        cmd,
        :stdinfile  => tmpfile.path,
        :failonfail => true,
        :combine    => true
      )
      tmpfile.remove
      return true
    rescue
      return false
    end
  end

  # Reading the fingerprint of the certificate on disk.
  def latest
    cmd = [
      command(:openssl),
      'x509', '-fingerprint', '-md5', '-noout',
      '-in', @resource[:certificate]
    ]
    output = Puppet::Util.execute(cmd)
    latest = output.scan(/MD5 Fingerprint=(.*)/)[0][0]
    return latest
  end

  # Reading the fingerprint of the certificate currently in the keystore.
  def current
    output = ''
    cmd = [
      command(:keytool),
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
    tmpfile.write(@resource[:password])
    output = Puppet::Util.execute(
      cmd,
      :stdinfile  => tmpfile.path,
      :failonfail => true,
      :combine    => true
    )
    tmpfile.remove
    current = output.scan(/Certificate fingerprint \(MD5\): (.*)/)[0][0]
    return current
  end

  # Determine if we need to do an import of a private_key and certificate pair
  # or just add a signed certificate, then do it.
  def create
    if ! @resource[:certificate].nil? and ! @resource[:private_key].nil?
      import_ks
    elsif @resource[:certificate].nil? and ! @resource[:private_key].nil?
      raise Puppet::Error 'Keytool is not capable of importing a private key without an accomapaning certificate.'
    else
      cmd = [
        command(:keytool),
        '-importcert', '-noprompt',
        '-alias', @resource[:name],
        '-file', @resource[:certificate],
        '-keystore', @resource[:target]
      ]
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
      if File.exists?(@resource[:target])
        tmpfile.write(@resource[:password])
      else
        tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
      end
      Puppet::Util.execute(
        cmd,
        :stdinfile  => tmpfile.path,
        :failonfail => true,
        :combine    => true
      )
      tmpfile.remove
    end
  end

  def destroy
    cmd = [
      command(:keytool),
      '-delete',
      '-alias', @resource[:name],
      '-keystore', @resource[:target]
    ]
    tmpfile = Puppet::Util::FileType.filetype(:flat).new("/tmp/#{@resource[:name]}.#{rand(2 << 64)}")
    tmpfile.write(@resource[:password])
    Puppet::Util.execute(
      cmd,
      :stdinfile  => tmpfile.path,
      :failonfail => true,
      :combine    => true
    )
    tmpfile.remove
  end

  # Being safe since I have seen some additions overwrite and some just throw errors.
  def update
    destroy
    create
  end
end
