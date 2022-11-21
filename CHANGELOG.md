# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.4.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.4.1) (2022-11-21)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.4.0...v4.4.1)

### Fixed

- \(CONT-186\) Set `-deststoretype` [\#418](https://github.com/puppetlabs/puppetlabs-java_ks/pull/418) ([david22swan](https://github.com/david22swan))
- pdksync - \(CONT-189\) Remove support for RedHat6 / OracleLinux6 / Scientific6 [\#417](https://github.com/puppetlabs/puppetlabs-java_ks/pull/417) ([david22swan](https://github.com/david22swan))
- pdksync - \(CONT-130\) - Dropping Support for Debian 9 [\#414](https://github.com/puppetlabs/puppetlabs-java_ks/pull/414) ([jordanbreen28](https://github.com/jordanbreen28))

### UNCATEGORIZED PRS; LABEL THEM ON GITHUB

- reversed insync set comparison [\#412](https://github.com/puppetlabs/puppetlabs-java_ks/pull/412) ([rstuart-indue](https://github.com/rstuart-indue))

## [v4.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.4.0) (2022-10-03)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.3.1...v4.4.0)

### Added

- pdksync - \(GH-cat-11\) Certify Support for Ubuntu 22.04 [\#408](https://github.com/puppetlabs/puppetlabs-java_ks/pull/408) ([david22swan](https://github.com/david22swan))
- pdksync - \(GH-cat-12\) Add Support for Redhat 9 [\#404](https://github.com/puppetlabs/puppetlabs-java_ks/pull/404) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MAINT\) Drop support for Solaris 10, Windows Server 2008 R2 and Windows 7+8.1 [\#410](https://github.com/puppetlabs/puppetlabs-java_ks/pull/410) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.3.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.3.1) (2022-05-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.3.0...v4.3.1)

### Fixed

- Don't require certificate or private key params when ensure: absent [\#399](https://github.com/puppetlabs/puppetlabs-java_ks/pull/399) ([tparkercbn](https://github.com/tparkercbn))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.3.0) (2022-04-05)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.2.0...v4.3.0)

### Added

- Add support for certificate\_content and private\_key\_content parameters [\#385](https://github.com/puppetlabs/puppetlabs-java_ks/pull/385) ([hajee](https://github.com/hajee))
- pdksync - \(IAC-1753\) - Add Support for AlmaLinux 8 [\#381](https://github.com/puppetlabs/puppetlabs-java_ks/pull/381) ([david22swan](https://github.com/david22swan))
- pdksync - \(IAC-1751\) - Add Support for Rocky 8 [\#380](https://github.com/puppetlabs/puppetlabs-java_ks/pull/380) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - \(GH-iac-334\) Remove Support for Ubuntu 14.04/16.04 [\#390](https://github.com/puppetlabs/puppetlabs-java_ks/pull/390) ([david22swan](https://github.com/david22swan))
- pdksync - \(IAC-1787\) Remove Support for CentOS 6 [\#384](https://github.com/puppetlabs/puppetlabs-java_ks/pull/384) ([david22swan](https://github.com/david22swan))
- pdksync - \(IAC-1598\) - Remove Support for Debian 8 [\#379](https://github.com/puppetlabs/puppetlabs-java_ks/pull/379) ([david22swan](https://github.com/david22swan))
- Fix "password" as Property [\#378](https://github.com/puppetlabs/puppetlabs-java_ks/pull/378) ([cocker-cc](https://github.com/cocker-cc))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.2.0) (2021-08-25)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.1.0...v4.2.0)

### Added

- pdksync - \(IAC-1709\) - Add Support for Debian 11 [\#376](https://github.com/puppetlabs/puppetlabs-java_ks/pull/376) ([david22swan](https://github.com/david22swan))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.1.0) (2021-06-28)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.0.0...v4.1.0)

### Added

- Accept Datatype Sensitive for Secrets [\#373](https://github.com/puppetlabs/puppetlabs-java_ks/pull/373) ([cocker-cc](https://github.com/cocker-cc))

### Fixed

- Fix fingerprint comparison [\#372](https://github.com/puppetlabs/puppetlabs-java_ks/pull/372) ([kdehairy](https://github.com/kdehairy))
- \(MODULES-11067\) Fix keytool output parsing [\#370](https://github.com/puppetlabs/puppetlabs-java_ks/pull/370) ([durist](https://github.com/durist))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.0.0) (2021-03-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.4.0...v4.0.0)

### Changed

- pdksync - \(MAINT\) Remove SLES 11 support [\#354](https://github.com/puppetlabs/puppetlabs-java_ks/pull/354) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - \(MAINT\) Remove RHEL 5 family support [\#353](https://github.com/puppetlabs/puppetlabs-java_ks/pull/353) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [\#351](https://github.com/puppetlabs/puppetlabs-java_ks/pull/351) ([carabasdaniel](https://github.com/carabasdaniel))

### Fixed

- Fix keytool path handling [\#349](https://github.com/puppetlabs/puppetlabs-java_ks/pull/349) ([chillinger](https://github.com/chillinger))

## [v3.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.4.0) (2020-12-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.3.0...v3.4.0)

### Added

- pdksync - \(feat\) Add support for Puppet 7 [\#342](https://github.com/puppetlabs/puppetlabs-java_ks/pull/342) ([daianamezdrea](https://github.com/daianamezdrea))

## [v3.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.3.0) (2020-11-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.2.0...v3.3.0)

### Added

- \(IAC-994\) Removal of inappropriate terminology [\#335](https://github.com/puppetlabs/puppetlabs-java_ks/pull/335) ([pmcmaw](https://github.com/pmcmaw))
- pdksync - \(IAC-973\) - Update travis/appveyor to run on new default branch `main` [\#327](https://github.com/puppetlabs/puppetlabs-java_ks/pull/327) ([david22swan](https://github.com/david22swan))

### Fixed

- Change latest/current comparison to account for chains [\#336](https://github.com/puppetlabs/puppetlabs-java_ks/pull/336) ([mwpower](https://github.com/mwpower))
- add storetype parameter comparison to 'destroy' method [\#333](https://github.com/puppetlabs/puppetlabs-java_ks/pull/333) ([mwpower](https://github.com/mwpower))
- Correct jceks symbol comparison [\#332](https://github.com/puppetlabs/puppetlabs-java_ks/pull/332) ([mwpower](https://github.com/mwpower))

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.2.0) (2020-07-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.1.0...v3.2.0)

### Added

- Allow DER formatted certificates with keys. [\#319](https://github.com/puppetlabs/puppetlabs-java_ks/pull/319) ([tomkitchen](https://github.com/tomkitchen))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.1.0) (2019-12-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.0.0...v3.1.0)

### Added

- \(FM-8224\) - Addition of support for CentOS 8 [\#294](https://github.com/puppetlabs/puppetlabs-java_ks/pull/294) ([david22swan](https://github.com/david22swan))
- \(feat\) adding litmus support [\#292](https://github.com/puppetlabs/puppetlabs-java_ks/pull/292) ([tphoney](https://github.com/tphoney))
- pdksync - "Add support on Debian10" [\#288](https://github.com/puppetlabs/puppetlabs-java_ks/pull/288) ([lionce](https://github.com/lionce))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.0.0) (2019-08-20)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.4.0...v3.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#276](https://github.com/puppetlabs/puppetlabs-java_ks/pull/276) ([david22swan](https://github.com/david22swan))

### Added

- \(FM-8155\) Add Window Server 2019 support [\#281](https://github.com/puppetlabs/puppetlabs-java_ks/pull/281) ([eimlav](https://github.com/eimlav))
- \(FM-8042\) Add RedHat 8 support [\#280](https://github.com/puppetlabs/puppetlabs-java_ks/pull/280) ([eimlav](https://github.com/eimlav))
- Add initial support for DSA private keys. [\#273](https://github.com/puppetlabs/puppetlabs-java_ks/pull/273) ([surcouf](https://github.com/surcouf))

### Fixed

- FM-7945 stringify java\_ks [\#279](https://github.com/puppetlabs/puppetlabs-java_ks/pull/279) ([lionce](https://github.com/lionce))
- Modules 8962 - java\_ks - Windows 2012 failing smoke [\#278](https://github.com/puppetlabs/puppetlabs-java_ks/pull/278) ([lionce](https://github.com/lionce))

## [2.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.4.0) (2019-02-19)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.3.0...2.4.0)

### Added

- \(MODULES-8146\) - Add SLES 15 support [\#255](https://github.com/puppetlabs/puppetlabs-java_ks/pull/255) ([eimlav](https://github.com/eimlav))

### Fixed

- \(MODULES-8549\) - Bump of Java version used for test [\#260](https://github.com/puppetlabs/puppetlabs-java_ks/pull/260) ([david22swan](https://github.com/david22swan))
- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#257](https://github.com/puppetlabs/puppetlabs-java_ks/pull/257) ([tphoney](https://github.com/tphoney))
- Fix provider so "latest" gets the MD5 AND SHA1 hashes for comparing [\#252](https://github.com/puppetlabs/puppetlabs-java_ks/pull/252) ([absltkaos](https://github.com/absltkaos))
- \(FM-7505\) - Bumping Windows jdk version to 8.0.191 [\#251](https://github.com/puppetlabs/puppetlabs-java_ks/pull/251) ([pmcmaw](https://github.com/pmcmaw))
- \(MODULES-8125\) Fix unnecessary change when using intermediate certificates [\#250](https://github.com/puppetlabs/puppetlabs-java_ks/pull/250) ([johngmyers](https://github.com/johngmyers))

## [2.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.3.0) (2018-09-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.2.0...2.3.0)

### Changed

- \[FM-6966\] Removal of unsupported OS from java\_ks [\#230](https://github.com/puppetlabs/puppetlabs-java_ks/pull/230) ([david22swan](https://github.com/david22swan))

### Added

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#246](https://github.com/puppetlabs/puppetlabs-java_ks/pull/246) ([tphoney](https://github.com/tphoney))
- \(FM-7238\) - Addition of support for Ubuntu 18.04 [\#237](https://github.com/puppetlabs/puppetlabs-java_ks/pull/237) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MODULES-7632\) - Update README Limitations section [\#239](https://github.com/puppetlabs/puppetlabs-java_ks/pull/239) ([eimlav](https://github.com/eimlav))
- \(MODULES-1997\) - Update the target when the cert chain changes [\#233](https://github.com/puppetlabs/puppetlabs-java_ks/pull/233) ([johngmyers](https://github.com/johngmyers))
- \(MODULES-6342\) Update pathing for new java in \#229 [\#231](https://github.com/puppetlabs/puppetlabs-java_ks/pull/231) ([hunner](https://github.com/hunner))

## 2.2.0
### Summary
A release that converts the module to the PDK version 1.3.2, alongside an additional parameter added.

### Added
- Add support for `destkeypass` when importing PKCS12 keystores.

### Changed
- Module has been converted to the PDK with version 1.3.2.

## Supported Release [2.1.0]
### Summary
The main purpose of this module is to release Rubocop changes, with some other minor updates included.

### Added
- Support added for the specifying of source cert alias.

### Changed
- The module has been changed to comply with the set rubocop guidelines.
- JDK updated to 8u161.
- Fingerprint extraction in keytool.rb has been improved upon.
- Modulesync changes.

## Supported Release [2.0.0]
### Summary
This is a roll up of maintainence changes, features and compatibility updates from throughout the year. This release is backwards incompatible because the Puppet version requirements have now changed with the lower Puppet version boundary jumping from 3.0.0 to 4.7.0 and we have removed vulnerable puppet3 support dependencies.

### Added
- Debian 9 entry in 'metadata.json'
- Support for importing pkcs12 files by introducing a function called `import pkcs12`
- Support for removal of key store file on invalid password by introducing `password_fail_reset`

### Changed
- Appveyor testing has been enabled
- General maintainence changes via modulessync
- Java-ks is now being managed in modulesync as a cross-platform module
- [FM-6547](https://tickets.puppetlabs.com/browse/FM-6547) - Pin JDK installation package to 8.0.152 for Windows
- pkcs12 acceptance tests no longer run on SLES
- CONTRIBUTING.md updates
- Travis ruby version to 2.4.0 and 2.1.9
- Upper Puppet boundary to Puppet 6.0.0
- Lower Puppet boundary to Puppet 4.7.0

### Fixed
- Unit test failures on Windows
- Java 9 support

### Removed
- SLES 10 SP4 entry in 'metadata.json'
- Debian 6 entry in 'metadata.json'
- Windows Server 2003 R2 and Windows 8 entry in 'metadata.json'
- Ubuntu 10.04 and 12.04 entry in 'metadata.json'
- [FM-6588](https://tickets.puppetlabs.com/browse/FM-6588) - Remove vulnerable puppet3 support dependencies

## Supported Release 1.6.0
### Summary
The keytool would hang on occasion for unexplained reasons, so keytool executions are wrapped in a timeout that defaults to 120 seconds and is configurable by the `keytool_timeout` parameter.

### Added
- New parameter: `keytool_timeout`

## Supported Release 1.5.0
### Summary
This release contains some small features and one bugfix which makes the module environment safe.

#### Features
- Added a new parameter, `private_key_type` which defaults to `rsa` but can also be set to `ec` for ECDSA keys.
- Added `java_ks::config` class with `create_resources` so that Hiera can be used to manage the config.
- [MODULES-2495] Allows the provider to work with encrypted private keys.

#### Bugfixes
- [MODULES-4505] Fixed `self.title_patterns` in java_ks type so it doesn't return a Proc so the module is environment safe.

## Supported Release 1.4.1
### Summary
This release contains bugfixes around certificate chains and other testing improvements.

#### Bugfixes
- Dont expose keystore content when keystore initally empty.
- Support certificate chains in certificate file.
- Support multiple intermediate certificates in chain.
- Improve cert chain acceptance tests.
- Update to current msync configs.
- Debian 8 support.

## Supported Release 1.4.0
### Summary
This release contains a new option to provide destkeypass. Also contains 
bugfixes and a metadata update to support Puppet Enterprise 2015.3.x.

#### Features
- Adds `destkeypass` option to pass in password when importing into the keystore.
- Adds feature support for JCEKS format and extensions.

#### Bugfixes
- Fixes composite title patterns in provider to improve support for Windows.

#### Test Improvements
- Improves Windows testing.

## 2015-07-20 - Supported Release 1.3.1
### Summary
This release updates the metadata for the upcoming release of PE as well as an additional bugfix.

#### Bugfixes
- Fixes Puppet.newtype deprecation warning

## 2015-04-14 - Supported Release 1.3.0
### Summary
Remove openssl command line tool from requirements

#### Features
- Add Windows support and tests

## 2014-11-11 - Supported Release 1.2.6
### Summary

This release has test fixes and files synced from modulesync.

## 2014-07-10 - Supported Release 1.2.5
### Summary

This release has bugfixes and test improvements.

#### Features
- Update tests to use RSpec 2.99 syntax

#### Bugfixes
- Remove broken support for puppet:// files.
- Remove incorrect statment of windows support from metadata.json.
- Fix path issue for openssl on solaris 11.

#### Known Bugs
* No known bugs

## 2014-06-04 - Release 1.2.4
### Summary

This is a compatibility release. No functional changes to this module were made
in this release, just testing infrastructure changes to extend tests to RHEL7
and Ubuntu 14.04

#### Features

#### Bugfixes

#### Known Bugs
* No known bugs

## 2014-03-04 - Supported Release 1.2.3
### Summary

This is a supported release.  This release removes a testing symlink that can
cause trouble on systems where /var is on a seperate filesystem from the
modulepath.

#### Features

#### Bugfixes

#### Known Bugs
* No known bugs

## 2014-03-04 - Supported Release 1.2.2
### Summary

This is a supported release.  Only tests and documentation were changed.

#### Features
- Test changes.
- Documentation changes.

#### Bugfixes

#### Known Bugs
* No known bugs


## 2014-02-12 - Release 1.2.1

#### Bugfixes
- Updating specs


## 2013-09-18 - Release 1.2.0

### Summary
This release adds `puppet://` URI support, a few bugfixes, and lots of tests.

#### Features
- `puppet://` URI support for the `chain`, `certificate`, and `private_key` parameters

#### Bugfixes
- Validate that keystore passwords are > 6 characters (would silent fail before)
- Fixed corrupted keystore PKCS12 files in some cases.
- More acceptance tests, unit tests, and rspec-puppet tests.


## 1.1.0

This minor feature provides a number of new features:

* We have introduced a new property `password_file` to the java_ks type, so
  that users can specify a plain text file to be used for unlocking a Java
  keystore file.
* A new property `path` has been also added so you can add a custom search
  path for the command line tooling (keystore etc.)

Travis-CI support has also been added to improve testing.

#### Detailed Changes

* Support for executables outside the system default path (Filip Hrbek)
* Add password_file to type (Raphaël Pinson)
* Travis ci support (Adrien Thebo)
* refactor keytool provider specs (Adrien Thebo)

---------------------------------------

## 0.0.6


Fixes an issue with ibm java handling input from stdin on SLES

[2.1.0]:https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.0.0...2.1.0
[2.0.0]:https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.6.0...2.0.0


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
