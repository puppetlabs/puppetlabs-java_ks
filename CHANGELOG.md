## puppetlabs-java_ks changelog

Release notes for the puppetlabs-java_ks module

---------------------------------------

1.1.0
=====

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

0.0.6
=====

Fixes an issue with ibm java handling input from stdin on SLES
