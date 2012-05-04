This modules ships a type called java_ks and a single provider named keytool.  The purpose is to be able to import arbitrary, already generated and signed certificates into a java keystore for use by various applications.  It has a concept of absent, present, and latest.  Absent and present are self explanatory but latest will actually verify md5 certificate fingerprints for the stored certificate and the source file.  Support for multiple certificates with the same alias but different keystores has been implemented using Puppet's composite namevar functionality.  The mapping of title to namevars is $alias:$target (alias of certificate, colon, on disk path to the keystore).  If you create dependencies on these resources you need to remember to use the same title syntax outlined for generating the composite namevars.  To have a java application server use a specific certificate for incoming connections you will need to import the private key accompanying signed certificate you want to use at the same time, this is a limitation of keytool.  As long as you provide the path to the key and the certificate the provider will do the conversion for you.

Note about composite namevars.  The way they currently work you must have the colon in the title.  YES even if you define name and target parameters.  The title can be 'foo:bar' but the name and target parameters be 'broker.example.com' and '/etc/activemq/broker.ks' and it will do as you expect and correctly create an entry in the broker.ks keystore with the alias of broker.example.com...I think you could consider this a bug.

Example Usage:
```puppet
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
```
