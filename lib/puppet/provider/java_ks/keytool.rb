Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  def to_pkcs12
    cmd = [command(:openssl)]
    cmd << 'pkcs12' << '-export'
    cmd << '-in' << @resource[:certificate]
    cmd << '-inkey' << @resource[:private_key]
    cmd << '-name' << @resource[:name]
    cmd << '-passout' << "pass:#{@resource[:password]}"
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    return raw
  end

  def import_ks
    Tempfile.open("#{@resource[:name]}.pk12.") do |tmpfile|
      tmpfile.write(to_pkcs12)
      tmpfile.flush
      cmd = [command(:keytool)]
      cmd << '-importkeystore'
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      cmd << '-destkeystore' << @resource[:target]
      cmd << '-destkeypass' << @resource[:password]
      cmd << '-deststorepass' << @resource[:password]
      cmd << '-srckeystore' << tmpfile.path.to_s
      cmd << '-srcstorepass' << @resource[:password]
      cmd << '-srcstoretype' << 'PKCS12'
      cmd << '-alias' << @resource[:name]
      Puppet::Util.execute(cmd)
    end
  end

  def exists?
    cmd = [command(:keytool)]
    cmd << '-list'
    cmd << '-keystore' << @resource[:target]
    cmd << '-alias' << @resource[:name]
    cmd << '-storepass' << @resource[:password]
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    if status == 0
      return true
    else
      return false
    end
  end

  def latest
    cmd = [command(:openssl)]
    cmd << 'x509' << '-fingerprint' << '-md5' << '-noout'
    cmd << '-in' << @resource[:certificate]
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    latest = raw.scan(/MD5 Fingerprint=(.*)/)[0][0]
    return latest
  end

  def current
    cmd = [command(:keytool)]
    cmd << '-list'
    cmd << '-keystore' << @resource[:target]
    cmd << '-alias' << @resource[:name]
    cmd << '-storepass' << @resource[:password]
    raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    current = raw.scan(/Certificate fingerprint \(MD5\): (.*)/)[0][0]
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
      cmd << '-storepass' << @resource[:password]
      Puppet::Util.execute(cmd)
    end
  end

  def destroy
    cmd = [command(:keytool)]
    cmd << '-delete'
    cmd << '-alias' << @resource[:name]
    cmd << '-keystore' << @resource[:target]
    cmd << '-storepass' << @resource[:password]
    Puppet::Util.execute(cmd)
  end

  def update
    destroy
    create
  end
end
