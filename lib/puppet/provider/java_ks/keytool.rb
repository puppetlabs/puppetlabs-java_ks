require 'puppet/util/filetype'

Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  def command_openssl
    'openssl'
  end

  def command_keytool
    'keytool'
  end

  # Keytool can only import a keystore if the format is pkcs12.  Generating and
  # importing a keystore is used to add private_key and certifcate pairs.
  def to_pkcs12(path)
    cmd = [
      command_openssl,
      'pkcs12', '-export', '-passout', 'stdin',
      '-in', certificate,
      '-inkey', private_key,
      '-name', @resource[:name],
      '-out', path
    ]
    cmd << [ '-certfile', chain ] if chain
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush

    # To maintain backwards compatibility with Puppet 2.7.x, resort to ugly
    # code to make sure RANDFILE is passed as an environment variable to the
    # openssl command but not retained in the Puppet process environment.
    randfile = Tempfile.new("#{@resource[:name]}.")
    run_command(cmd, false, tmpfile, 'RANDFILE' => randfile.path)
    tmpfile.close!
    randfile.close!
  end

  def password_file
    if @resource[:password_file].nil?
      tmpfile = Tempfile.new("#{@resource[:name]}.")
      if File.exists?(@resource[:target]) and not File.zero?(@resource[:target])
        tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}")
      else
        tmpfile.write("#{@resource[:password]}\n#{@resource[:password]}\n#{@resource[:password]}")
      end
      tmpfile.flush
      tmpfile
    else
      @resource[:password_file]
    end
  end

  # Where we actually to the import of the file created using to_pkcs12.
  def import_ks
    tmppk12 = Tempfile.new("#{@resource[:name]}.")
    to_pkcs12(tmppk12.path)
    cmd = [
      command_keytool,
      '-importkeystore', '-srcstoretype', 'PKCS12',
      '-destkeystore', @resource[:target],
      '-srckeystore', tmppk12.path,
      '-alias', @resource[:name]
    ]
    cmd << '-trustcacerts' if @resource[:trustcacerts] == :true

    pwfile = password_file
    run_command(cmd, @resource[:target], pwfile)
    tmppk12.close!
    pwfile.close! if pwfile.is_a? Tempfile
  end

  def exists?
    cmd = [
      command_keytool,
      '-list',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    begin
      tmpfile = Tempfile.new("#{@resource[:name]}.")
      tmpfile.write(@resource[:password])
      tmpfile.flush
      run_command(cmd, false, tmpfile)
      tmpfile.close!
      return true
    rescue
      return false
    end
  end

  # Reading the fingerprint of the certificate on disk.
  def latest
    cmd = [
      command_openssl,
      'x509', '-fingerprint', '-md5', '-noout',
      '-in', certificate
    ]
    output = run_command(cmd)
    latest = output.scan(/MD5 Fingerprint=(.*)/)[0][0]
    return latest
  end

  # Reading the fingerprint of the certificate currently in the keystore.
  def current
    output = ''
    cmd = [
      command_keytool,
      '-list', '-v',
      '-keystore', @resource[:target],
      '-alias', @resource[:name]
    ]
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush
    output = run_command(cmd, false, tmpfile)
    tmpfile.close!
    current = output.scan(/Certificate fingerprints:\n\s+MD5:  (.*)/)[0][0]
    return current
  end

  # Determine if we need to do an import of a private_key and certificate pair
  # or just add a signed certificate, then do it.
  def create
    if ! certificate.nil? and ! private_key.nil?
      import_ks
    elsif certificate.nil? and ! private_key.nil?
      raise Puppet::Error, 'Keytool is not capable of importing a private key without an accomapaning certificate.'
    else
      cmd = [
        command_keytool,
        '-importcert', '-noprompt',
        '-alias', @resource[:name],
        '-file', certificate,
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
      run_command(cmd, @resource[:target], tmpfile)
      tmpfile.close!
    end
  end

  def destroy
    cmd = [
      command_keytool,
      '-delete',
      '-alias', @resource[:name],
      '-keystore', @resource[:target]
    ]
    tmpfile = Tempfile.new("#{@resource[:name]}.")
    tmpfile.write(@resource[:password])
    tmpfile.flush
    run_command(cmd, false, tmpfile)
    tmpfile.close!
  end

  # Being safe since I have seen some additions overwrite and some just throw errors.
  def update
    destroy
    create
  end

  def certificate
    file_path @resource[:certificate]
  end

  def private_key
    file_path @resource[:private_key]
  end

  def chain
    file_path @resource[:chain]
  end

  def file_path(path)
    return path unless path and path.start_with? 'puppet://'

    served_file = Puppet::FileServing::Metadata.indirection.find(path, :environment => @resource.catalog.environment)
    self.fail "Could not retrieve information for #{path}" unless served_file
    served_file.full_path
  end

  def run_command(cmd, target=false, stdinfile=false, env={})

    env[:PATH] = @resource[:path].join(File::PATH_SEPARATOR) if resource[:path]

    # The Puppet::Util::Execution.execute method is deparcated in Puppet 3.x
    # but we need this to work on 2.7.x too.
    if Puppet::Util::Execution.respond_to?(:execute)
      exec_method = Puppet::Util::Execution.method(:execute)
    else
      exec_method = Puppet::Util.method(:execute)
    end

    if Puppet::Util::Execution.respond_to?(:withenv)
      withenv = Puppet::Util::Execution.method(:withenv)
    else
      withenv = Puppet::Util.method(:withenv)
    end

    # the java keytool will not correctly deal with an empty target keystore
    # file. If we encounter an empty keystore target file, preserve the mode,
    # owner and group, and delete the empty file.
    if target and (File.exists?(target) and File.zero?(target))
      stat = File.stat(target)
      File.delete(target)
    end

    # There's a problem in IBM java keytool wherein stdin cannot be used
    # (trivially) to pass in the keystore passwords. The below hack makes the
    # provider work on SLES with minimal effort at the cost of letting the
    # passphrase to the keystore show up in the process list as an argument.
    # From a best practice standpoint the keystore should be protected by file
    # permissions and not just the passphrase so "making it work on SLES"
    # trumps.
    if Facter.value('osfamily') == 'Suse' and @resource[:password]
      cmd_to_run = cmd.is_a?(String) ? cmd.split(/\s/).first : cmd.first
      if cmd_to_run == command_keytool
        cmd << '-srcstorepass'  << @resource[:password]
        cmd << '-deststorepass' << @resource[:password]
      end
    end

    # Now run the command
    options = { :failonfail => true, :combine => true }
    output = if stdinfile
      withenv.call(env) do
        exec_method.call(cmd, options.merge(:stdinfile => stdinfile.path))
      end
    else
      withenv.call(env) do
        exec_method.call(cmd, options)
      end
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
