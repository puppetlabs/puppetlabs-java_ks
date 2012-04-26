Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  def to_pkcs12
    output = ''
    cmd = [
      command(:openssl),
      'pkcs12', '-export', '-passout', 'stdin',
      '-in', @resource[:certificate],
      '-inkey', @resource[:private_key],
      '-name', @resource[:name]
    ]
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      output = Puppet::Util.execute(
        cmd,
        :stdinfile  => tmpfile.path.to_s,
        :failonfail => true,
        :combine    => truer
      )
    end
    return output
  end

  def import_ks
    Tempfile.open("#{@resource[:name]}.pk12.") do |tmppk12|
      tmppk12.write(to_pkcs12)
      tmppk12.flush
      cmd = [
        command(:keytool),
        '-importkeystore', '-srcstoretype', 'PKCS12',
        '-destkeystore', @resource[:target],
        '-srckeystore', tmppk12.path.to_s,
        '-alias', @resource[:name]
      ]
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        if File.exists?(@resource[:target])
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
        else
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}\n#{@resource[:password]}")
        end
        tmpfile.flush
        Puppet::Util.execute(
          cmd,
          :stdinfile  => tmpfile.path.to_s,
          :failonfail => true,
          :combine    => true
        )
      end
    end
  end

  def exists?
    cmd = [
      command(:keytool),
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    begin
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        tmpfile.write(@resource[:password])
        tmpfile.flush
        Puppet::Util.execute(
          cmd,
          :stdinfile  => tmpfile.path.to_s,
          :failonfail => true,
          :combine    => true
        )
      end
      return true
    rescue
      return false
    end
  end

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

  def current
    output = ''
    cmd = [
      command(:keytool),
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      output = Puppet::Util.execute(
        cmd,
        :stdinfile  => tmpfile.path.to_s,
        :failonfail => true,
        :combine    => true
      )
    end
    current = output.scan(/Certificate fingerprint \(MD5\): (.*)/)[0][0]
    return current
  end

  def create
    if ! @resource[:certificate].nil? and ! @resource[:private_key].nil?
      import_ks
    elsif @resource[:certificate].nil? and ! @resource[:private_key].nil?
      raise Puppet::Error 'Keytool is not capable of importing a private key
without an accomapaning certificate.'
    else
      cmd = [
        command(:keytool),
        '-importcert', '-noprompt',
        '-alias', @resource[:name],
        '-file', @resource[:certificate],
        '-keystore', @resource[:target]
      ]
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        if File.exists?(@resource[:target])
          tmpfile.write(@resource[:password])
        else
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
        end
        tmpfile.flush
        Puppet::Util.execute(
          cmd,
          :stdinfile  => tmpfile.path.to_s,
          :failonfail => true,
          :combine    => true
        )
      end
    end
  end

  def destroy
    cmd = [
      command(:keytool),
      '-delete',
      '-alias', @resource[:name],
      '-keystore', @resource[:target]
    ]
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      Puppet::Util.execute(
        cmd,
        :stdinfile  => tmpfile.path.to_s,
        :failonfail => true,
        :combine    => true
      )
    end
  end

  def update
    destroy
    create
  end
end
