# frozen_string_literal: true

require 'openssl'
require 'timeout'
require 'puppet/util/filetype'

Puppet::Type.type(:java_ks).provide(:keytool) do
  desc 'Uses a combination of openssl and keytool to manage Java keystores'

  def command_keytool
    'keytool'
  end

  # Keytool can only import a keystore if the format is pkcs12.  Generating and
  # importing a keystore is used to add private_key and certificate pairs.
  def to_pkcs12(path)
    case private_key_type
    when :rsa
      pkey = OpenSSL::PKey::RSA.new File.read(private_key), password
    when :dsa
      pkey = OpenSSL::PKey::DSA.new File.read(private_key), password
    when :ec
      pkey = OpenSSL::PKey::EC.new File.read(private_key), password
    end

    if chain
      x509_cert = OpenSSL::X509::Certificate.new File.read certificate
      chain_certs = get_chain(chain)
    else
      chain_certs = get_chain(certificate)
      x509_cert = chain_certs.shift
    end
    pkcs12 = OpenSSL::PKCS12.create(password, @resource[:name], pkey, x509_cert, chain_certs)
    File.open(path, 'wb') { |f| f.print pkcs12.to_der }
  end

  # Keytool can only import a jceks keystore if the format is der.  Generating and
  # importing a keystore is used to add private_key and certificate pairs.
  def to_der(path)
    x509_cert = OpenSSL::X509::Certificate.new File.read certificate
    File.open(path, 'wb') { |f| f.print x509_cert.to_der }
  end

  def get_chain(path)
    chain_certs = File.read(path, encoding: 'ISO-8859-1').scan(%r{-----BEGIN [^\n]*CERTIFICATE.*?-----END [^\n]*CERTIFICATE-----}m)
    if chain_certs.any?
      chain_certs.map { |cert| OpenSSL::X509::Certificate.new cert }
    else
      chain_certs << ((OpenSSL::X509::Certificate.new File.binread path))
    end
  end

  def password
    if @resource[:password_file].nil?
      @resource[:password]
    else
      file = File.open(@resource[:password_file], 'r')
      pword = file.read
      file.close
      pword.chomp
    end
  end

  def password_file
    pword = password
    source_pword = sourcepassword

    tmpfile = Tempfile.new("#{@resource[:name]}.")
    contents = if File.exist?(@resource[:target]) && !File.empty?(@resource[:target])
                 if source_pword.nil?
                   "#{pword}\n#{pword}"
                 else
                   "#{pword}\n#{source_pword}"
                 end
               elsif !source_pword.nil?
                 "#{pword}\n#{pword}\n#{source_pword}"
               else
                 "#{pword}\n#{pword}\n#{pword}"
               end
    tmpfile.write(contents)
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
    cmd << '-trustcacerts' if @resource[:trustcacerts]
    cmd += ['-destkeypass', @resource[:destkeypass]] unless @resource[:destkeypass].nil?
    cmd += ['-deststoretype', storetype] unless storetype.nil?

    pwfile = password_file
    run_command(cmd, @resource[:target], pwfile)
    tmppk12.close!
    pwfile.close! if pwfile.is_a? Tempfile
  end

  def import_pkcs12
    cmd = [
      command_keytool,
      '-importkeystore', '-srcstoretype', 'PKCS12',
      '-destkeystore', @resource[:target],
      '-srckeystore', certificate
    ]

    if @resource[:source_alias]
      cmd.push(
        '-srcalias', @resource[:source_alias],
        '-destalias', @resource[:name]
      )
    end

    if @resource[:destkeypass]
      cmd.push(
        '-destkeypass', @resource[:destkeypass]
      )
    end

    pwfile = password_file
    run_command(cmd, @resource[:target], pwfile)
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
    cmd << '-trustcacerts' if @resource[:trustcacerts]
    cmd += ['-destkeypass', @resource[:destkeypass]] unless @resource[:destkeypass].nil?

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
    cmd += ['-storetype', storetype] if storetype == :jceks
    begin
      tmpfile = password_file
      run_command(cmd, false, tmpfile)
      tmpfile.close!
      true
    rescue StandardError => e
      if e.message.match?(%r{password was incorrect}i) && (@resource[:password_fail_reset])
        # we have the wrong password for the keystore. so delete it if :password_fail_reset
        File.delete(@resource[:target])
      end
      false
    end
  end

  # Extracts the fingerprints of a given output
  def extract_fingerprint(output)
    fps = []
    output.scan(%r{^Certificate fingerprints:(.*?)Signature?}m).flatten.each do |certblock|
      fps.push(certblock.scan(%r{^\s+\S+:\s+(\S+)}m))
    end
    fps.flatten.sort.join('/')
  end

  # Reading the fingerprint of the certificate on disk.
  def latest
    # The certificate file may not exist during a puppet noop run as it's managed by puppet.
    # Return value must be different to provider.current to signify a possible trigger event.
    if Puppet[:noop] && !File.exist?(certificate)
      'latest'
    elsif storetype == :pkcs12
      cmd = [
        command_keytool, '-v',
        '-list', '-keystore', certificate,
        '-storetype', 'PKCS12', '-storepass', sourcepassword
      ]
      output = run_command(cmd)
      extract_fingerprint(output)

    else
      cmd = [
        command_keytool,
        '-v', '-printcert', '-file', certificate
      ]
      output = run_command(cmd)
      if chain
        cmd = [
          command_keytool,
          '-v', '-printcert', '-file', chain
        ]
        output += run_command(cmd)
      end
      extract_fingerprint(output)

    end
  end

  # Reading the fingerprint of the certificate currently in the keystore.
  def current
    # The keystore file may not exist during a puppet noop run as it's managed by puppet.
    if Puppet[:noop] && !File.exist?(@resource[:target])
      'current'
    else
      cmd = [
        command_keytool,
        '-list', '-v',
        '-keystore', @resource[:target],
        '-alias', @resource[:name]
      ]
      cmd += ['-storetype', storetype] if storetype == :jceks
      tmpfile = password_file
      output = run_command(cmd, false, tmpfile)
      tmpfile.close!
      extract_fingerprint(output)

    end
  end

  # Determine if we need to do an import of a private_key and certificate pair
  # or just add a signed certificate, then do it.
  def create
    if !certificate.nil? && !private_key.nil?
      import_ks
    elsif certificate.nil? && !private_key.nil?
      raise Puppet::Error, 'Keytool is not capable of importing a private key without an accompanying certificate.'
    elsif storetype == :jceks
      import_jceks
    elsif storetype == :pkcs12
      import_pkcs12
    else
      cmd = [
        command_keytool,
        '-importcert', '-noprompt',
        '-alias', @resource[:name],
        '-file', certificate,
        '-keystore', @resource[:target]
      ]
      cmd << '-trustcacerts' if @resource[:trustcacerts]
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
    cmd += ['-storetype', storetype] if storetype == :jceks
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
    return @resource[:certificate] if @resource[:certificate]

    # When no certificate file is specified, we infer the usage of
    # certificate content and create a tempfile containing this value.
    # we leave it to to the tempfile to clean it up after the pupet run exists.
    file = Tempfile.new('certificate')
    # Check if the specified value is a Sensitive data type. If so, unwrap it and use
    # the value.
    content = @resource[:certificate_content].respond_to?(:unwrap) ? @resource[:certificate_content].unwrap : @resource[:certificate_content]
    file.write(content)
    file.close
    file.path
  end

  def private_key
    return @resource[:private_key] if @resource[:private_key]
    return unless @resource[:private_key_content]

    # When no private key file is specified, we infer the usage of
    # private key content and create a tempfile containing this value.
    # we leave it to to the tempfile to clean it up after the pupet run exists.
    file = Tempfile.new('private_key')
    # Check if the specified value is a Sensitive data type. If so, unwrap it and use
    # the value.
    content = @resource[:private_key_content].respond_to?(:unwrap) ? @resource[:private_key_content].unwrap : @resource[:private_key_content]
    file.write(content)
    file.close
    file.path
  end

  def private_key_type
    @resource[:private_key_type]
  end

  def chain
    @resource[:chain]
  end

  def sourcepassword
    @resource[:source_password]
  end

  def storetype
    @resource[:storetype]
  end

  def run_command(cmd, target = false, stdinfile = false, env = {})
    env[:PATH] = @resource[:path].join(File::PATH_SEPARATOR) if @resource[:path]

    # The Puppet::Util::Execution.execute method is deprecated in Puppet 3.x
    # but we need this to work on 2.7.x too.
    exec_method = if Puppet::Util::Execution.respond_to?(:execute)
                    Puppet::Util::Execution.method(:execute)
                  else
                    Puppet::Util.method(:execute)
                  end

    withenv = if Puppet::Util::Execution.respond_to?(:withenv)
                Puppet::Util::Execution.method(:withenv)
              else
                Puppet::Util.method(:withenv)
              end

    # the java keytool will not correctly deal with an empty target keystore
    # file. If we encounter an empty keystore target file, preserve the mode,
    # owner and group, temporarily raise the umask, and delete the empty file.
    if target && (File.exist?(target) && File.empty?(target))
      stat = File.stat(target)
      umask = File.umask(0o077)
      File.delete(target)
    end

    # There's a problem in IBM java keytool wherein stdin cannot be used
    # (trivially) to pass in the keystore passwords. The below hack makes the
    # provider work on SLES with minimal effort at the cost of letting the
    # passphrase to the keystore show up in the process list as an argument.
    # From a best practice standpoint the keystore should be protected by file
    # permissions and not just the passphrase so "making it work on SLES"
    # trumps.
    if Facter.value('os.family') == 'Suse' && @resource[:password]
      cmd_to_run = cmd.is_a?(String) ? cmd.split(%r{\s}).first : cmd.first
      if cmd_to_run == command_keytool
        cmd << '-srcstorepass' << @resource[:password]
        cmd << '-deststorepass' << @resource[:password]
      end
    end

    # Now run the command
    options = { failonfail: true, combine: true }
    output = nil
    begin
      Timeout.timeout(@resource[:keytool_timeout], Timeout::Error) do
        output = if stdinfile
                   withenv.call(env) do
                     exec_method.call(cmd, options.merge(stdinfile: stdinfile.path))
                   end
                 else
                   withenv.call(env) do
                     exec_method.call(cmd, options)
                   end
                 end
      end
    rescue Timeout::Error
      raise Puppet::Error, "Timed out waiting for '#{@resource[:name]}' to run keytool"
    end

    # for previously empty files, restore the umask, mode, owner and group.
    # The funky double-take check is because on Suse defined? doesn't seem
    # to behave quite the same as on Debian, RedHat
    if target and (defined? stat and stat) # rubocop:disable Style/AndOr : Changing 'and' to '&&' causes test failures.
      File.umask(umask)
      # Need to change group ownership before mode to prevent making the file
      # accessible to the wrong group.
      File.chown(stat.uid, stat.gid, target)
      File.chmod(stat.mode, target)
    end

    output
  end
end
