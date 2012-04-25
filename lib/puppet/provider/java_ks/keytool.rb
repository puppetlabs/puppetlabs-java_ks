Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  def to_pkcs12
    output = ''
    cmd = [command(:openssl)]
    cmd << 'pkcs12' << '-export'
    cmd << '-in' << @resource[:certificate]
    cmd << '-inkey' << @resource[:private_key]
    cmd << '-name' << @resource[:name]
    cmd << '-passout' << 'stdin'
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      output = Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
    end
    return output
  end

  def import_ks
    Tempfile.open("#{@resource[:name]}.pk12.") do |tmppk12|
      tmppk12.write(to_pkcs12)
      tmppk12.flush
      cmd = [command(:keytool)]
      cmd << '-importkeystore'
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      cmd << '-destkeystore' << @resource[:target]
      cmd << '-srckeystore' << tmppk12.path.to_s
      cmd << '-srcstoretype' << 'PKCS12'
      cmd << '-alias' << @resource[:name]
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        if File.exists?(@resource[:target])
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
        else
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}\n#{@resource[:password]}")
        end
        tmpfile.flush
        Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
      end
    end
  end

  def exists?
    cmd = [command(:keytool)]
    cmd << '-list'
    cmd << '-keystore' << @resource[:target]
    cmd << '-alias' << @resource[:name]
    begin
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        tmpfile.write(@resource[:password])
        tmpfile.flush
        Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
      end
      return true
    rescue
      return false
    end
  end

  def latest
    cmd = [command(:openssl)]
    cmd << 'x509' << '-fingerprint' << '-md5' << '-noout'
    cmd << '-in' << @resource[:certificate]
    output = Puppet::Util.execute(cmd)
    latest = output.scan(/MD5 Fingerprint=(.*)/)[0][0]
    return latest
  end

  def current
    output = ''
    cmd = [command(:keytool)]
    cmd << '-list'
    cmd << '-keystore' << @resource[:target]
    cmd << '-alias' << @resource[:name]
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      output = Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
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
      cmd = [command(:keytool)]
      cmd << '-importcert' << '-noprompt'
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      cmd << '-alias' << @resource[:name]
      cmd << '-file' << @resource[:certificate]
      cmd << '-keystore' << @resource[:target]
      Tempfile.open("#{@resource[:name]}.") do |tmpfile|
        if File.exists?(@resource[:taget])
          tmpfile.write(@resource[:password])
        else
          tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
        end
        tmpfile.flush
        Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
      end
    end
  end

  def destroy
    cmd = [command(:keytool)]
    cmd << '-delete'
    cmd << '-alias' << @resource[:name]
    cmd << '-keystore' << @resource[:target]
    Tempfile.open("#{@resource[:name]}.") do |tmpfile|
      tmpfile.write(@resource[:password])
      tmpfile.flush
      Puppet::Util.execute(cmd, :stdinfile => tmpfile.path.to_s, :failonfail => true, :combine => true)
    end
  end

  def update
    destroy
    create
  end
end
