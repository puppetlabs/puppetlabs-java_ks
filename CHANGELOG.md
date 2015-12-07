##Supported Release 1.4.0
###Summary
This release contains a new option to provide destkeypass. Also contains 
bugfixes and a metadata update to support Puppet Enterprise 2015.3.x.

####Features
- Adds `destkeypass` option to pass in password when importing into the keystore.
- Adds feature support for JCEKS format and extensions.

####Bugfixes
- Fixes composite title patterns in provider to improve support for Windows.

####Test Improvements
- Improves Windows testing.

##2015-07-20 - Supported Release 1.3.1
###Summary
This release updates the metadata for the upcoming release of PE as well as an additional bugfix.

####Bugfixes
- Fixes Puppet.newtype deprecation warning

##2015-04-14 - Supported Release 1.3.0
###Summary
Remove openssl command line tool from requirements

####Features
- Add Windows support and tests

##2014-11-11 - Supported Release 1.2.6
###Summary

This release has test fixes and files synced from modulesync.

##2014-07-10 - Supported Release 1.2.5
###Summary

This release has bugfixes and test improvements.

####Features
- Update tests to use RSpec 2.99 syntax

####Bugfixes
- Remove broken support for puppet:// files.
- Remove incorrect statment of windows support from metadata.json.
- Fix path issue for openssl on solaris 11.

####Known Bugs
* No known bugs

##2014-06-04 - Release 1.2.4
###Summary

This is a compatibility release. No functional changes to this module were made
in this release, just testing infrastructure changes to extend tests to RHEL7
and Ubuntu 14.04

####Features

####Bugfixes

####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 1.2.3
###Summary

This is a supported release.  This release removes a testing symlink that can
cause trouble on systems where /var is on a seperate filesystem from the
modulepath.

####Features

####Bugfixes

####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 1.2.2
###Summary

This is a supported release.  Only tests and documentation were changed.

####Features
- Test changes.
- Documentation changes.

####Bugfixes

####Known Bugs
* No known bugs


##2014-02-12 - Release 1.2.1

#### Bugfixes
- Updating specs


##2013-09-18 - Release 1.2.0

### Summary
This release adds `puppet://` URI support, a few bugfixes, and lots of tests.

#### Features
- `puppet://` URI support for the `chain`, `certificate`, and `private_key` parameters

#### Bugfixes
- Validate that keystore passwords are > 6 characters (would silent fail before)
- Fixed corrupted keystore PKCS12 files in some cases.
- More acceptance tests, unit tests, and rspec-puppet tests.


##1.1.0

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

##0.0.6


Fixes an issue with ibm java handling input from stdin on SLES
