require 'openssl'
require 'puppet/util/filetype'

Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  def command_keytool
    'keytool'
  end

  # Keytool can only import a keystore if the format is pkcs12.  Generating and
  # importing a keystore is used to add private_key and certifcate pairs.
  def to_pkcs12(path)
    pkey = OpenSSL::PKey::RSA.new File.read private_key
    x509_cert = OpenSSL::X509::Certificate.new File.read certificate
    if chain
      chain_certs = [(OpenSSL::X509::Certificate.new File.read chain)]
    else
      chain_certs = []
    end
    pkcs12 = OpenSSL::PKCS12.create(get_password, @resource[:name], pkey, x509_cert, chain_certs)
    File.open(path, "wb") { |f| f.print pkcs12.to_der }
  end

  # Keytool can only import a jceks keystore if the format is der.  Generating and
  # importing a keystore is used to add private_key and certifcate pairs.
  def to_der(path)
    x509_cert = OpenSSL::X509::Certificate.new File.read certificate
    File.open(path, "wb") { |f| f.print x509_cert.to_der }
  end

  def get_password
    if @resource[:password_file].nil?
      @resource[:password]
    else
      file = File.open(@resource[:password_file], "r")
      pword = file.read
      file.close
      pword.chomp
    end
  end

  def password_file
    pword = get_password

    tmpfile = Tempfile.new("#{@resource[:name]}.")
    if File.exists?(@resource[:target]) and not File.zero?(@resource[:target])
      tmpfile.write("#{pword}\n#{pword}")
    else
      tmpfile.write("#{pword}\n#{pword}\n#{pword}")
    end
    tmpfile.flush
    tmpfile
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
    cmd += [ '-destkeypass', @resource[:destkeypass] ] unless @resource[:destkeypass].nil?

    pwfile = password_file
    run_command(cmd, @resource[:target], pwfile)
    tmppk12.close!
    pwfile.close! if pwfile.is_a? Tempfile
  end

  def import_jceks
    tmpder = Tempfile.new("#{@resource[:name]}.")
    to_der(tmpder.path)
    cmd = [
	command_keytool,
	'-importcert', '-noprompt',
	'-alias', @resource[:name],
	'-file', tmpder.path,
	'-keystore', @resource[:target],
	'-storetype', storetype
    ]
    cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
    cmd += [ '-destkeypass', @resource[:destkeypass] ] unless @resource[:destkeypass].nil?

    pwfile = password_file
    run_command(cmd, @resource[:target], pwfile)
    pwfile.close! if pwfile.is_a? Tempfile
  end

  def exists?
    cmd = [
        command_keytool,
        '-list',
        '-keystore', @resource[:target],
        '-alias', @resource[:name]
    ]
    cmd += [ '-storetype', storetype ] if storetype == "jceks"
    begin
      tmpfile = password_file
      run_command(cmd, false, tmpfile)
      tmpfile.close!
      return true
    rescue
      return false
    end
  end

  # Reading the fingerprint of the certificate on disk.
  def latest
    # The certificate file may not exist during a puppet noop run as it's managed by puppet.
    # Return value must be different to provider.current to signify a possible trigger event.
    if Puppet[:noop] and !File.exists?(certificate)
      return 'latest'
    else
      cmd = [
          command_keytool,
          '-v', '-printcert', '-file', certificate
      ]
      output = run_command(cmd)
      latest = output.scan(/MD5:\s+(.*)/)[0][0]
      return latest
    end
  end

  # Reading the fingerprint of the certificate currently in the keystore.
  def current
    # The keystore file may not exist during a puppet noop run as it's managed by puppet.
    if Puppet[:noop] and !File.exists?(@resource[:target])
      return 'current'
    else
      cmd = [
          command_keytool,
          '-list', '-v',
          '-keystore', @resource[:target],
          '-alias', @resource[:name]
      ]
      cmd += [ '-storetype', storetype ] if storetype == "jceks"
      tmpfile = password_file
      output = run_command(cmd, false, tmpfile)
      tmpfile.close!
      current = output.scan(/Certificate fingerprints:\n\s+MD5:  (.*)/)[0][0]
      return current
    end
  end

  # Determine if we need to do an import of a private_key and certificate pair
  # or just add a signed certificate, then do it.
  def create
    if !certificate.nil? and !private_key.nil?
      import_ks
    elsif certificate.nil? and !private_key.nil?
      raise Puppet::Error, 'Keytool is not capable of importing a private key without an accomapaning certificate.'
    elsif storetype == "jceks"
      import_jceks
    else
      cmd = [
          command_keytool,
          '-importcert', '-noprompt',
          '-alias', @resource[:name],
          '-file', certificate,
          '-keystore', @resource[:target]
      ]
      cmd << '-trustcacerts' if @resource[:trustcacerts] == :true
      tmpfile = password_file
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
    tmpfile = password_file
    run_command(cmd, false, tmpfile)
    tmpfile.close!
  end

  # Being safe since I have seen some additions overwrite and some just throw errors.
  def update
    destroy
    create
  end

  def certificate
    @resource[:certificate]
  end

  def private_key
    @resource[:private_key]
  end

  def chain
    @resource[:chain]
  end

  def storetype
    @resource[:storetype]
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
    # owner and group, temporarily raise the umask, and delete the empty file.
    if target and (File.exists?(target) and File.zero?(target))
      stat = File.stat(target)
      umask = File.umask(0077)
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
        cmd << '-srcstorepass' << @resource[:password]
        cmd << '-deststorepass' << @resource[:password]
      end
    end

    # Now run the command
    options = {:failonfail => true, :combine => true}
    output = if stdinfile
               withenv.call(env) do
                 exec_method.call(cmd, options.merge(:stdinfile => stdinfile.path))
               end
             else
               withenv.call(env) do
                 exec_method.call(cmd, options)
               end
             end

    # for previously empty files, restore the umask, mode, owner and group.
    # The funky double-take check is because on Suse defined? doesn't seem
    # to behave quite the same as on Debian, RedHat
    if target and (defined? stat and stat)
      File.umask(umask)
      # Need to change group ownership before mode to prevent making the file
      # accessible to the wrong group.
      File.chown(stat.uid, stat.gid, target)
      File.chmod(stat.mode, target)
    end

    return output
  end

end
