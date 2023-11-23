# java_ks

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
     * [Beginning with the module](#beginning-with-the-module)
3. [Setup](#setup)
4. [Usage](#usage)
     * [Certificates](#certificates)
     * [Namevars](#namevars)
     * [Windows task](#windows-task)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [License](#license)
8. [Development](#development)

## Overview

The java_ks module uses a combination of keytool and openssl to manage entries in a Java keystore.

## Module Description

The java_ks module contains a type called `java_ks` and a single provider named `keytool`.  Their purpose is to enable importation of arbitrary, already generated and signed certificates into a Java keystore for use by various applications.

## Setup

### Beginning with the module

To get started with java_ks, declare each `java_ks` resource you need.

```puppet
java_ks { 'puppetca:truststore':
  ensure       => latest,
  certificate  => '/etc/puppet/ssl/certs/ca.pem',
  target       => '/etc/activemq/broker.ts',
  password     => 'puppet',
  trustcacerts => true,
}
```


## Usage

You must specify a target in some way. You can specify `target` after the colon in the title or by using the target attribute in the resource. If you declare both, it will prefer the attribute.

```puppet
java_ks { 'puppetca:keystore':
  ensure       => latest,
  certificate  => '/etc/puppet/ssl/certs/ca.pem',
  target       => '/etc/activemq/broker.ks',
  password     => 'puppet',
  trustcacerts => true,
}

java_ks { 'broker.example.com:/etc/activemq/broker.ks':
  ensure              => latest,
  certificate         => '/etc/puppet/ssl/certs/broker.example.com.pe-internal-broker.pem',
  private_key         => '/etc/puppet/ssl/private_keys/broker.example.com.pe-internal-broker.pem',
  password            => 'albatros',
  password_fail_reset => true,
}
```

For use cases where you want to fetch the certificate data from a secure store, like vault, you can use the `_content` attributes. Here is an example:

```puppet
java_ks { 'broker.example.com:/etc/activemq/broker.ks':
  ensure              => latest,
  certificate_content => $certificate_data_fetched_from_secure_store,
  private_key_content => $private_key_data_fetched_from_secure_store,
  password            => 'albatros',
  password_fail_reset => true,
}
```

**NOTE:** Sensitive fields like `password`, `certificate_content` and `private_key_content` can be deferred using the [Deferred](https://www.puppet.com/docs/puppet/7/template_with_deferred_values.html) function. This will ensure sensitive values are not present in the Catalog.

You can see an example of its use below.

~~~ puppet
java_ks { 'broker.example.com:/etc/activemq/broker.ks':
  ensure              => latest,
  certificate_content => Deferred('sprintf', [$certificate_data_fetched_from_secure_store],
  private_key_content => Deferred('sprintf', [$private_key_data_fetched_from_secure_store],
  password            => Deferred('sprint', ['albatros']),
  password_fail_reset => true,
}
~~~

We recommend using the data type `Senstive` for the attributes `certificate_content` and `private_key_content`. But These attributes also support a regular `String` data type. The `_content` attributes are mutual exclusive with their file-based variants.


You can also use Hiera by passing params to the java_ks::config class:

```yaml
java_ks::config::params:
  'broker.example.com:/etc/activemq/broker.ks':
    ensure: latest
    certificate: '/etc/puppet/ssl/certs/broker.example.com.pe-internal-broker.pem'
    private_key: '/etc/puppet/ssl/private_keys/broker.example.com.pe-internal-broker.pem'
    password: true
```

### Certificates
To have a Java application server use a specific certificate for incoming connections, use the certificate parameter. You will need to simultaneously import the private key accompanying the signed certificate you want to use. As long as you provide the path to the key and the certificate, the provider will do the conversion for you.


### Namevars

The java_ks module supports multiple certificates with different keystores but the same alias by implementing Puppet's composite namevar functionality.  Titles map to namevars via `$alias:$target` (alias of certificate, colon, on-disk path to the keystore). If you create dependencies on these resources you need to remember to use the same title syntax outlined for generating the composite namevars.

*Note about composite namevars:*
The way composite namevars currently work, you must have the colon in the title. This is true *even if you define name and target parameters.*  The title can be `foo:bar`, but the name and target parameters must be `broker.example.com` and `/etc/activemq/broker.ks`. If you follow convention, it will do as you expect and correctly create an entry in the
broker.ks keystore with the alias of broker.example.com.

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-java_ks/blob/main/REFERENCE.md).

## Limitations

The java_ks module uses the `keytool` and `openssl` commands. It should work on all systems with these commands.

Java 7 is supported as of 1.0.0.

Developed against IBM Java 6 on AIX. Other versions may be unsupported.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-java_ks/blob/main/metadata.json)

## License

This codebase is licensed under the Apache2.0 licensing, however due to the nature of the codebase the open source dependencies may also use a combination of [AGPL](https://opensource.org/license/agpl-v3/), [BSD-2](https://opensource.org/license/bsd-2-clause/), [BSD-3](https://opensource.org/license/bsd-3-clause/), [GPL2.0](https://opensource.org/license/gpl-2-0/), [LGPL](https://opensource.org/license/lgpl-3-0/), [MIT](https://opensource.org/license/mit/) and [MPL](https://opensource.org/license/mpl-2-0/) Licensing.

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)
