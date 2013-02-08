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
    cmd << [ '-certfile', @resource[:chain] ] if @resource[:chain]
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush
    output = run_keystore_command(cmd, false, tmpfile)
    tmpfile.close!
    return output
  end

  # Where we actually to the import of the file created using to_pkcs12.
  def import_ks
    tmppk12 = Tempfile.new("#{@resource[:name]}.")
    tmppk12.write(to_pkcs12)
    tmppk12.flush
    cmd = [
      command(:keytool),
      '-importkeystore', '-srcstoretype', 'PKCS12',
      '-destkeystore', @resource[:target],
      '-srckeystore', tmppk12.path,
      '-alias', @resource[:name]
    ]
    cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    if File.exists?(@resource[:target]) and not File.zero?(@resource[:target])
      tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
    else
      tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}\n#{@resource[:password]}")
    end
    tmpfile.flush
    run_keystore_command(cmd, @resource[:target], tmpfile)
    tmppk12.close!
    tmpfile.close!
  end

  def exists?
    cmd = [
      command(:keytool),
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    begin
      tmpfile = Tempfile.new("#{@resource[:name]}.")
      tmpfile.write(@resource[:password])
      tmpfile.flush
      run_keystore_command(cmd, false, tmpfile)
      tmpfile.close!
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
    output = run_keystore_command(cmd)
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
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush
    output = run_keystore_command(cmd, false, tmpfile)
    tmpfile.close!
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
      tmpfile = Tempfile.new("#{@resource[:name]}.")
      if File.exists?(@resource[:target]) and not File.zero?(@resource[:target])
        tmpfile.write(@resource[:password])
      else
        tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
      end
      tmpfile.flush
      run_keystore_command(cmd, @resource[:target], tmpfile)
      tmpfile.close!
    end
  end

  def destroy
    cmd = [
      command(:keytool),
      '-delete',
      '-alias', @resource[:name],
      '-keystore', @resource[:target]
    ]
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush
    run_keystore_command(cmd, false, tmpfile)
    tmpfile.close!
  end

  # Being safe since I have seen some additions overwrite and some just throw errors.
  def update
    destroy
    create
  end

  def run_keystore_command(cmd, target=false, stdinfile=false)

    # The Puppet::Util::Execution.execute method is deparcated in Puppet 3.x
    # but we need this to work on 2.7.x too.
    if Puppet::Util::Execution.respond_to?(:execute)
      exec_method = Puppet::Util::Execution.execute
    else
      exec_method = Puppet::Util.execute
    end

    # the java keytool will not correctly deal with an empty target keystore
    # file. If we encounter an empty keystore target file, preserve the mode,
    # owner and group, and delete the empty file.
    if target and (File.exists?(target) and File.zero?(target))
      stat = File.stat(target)
      File.delete(target)
    end

    # There's a problem in IBM java wherein stdin cannot be used (trivially)
    # pass in the keystore passwords. This makes the provider work on SLES
    # with minimal effort.
    if Facter.value('osfamily') == 'Suse' and @resource[:password]
     cmd << '-srcstorepass'  << @resource[:password]
     cmd << '-deststorepass' << @resource[:password]
    end

    # Now run the command
    output = if stdinfile
      exec_method(cmd, :stdinfile => stdinfile.path, :failonfail => true, :combine => true)
    else
      exec_method(cmd, :failonfail => true, :combine => true)
    end

    # for previously empty files, restore the mode, owner and group. The funky
    # double-take check is because on Suse defined? doesn't seem to behave
    # quite the same as on Debian, RedHat
    if target and (defined? stat and stat)
      File.chmod(stat.mode, target)
      File.chown(stat.uid, stat.gid, target)
    end

    return output
  end

end
