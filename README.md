#java_ks

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-java_ks.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-java_ks)

####Table of Contents

1. [Overview - What is the java_ks module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with java_ks](#setup)
4. [Usage - The parameters available for configuration](#usage)
5. [Reference - An under-the-hood peek at what the module is doing](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

##Overview

The java_ks module uses a combination of keytool and openssl to manage entries in a Java keystore.

##Module Description

The java_ks module contains a type called `java_ks` and a single provider named `keytool`.  Their purpose is to enable importation of arbitrary, already generated and signed certificates into a Java keystore for use by various applications.

##Setup

### Beginning with java_ks

To get started with java_ks, declare each `java_ks` resource you need.

~~~
java_ks { 'puppetca:truststore':
  ensure       => latest,
  certificate  => '/etc/puppet/ssl/certs/ca.pem',
  target       => '/etc/activemq/broker.ts',
  password     => 'puppet',
  trustcacerts => true,
}
~~~


##Usage

You must specify a target in some way. You can specify `target` after the colon in the title or by using the target attribute in the resource. If you declare both, it will prefer the attribute.

~~~
java_ks { 'puppetca:keystore':
  ensure       => latest,
  certificate  => '/etc/puppet/ssl/certs/ca.pem',
  target       => '/etc/activemq/broker.ks',
  password     => 'puppet',
  trustcacerts => true,
}

java_ks { 'broker.example.com:/etc/activemq/broker.ks':
  ensure      => latest,
  certificate => '/etc/puppet/ssl/certs/broker.example.com.pe-internal-broker.pem',
  private_key => '/etc/puppet/ssl/private_keys/broker.example.com.pe-internal-broker.pem',
  password    => 'puppet',
}
~~~

### Certificates
To have a Java application server use a specific certificate for incoming connections, use the certificate parameter. You will need to simultaneously import the private key accompanying the signed certificate you want to use. As long as you provide the path to the key and the certificate, the provider will do the conversion for you.


### Namevars

The java_ks module supports multiple certificates with different keystores but the same alias by implementing Puppet's composite namevar functionality.  Titles map to namevars via `$alias:$target` (alias of certificate, colon, on-disk path to the keystore). If you create dependencies on these resources you need to remember to use the same title syntax outlined for generating the composite namevars.

*Note about composite namevars:*  
The way composite namevars currently work, you must have the colon in the title. This is true *even if you define name and target parameters.*  The title can be `foo:bar`, but the name and target parameters must be `broker.example.com` and `/etc/activemq/broker.ks`. If you follow convention, it will do as you expect and correctly create an entry in the
broker.ks keystore with the alias of broker.example.com.

##Reference

###Public Types
* `java_ks`: This resource manages the entries in a Java keystore, and uses composite namevars to allow the same alias across multiple target keystores.

###Public Providers
* `keytool`: Manages Java keystores by using a combination of the `openssl` and `keytool` commands.

####Parameters
All parameters, except where specified, are optional.

#####`certificate`
*Required.* Places an already-signed certificate in the keystore. This autorequires the specified file and must be present on the node before java_ks{} is run. Valid options: string. Default: undef.

#####`chain`
Bundles intermediary certificate authorities with certificate authorities. This autorequires the file of the same path and must be present on the node before java_ks{} is run. Valid options: string. Default: undef.

#####`ensure`
Valid options: absent, present, latest. Latest verifies md5 certificate fingerprints for the stored certificate and the source file. Default: present.

#####`name`
*Required.* Identifies the entry in the keystore. This will be converted to lowercase. Valid options: string. Default: undef.  

#####`password`
This password is used to protect the keystore. If private keys are also protected, this password will be used to attempt to unlock them. Valid options: String. Must be 6 or more characters. This cannot be used together with `password_file`, but *you must pass at least one of these parameters.* Default: undef.

#####`password_file`
Sets a plaintext file where the password is stored. Used as an alternative to `password`. This cannot be used together with `password`, but *you must pass at least one of these parameters.* Valid options: String to the plaintext file. Default: undef.

#####`destkeypass`
The password you want to set to protect the key in the keystore.

#####`path`
Used for command (keytool, openssl) execution. Valid options: array or file path separated list (for example : in linux). Default: undef.

#####`private_key`
Sets a private key that encrypts traffic to a server application. Must be accompanied by a signed certificate for the keytool provider. This autorequires the specified file and must be present on the node before java_ks{} is run. Valid options: string. Default: undef.

#####`target`
*Required.* Specifies a destination file for the keystore. Autorequires the parent directory of the file. Valid options: string. Default: undef.

#####`trustcacerts`
Certificate authorities input into a keystore aren’t trusted by default, so if you are adding a CA you need to set this parameter to 'true'. Valid options: 'true' or 'false'. Default: 'false'.

### `storetype`

The storetype parameter allows you to use 'jceks' format if desired.

    java_ks { 'puppetca:/opt/puppet/truststore.jceks':
      ensure       => latest,
      storetype    => 'jceks',
      certificate  => '/etc/puppet/ssl/certs/ca.pem',
      password     => 'puppet',
      trustcacerts => true,
    }


Limitations
------------

The java_ks module uses the `keytool` and `openssl` commands. It should work on all systems with these commands.

Java 7 is supported as of 1.0.0.

Developed against IBM Java 6 on AIX. Other versions may be unsupported.

Development
-----------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve.  

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)
