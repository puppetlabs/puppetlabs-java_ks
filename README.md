java_ks
=======

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-java_ks.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-java_ks)

####Table of Contents

1. [Overview - What is the java_ks module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with java_ks](#setup)
4. [Usage - The parameters available for configuration](#usage)
5. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The java_ks module uses a combination of keytool and openssl to manage entries in a Java keystore.

Module Description
------------------

The java_ks module contains a type called 'java_ks' and a single provider named 'keytool'.  Their purpose is to enable importation of arbitrary, already generated and signed certificates into a java keystore for use by various applications. 

Setup
-----

**What java_ks affects:**

* keystore repositories

### Beginning with java_ks

To use the java_ks module's functionality, declare each java_ks resource you need

    java_ks { 'puppetca:truststore':
      ensure       => latest,
      certificate  => '/etc/puppet/ssl/certs/ca.pem',
      target       => '/etc/activemq/broker.ts',
      password     => 'puppet',
      trustcacerts => true,
    }
    
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

Usage
-----

### java_ks

This resource manages the entries in a java keystore, and uses composite namevars to accomplish the same alias spread across multiple target keystores.

**Parameters within java_ks**

#### `certificate`

An already-signed certificate to place in the keystore. Accepts local file paths or `puppet://` uri paths.

To have a java application server use a specific certificate for incoming connections, you will need to simultaneously import the private key accompanying the signed certificate you want to use. As long as you provide the path to the key and the certificate, the provider will do the conversion for you.

#### `chain`

Some java applications do not properly send intermediary certificate authorities. In these cases, you can bundle them with the server certificate using this chain parameter. Accepts local file paths or `puppet://` uri paths.

    java_ks { 'broker.example.com:/etc/activemq/broker.jks':
      ensure      => latest,
      certificate => '/etc/ssl/certs/broker.example.com.pem',
      private_key => '/etc/ssl/private/broker.example.com.key',
      chain       => '/etc/ssl/certs/GlobalSign_Intermediate_CA.pem
      password    => 'puppet',
    }

#### `ensure`

The `ensure` parameter accepts three attributes: absent, present, and latest.  Latest verifies md5 certificate fingerprints for the stored certificate and the source file.  

#### `password`

The password used to protect the keystore. If private keys are also protected, this password will be used to attempt to unlock them. 

#### `password_file`

Used as an alternative to `password` here you can specify a plaintext file where the password is stored.

#### `path`

The search path used for command (keytool, openssl) execution. Paths can be specified as an array or as a file path seperated list (for example : in linux).

#### `private_key`

If you want an application to be a server and encrypt traffic, you will need a private key. Private key entries in a keystore must be accompanied by a signed certificate for the keytool provider. Accepts local file paths or `puppet://` uri paths.

#### `target`

Destination file for the keystore. We autorequire the parent directory for convenience.

#### `trustcacerts`

Certificate authorities input into a keystore aren’t trusted by default, so if you are adding a CA you need to set this parameter to true.

### Namevars

Java_ks supports multiple certificates with different keystores but the same alias by implementing Puppet's composite namevar functionality.  Titles map to namevars via `$alias:$target` (alias of certificate, colon, on-disk path to the keystore). If you create dependencies on these resources you need to remember to use the same title syntax outlined for generating the composite namevars. 

*Note about composite namevars:*  
The way composite namevars currently work, you must have the colon in the title. This is true *even if you define name and target parameters.*  The title can be `foo:bar`, but the name and target parameters must be `broker.example.com` and `/etc/activemq/broker.ks`. If you follow convention, it will do as you expect and correctly create an entry in the broker.ks keystore with the alias of broker.example.com.

Implementation
--------------

### keytool

Keytool is a provider that uses a combination of the binaries openssl and keytool to manage Java keystores

Limitations
------------

The java_ks module uses the `keytool` and `openssl` commands. It should work on all systems with these commands. 

At the moment, Java 7 isn't fully supported, and `ensure => latest` will fail.

Development
-----------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)
