<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v5.1.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v5.1.1) - 2025-01-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v5.1.0...v5.1.1)

### Fixed

- (CAT-2203) Removing legacy facts [#466](https://github.com/puppetlabs/puppetlabs-java_ks/pull/466) ([amitkarsale](https://github.com/amitkarsale))

## [v5.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v5.1.0) - 2024-11-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v5.0.0...v5.1.0)

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v5.0.0) - 2023-05-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.4.2...v5.0.0)

### Changed

- (CONT-785) Add Support for Puppet 8 / Drop Support for Puppet 6 [#430](https://github.com/puppetlabs/puppetlabs-java_ks/pull/430) ([david22swan](https://github.com/david22swan))

### Added

- (CONT-1008) Add missing Windows 2022 Support [#435](https://github.com/puppetlabs/puppetlabs-java_ks/pull/435) ([david22swan](https://github.com/david22swan))

## [v4.4.2](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.4.2) - 2023-04-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.4.1...v4.4.2)

### Fixed

- (CONT-357) Syntax update [#422](https://github.com/puppetlabs/puppetlabs-java_ks/pull/422) ([LukasAud](https://github.com/LukasAud))

## [v4.4.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.4.1) - 2022-11-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.4.0...v4.4.1)

### Fixed

- (CONT-186) Set `-deststoretype` [#418](https://github.com/puppetlabs/puppetlabs-java_ks/pull/418) ([david22swan](https://github.com/david22swan))
- pdksync - (CONT-189) Remove support for RedHat6 / OracleLinux6 / Scientific6 [#417](https://github.com/puppetlabs/puppetlabs-java_ks/pull/417) ([david22swan](https://github.com/david22swan))
- pdksync - (CONT-130) - Dropping Support for Debian 9 [#414](https://github.com/puppetlabs/puppetlabs-java_ks/pull/414) ([jordanbreen28](https://github.com/jordanbreen28))
- reversed insync set comparison [#412](https://github.com/puppetlabs/puppetlabs-java_ks/pull/412) ([rstuart-indue](https://github.com/rstuart-indue))

## [v4.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.4.0) - 2022-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.3.1...v4.4.0)

### Added

- pdksync - (GH-cat-11) Certify Support for Ubuntu 22.04 [#408](https://github.com/puppetlabs/puppetlabs-java_ks/pull/408) ([david22swan](https://github.com/david22swan))
- pdksync - (GH-cat-12) Add Support for Redhat 9 [#404](https://github.com/puppetlabs/puppetlabs-java_ks/pull/404) ([david22swan](https://github.com/david22swan))

### Fixed

- (MAINT) Drop support for Solaris 10, Windows Server 2008 R2 and Windows 7+8.1 [#410](https://github.com/puppetlabs/puppetlabs-java_ks/pull/410) ([jordanbreen28](https://github.com/jordanbreen28))

## [v4.3.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.3.1) - 2022-05-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.3.0...v4.3.1)

### Fixed

- Don't require certificate or private key params when ensure: absent [#399](https://github.com/puppetlabs/puppetlabs-java_ks/pull/399) ([tparkercbn](https://github.com/tparkercbn))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.3.0) - 2022-04-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.2.0...v4.3.0)

### Added

- Add support for certificate_content and private_key_content parameters [#385](https://github.com/puppetlabs/puppetlabs-java_ks/pull/385) ([hajee](https://github.com/hajee))
- pdksync - (IAC-1753) - Add Support for AlmaLinux 8 [#381](https://github.com/puppetlabs/puppetlabs-java_ks/pull/381) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1751) - Add Support for Rocky 8 [#380](https://github.com/puppetlabs/puppetlabs-java_ks/pull/380) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - (GH-iac-334) Remove Support for Ubuntu 14.04/16.04 [#390](https://github.com/puppetlabs/puppetlabs-java_ks/pull/390) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1787) Remove Support for CentOS 6 [#384](https://github.com/puppetlabs/puppetlabs-java_ks/pull/384) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1598) - Remove Support for Debian 8 [#379](https://github.com/puppetlabs/puppetlabs-java_ks/pull/379) ([david22swan](https://github.com/david22swan))
- Fix "password" as Property [#378](https://github.com/puppetlabs/puppetlabs-java_ks/pull/378) ([cocker-cc](https://github.com/cocker-cc))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.2.0) - 2021-08-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.1.0...v4.2.0)

### Added

- pdksync - (IAC-1709) - Add Support for Debian 11 [#376](https://github.com/puppetlabs/puppetlabs-java_ks/pull/376) ([david22swan](https://github.com/david22swan))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.1.0) - 2021-06-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v4.0.0...v4.1.0)

### Added

- Accept Datatype Sensitive for Secrets [#373](https://github.com/puppetlabs/puppetlabs-java_ks/pull/373) ([cocker-cc](https://github.com/cocker-cc))

### Fixed

- Fix fingerprint comparison [#372](https://github.com/puppetlabs/puppetlabs-java_ks/pull/372) ([kdehairy](https://github.com/kdehairy))
- (MODULES-11067) Fix keytool output parsing [#370](https://github.com/puppetlabs/puppetlabs-java_ks/pull/370) ([durist](https://github.com/durist))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v4.0.0) - 2021-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.4.0...v4.0.0)

### Changed

- pdksync - (MAINT) Remove SLES 11 support [#354](https://github.com/puppetlabs/puppetlabs-java_ks/pull/354) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - (MAINT) Remove RHEL 5 family support [#353](https://github.com/puppetlabs/puppetlabs-java_ks/pull/353) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#351](https://github.com/puppetlabs/puppetlabs-java_ks/pull/351) ([carabasdaniel](https://github.com/carabasdaniel))

### Fixed

- Fix keytool path handling [#349](https://github.com/puppetlabs/puppetlabs-java_ks/pull/349) ([chillinger](https://github.com/chillinger))

## [v3.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.4.0) - 2020-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.3.0...v3.4.0)

## [v3.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.3.0) - 2020-12-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.2.0...v3.3.0)

### Added

- pdksync - (feat) Add support for Puppet 7 [#342](https://github.com/puppetlabs/puppetlabs-java_ks/pull/342) ([daianamezdrea](https://github.com/daianamezdrea))
- (IAC-994) Removal of inappropriate terminology [#335](https://github.com/puppetlabs/puppetlabs-java_ks/pull/335) ([pmcmaw](https://github.com/pmcmaw))
- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#327](https://github.com/puppetlabs/puppetlabs-java_ks/pull/327) ([david22swan](https://github.com/david22swan))

### Fixed

- Change latest/current comparison to account for chains [#336](https://github.com/puppetlabs/puppetlabs-java_ks/pull/336) ([mwpower](https://github.com/mwpower))
- add storetype parameter comparison to 'destroy' method [#333](https://github.com/puppetlabs/puppetlabs-java_ks/pull/333) ([mwpower](https://github.com/mwpower))
- Correct jceks symbol comparison [#332](https://github.com/puppetlabs/puppetlabs-java_ks/pull/332) ([mwpower](https://github.com/mwpower))

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.2.0) - 2020-07-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.1.0...v3.2.0)

### Added

- Allow DER formatted certificates with keys. [#319](https://github.com/puppetlabs/puppetlabs-java_ks/pull/319) ([tomkitchen](https://github.com/tomkitchen))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.1.0) - 2019-12-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/v3.0.0...v3.1.0)

### Added

- (FM-8224) - Addition of support for CentOS 8 [#294](https://github.com/puppetlabs/puppetlabs-java_ks/pull/294) ([david22swan](https://github.com/david22swan))
- (feat) adding litmus support [#292](https://github.com/puppetlabs/puppetlabs-java_ks/pull/292) ([tphoney](https://github.com/tphoney))
- pdksync - "Add support on Debian10" [#288](https://github.com/puppetlabs/puppetlabs-java_ks/pull/288) ([lionce](https://github.com/lionce))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/v3.0.0) - 2019-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.4.0...v3.0.0)

### Changed

- pdksync - (MODULES-8444) - Raise lower Puppet bound [#276](https://github.com/puppetlabs/puppetlabs-java_ks/pull/276) ([david22swan](https://github.com/david22swan))

### Added

- (FM-8155) Add Window Server 2019 support [#281](https://github.com/puppetlabs/puppetlabs-java_ks/pull/281) ([eimlav](https://github.com/eimlav))
- (FM-8042) Add RedHat 8 support [#280](https://github.com/puppetlabs/puppetlabs-java_ks/pull/280) ([eimlav](https://github.com/eimlav))
- Add initial support for DSA private keys. [#273](https://github.com/puppetlabs/puppetlabs-java_ks/pull/273) ([surcouf](https://github.com/surcouf))

### Fixed

- FM-7945 stringify java_ks [#279](https://github.com/puppetlabs/puppetlabs-java_ks/pull/279) ([lionce](https://github.com/lionce))
- Modules 8962 - java_ks - Windows 2012 failing smoke [#278](https://github.com/puppetlabs/puppetlabs-java_ks/pull/278) ([lionce](https://github.com/lionce))

## [2.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.4.0) - 2019-02-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.3.0...2.4.0)

### Added

- (MODULES-8146) - Add SLES 15 support [#255](https://github.com/puppetlabs/puppetlabs-java_ks/pull/255) ([eimlav](https://github.com/eimlav))

### Fixed

- (MODULES-8549) - Bump of Java version used for test [#260](https://github.com/puppetlabs/puppetlabs-java_ks/pull/260) ([david22swan](https://github.com/david22swan))
- pdksync - (FM-7655) Fix rubygems-update for ruby < 2.3 [#257](https://github.com/puppetlabs/puppetlabs-java_ks/pull/257) ([tphoney](https://github.com/tphoney))
- Fix provider so "latest" gets the MD5 AND SHA1 hashes for comparing [#252](https://github.com/puppetlabs/puppetlabs-java_ks/pull/252) ([absltkaos](https://github.com/absltkaos))
- (FM-7505) - Bumping Windows jdk version to 8.0.191 [#251](https://github.com/puppetlabs/puppetlabs-java_ks/pull/251) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-8125) Fix unnecessary change when using intermediate certificates [#250](https://github.com/puppetlabs/puppetlabs-java_ks/pull/250) ([johngmyers](https://github.com/johngmyers))

## [2.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.3.0) - 2018-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.2.0...2.3.0)

### Changed

- [FM-6966] Removal of unsupported OS from java_ks [#230](https://github.com/puppetlabs/puppetlabs-java_ks/pull/230) ([david22swan](https://github.com/david22swan))

### Added

- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#246](https://github.com/puppetlabs/puppetlabs-java_ks/pull/246) ([tphoney](https://github.com/tphoney))
- (FM-7238) - Addition of support for Ubuntu 18.04 [#237](https://github.com/puppetlabs/puppetlabs-java_ks/pull/237) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-7632) - Update README Limitations section [#239](https://github.com/puppetlabs/puppetlabs-java_ks/pull/239) ([eimlav](https://github.com/eimlav))
- (MODULES-1997) - Update the target when the cert chain changes [#233](https://github.com/puppetlabs/puppetlabs-java_ks/pull/233) ([johngmyers](https://github.com/johngmyers))
- (MODULES-6342) Update pathing for new java in #229 [#231](https://github.com/puppetlabs/puppetlabs-java_ks/pull/231) ([hunner](https://github.com/hunner))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.2.0) - 2018-03-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.1.0...2.2.0)

### Other

- Release Prep 2.2.0 [#224](https://github.com/puppetlabs/puppetlabs-java_ks/pull/224) ([HelenCampbell](https://github.com/HelenCampbell))
- Add support for 'destkeypass' when importing PKCS12 keystores. [#221](https://github.com/puppetlabs/puppetlabs-java_ks/pull/221) ([fatmcgav](https://github.com/fatmcgav))
- Release merge back 2.1.0 [#219](https://github.com/puppetlabs/puppetlabs-java_ks/pull/219) ([pmcmaw](https://github.com/pmcmaw))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.1.0) - 2018-02-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/2.0.0...2.1.0)

### Other

- 2.1.0PreRelease [#217](https://github.com/puppetlabs/puppetlabs-java_ks/pull/217) ([david22swan](https://github.com/david22swan))
- Update JDK to 8u161 [#215](https://github.com/puppetlabs/puppetlabs-java_ks/pull/215) ([HelenCampbell](https://github.com/HelenCampbell))
- 'Latest' method updated to mirror 'Current' method. Code shared by both extracted into it's own method. [#214](https://github.com/puppetlabs/puppetlabs-java_ks/pull/214) ([david22swan](https://github.com/david22swan))
- Rubocop Implemented [#212](https://github.com/puppetlabs/puppetlabs-java_ks/pull/212) ([david22swan](https://github.com/david22swan))
- (maint) modulesync 65530a4 Update Travis [#211](https://github.com/puppetlabs/puppetlabs-java_ks/pull/211) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) modulesync cd884db Remove AppVeyor OpenSSL update on Ruby 2.4 [#210](https://github.com/puppetlabs/puppetlabs-java_ks/pull/210) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (maint) - modulesync 384f4c1 [#209](https://github.com/puppetlabs/puppetlabs-java_ks/pull/209) ([tphoney](https://github.com/tphoney))
- Merge back to master [#208](https://github.com/puppetlabs/puppetlabs-java_ks/pull/208) ([tphoney](https://github.com/tphoney))
- Add support for specifying a source cert alias [#205](https://github.com/puppetlabs/puppetlabs-java_ks/pull/205) ([fatmcgav](https://github.com/fatmcgav))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/2.0.0) - 2017-12-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.6.0...2.0.0)

### Changed

- (MODULES-5814) - Removing Windows 8 [#197](https://github.com/puppetlabs/puppetlabs-java_ks/pull/197) ([pmcmaw](https://github.com/pmcmaw))

### Added

- Add Java 9 support [#195](https://github.com/puppetlabs/puppetlabs-java_ks/pull/195) ([SndR85](https://github.com/SndR85))
- support removal of keystore file if password incorrect [#151](https://github.com/puppetlabs/puppetlabs-java_ks/pull/151) ([jessereynolds](https://github.com/jessereynolds))

### Fixed

- (FM-6457) Fix Windows CI [#200](https://github.com/puppetlabs/puppetlabs-java_ks/pull/200) ([michaeltlombardi](https://github.com/michaeltlombardi))

### Other

- (FM-6588) - Remove vulnerable puppet3 support dependencies (modulesync  e6d4a7d) [#207](https://github.com/puppetlabs/puppetlabs-java_ks/pull/207) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-6161) - Release Prep for 2.0.0 [#206](https://github.com/puppetlabs/puppetlabs-java_ks/pull/206) ([pmcmaw](https://github.com/pmcmaw))
- (maint) - modulesync 1d81b6a [#204](https://github.com/puppetlabs/puppetlabs-java_ks/pull/204) ([pmcmaw](https://github.com/pmcmaw))
- (maint) - Updating flag to stop appveyor config from being deleted [#203](https://github.com/puppetlabs/puppetlabs-java_ks/pull/203) ([pmcmaw](https://github.com/pmcmaw))
- Adding appveyor config file [#201](https://github.com/puppetlabs/puppetlabs-java_ks/pull/201) ([pmcmaw](https://github.com/pmcmaw))
- FM-6517 On SLES we do not have pkcs12 installed [#198](https://github.com/puppetlabs/puppetlabs-java_ks/pull/198) ([tphoney](https://github.com/tphoney))
- Update metadata [#196](https://github.com/puppetlabs/puppetlabs-java_ks/pull/196) ([pmcmaw](https://github.com/pmcmaw))
- Rubocop cleanup of java_ks type [#194](https://github.com/puppetlabs/puppetlabs-java_ks/pull/194) ([tphoney](https://github.com/tphoney))
- (maint) modulesync 892c4cf [#193](https://github.com/puppetlabs/puppetlabs-java_ks/pull/193) ([HAIL9000](https://github.com/HAIL9000))
- (MODULES-5501) - Remove unsupported Ubuntu [#191](https://github.com/puppetlabs/puppetlabs-java_ks/pull/191) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-5357) Pin JDK installation pacakge to 8.0.144 [#189](https://github.com/puppetlabs/puppetlabs-java_ks/pull/189) ([glennsarti](https://github.com/glennsarti))
- (maint) modulesync 915cde70e20 [#188](https://github.com/puppetlabs/puppetlabs-java_ks/pull/188) ([glennsarti](https://github.com/glennsarti))
- fix java install on windows in acceptance [#187](https://github.com/puppetlabs/puppetlabs-java_ks/pull/187) ([tphoney](https://github.com/tphoney))
- (MODULES-5187) mysnc puppet 5 and ruby 2.4 [#186](https://github.com/puppetlabs/puppetlabs-java_ks/pull/186) ([eputnam](https://github.com/eputnam))
- (MODULES-5144) Prep for puppet 5 [#184](https://github.com/puppetlabs/puppetlabs-java_ks/pull/184) ([hunner](https://github.com/hunner))
- (MODULES-4833) Update to Puppet version dependancy #puppethack [#183](https://github.com/puppetlabs/puppetlabs-java_ks/pull/183) ([HelenCampbell](https://github.com/HelenCampbell))
- Add support for importing PKCS12 files. [#182](https://github.com/puppetlabs/puppetlabs-java_ks/pull/182) ([fatmcgav](https://github.com/fatmcgav))
- Release mergeback [#181](https://github.com/puppetlabs/puppetlabs-java_ks/pull/181) ([hunner](https://github.com/hunner))

## [1.6.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.6.0) - 2017-05-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.5.0...1.6.0)

### Other

- Fix timing on older rubies [#180](https://github.com/puppetlabs/puppetlabs-java_ks/pull/180) ([hunner](https://github.com/hunner))
- (PE-17635) Wrap keytool in timeout [#179](https://github.com/puppetlabs/puppetlabs-java_ks/pull/179) ([hunner](https://github.com/hunner))
- Release mergeback for 1.5.0 [#178](https://github.com/puppetlabs/puppetlabs-java_ks/pull/178) ([HelenCampbell](https://github.com/HelenCampbell))
- [msync] 786266 Implement puppet-module-gems, a45803 Remove metadata.json from locales config [#177](https://github.com/puppetlabs/puppetlabs-java_ks/pull/177) ([wilson208](https://github.com/wilson208))
- Correct markdown formatting [#175](https://github.com/puppetlabs/puppetlabs-java_ks/pull/175) ([ekohl](https://github.com/ekohl))
- [MODULES-4528] Replace Puppet.version.to_f version comparison from spec_helper.rb [#174](https://github.com/puppetlabs/puppetlabs-java_ks/pull/174) ([wilson208](https://github.com/wilson208))
- [MODULES-4556] Remove PE requirement from metadata.json [#173](https://github.com/puppetlabs/puppetlabs-java_ks/pull/173) ([wilson208](https://github.com/wilson208))

## [1.5.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.5.0) - 2017-03-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.4.1...1.5.0)

### Other

- (docs)[FM-6102] 1.5.0 release docs edit [#171](https://github.com/puppetlabs/puppetlabs-java_ks/pull/171) ([jtappa](https://github.com/jtappa))
- [FM-6102] Release 1.5.0 Prep [#170](https://github.com/puppetlabs/puppetlabs-java_ks/pull/170) ([wilson208](https://github.com/wilson208))
- [MODULES-4505] Fix error: title patterns that use procs are not supported [#169](https://github.com/puppetlabs/puppetlabs-java_ks/pull/169) ([wilson208](https://github.com/wilson208))
- (maint) Change SHA256 fingerprint verification for certificates to SHA1 [#168](https://github.com/puppetlabs/puppetlabs-java_ks/pull/168) ([wilson208](https://github.com/wilson208))
- (MODULES-2495): use password with encrypted private keys [#167](https://github.com/puppetlabs/puppetlabs-java_ks/pull/167) ([tompsett](https://github.com/tompsett))
- (MODULES-4098) Sync the rest of the files [#166](https://github.com/puppetlabs/puppetlabs-java_ks/pull/166) ([hunner](https://github.com/hunner))
- (MODULES-4097) Sync travis.yml [#164](https://github.com/puppetlabs/puppetlabs-java_ks/pull/164) ([hunner](https://github.com/hunner))
- add xenial to metadata [#163](https://github.com/puppetlabs/puppetlabs-java_ks/pull/163) ([eputnam](https://github.com/eputnam))
- Support EC keys [#162](https://github.com/puppetlabs/puppetlabs-java_ks/pull/162) ([antaflos](https://github.com/antaflos))
- (FM-5972) gettext and spec.opts [#161](https://github.com/puppetlabs/puppetlabs-java_ks/pull/161) ([eputnam](https://github.com/eputnam))
- Support for systems running in FIPS mode [#160](https://github.com/puppetlabs/puppetlabs-java_ks/pull/160) ([jstuart](https://github.com/jstuart))
- (MODULES-3631) msync Gemfile for 1.9 frozen strings [#159](https://github.com/puppetlabs/puppetlabs-java_ks/pull/159) ([hunner](https://github.com/hunner))
- (MODULES-3704) Update gemfile template to be identical [#158](https://github.com/puppetlabs/puppetlabs-java_ks/pull/158) ([hunner](https://github.com/hunner))
- mocha version update [#157](https://github.com/puppetlabs/puppetlabs-java_ks/pull/157) ([eputnam](https://github.com/eputnam))
- (MODULES-3983) Update parallel_tests for ruby 2.0.0 [#156](https://github.com/puppetlabs/puppetlabs-java_ks/pull/156) ([pmcmaw](https://github.com/pmcmaw))
- Update modulesync_config [51f469d] [#154](https://github.com/puppetlabs/puppetlabs-java_ks/pull/154) ([DavidS](https://github.com/DavidS))
- Created simple java_ks::config class with create_resources so we can hiera manage configs [#153](https://github.com/puppetlabs/puppetlabs-java_ks/pull/153) ([arthurbarton](https://github.com/arthurbarton))
- Update modulesync_config [a3fe424] [#152](https://github.com/puppetlabs/puppetlabs-java_ks/pull/152) ([DavidS](https://github.com/DavidS))
- (MAINT) Update for modulesync_config 72d19f184 [#150](https://github.com/puppetlabs/puppetlabs-java_ks/pull/150) ([DavidS](https://github.com/DavidS))
- (MODULES-3581) modulesync [067d08a] [#149](https://github.com/puppetlabs/puppetlabs-java_ks/pull/149) ([DavidS](https://github.com/DavidS))
- {maint} modulesync 0794b2c [#148](https://github.com/puppetlabs/puppetlabs-java_ks/pull/148) ([tphoney](https://github.com/tphoney))
- Update to newest modulesync_configs [9ca280f] [#147](https://github.com/puppetlabs/puppetlabs-java_ks/pull/147) ([DavidS](https://github.com/DavidS))
- Mergeback 1.4.x [#146](https://github.com/puppetlabs/puppetlabs-java_ks/pull/146) ([bmjen](https://github.com/bmjen))

## [1.4.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.4.1) - 2016-02-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.4.0...1.4.1)

### Other

- (FM-4046) Update to current msync configs [006831f] [#145](https://github.com/puppetlabs/puppetlabs-java_ks/pull/145) ([DavidS](https://github.com/DavidS))
- 1.4.1 release prep [#144](https://github.com/puppetlabs/puppetlabs-java_ks/pull/144) ([tphoney](https://github.com/tphoney))
- (MODULES-3023) Support certificate chains in certificate file. [#143](https://github.com/puppetlabs/puppetlabs-java_ks/pull/143) ([johngmyers](https://github.com/johngmyers))
- (FM-4049) update to modulesync_configs [#142](https://github.com/puppetlabs/puppetlabs-java_ks/pull/142) ([DavidS](https://github.com/DavidS))
- Support multiple intermediate certs in chain [#141](https://github.com/puppetlabs/puppetlabs-java_ks/pull/141) ([johngmyers](https://github.com/johngmyers))
- (#2915) Don't expose keystore content when keystore initally empty [#140](https://github.com/puppetlabs/puppetlabs-java_ks/pull/140) ([johngmyers](https://github.com/johngmyers))
- 1.4.x mergeback [#139](https://github.com/puppetlabs/puppetlabs-java_ks/pull/139) ([bmjen](https://github.com/bmjen))

## [1.4.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.4.0) - 2015-12-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.3.1...1.4.0)

### Other

- Rebase from master [#138](https://github.com/puppetlabs/puppetlabs-java_ks/pull/138) ([bmjen](https://github.com/bmjen))
- 1.3.x mergeback [#137](https://github.com/puppetlabs/puppetlabs-java_ks/pull/137) ([bmjen](https://github.com/bmjen))
- Fixes metadata.json dependencies. [#136](https://github.com/puppetlabs/puppetlabs-java_ks/pull/136) ([bmjen](https://github.com/bmjen))
- Release prep for 1.4.0. [#135](https://github.com/puppetlabs/puppetlabs-java_ks/pull/135) ([bmjen](https://github.com/bmjen))
- Fix acceptance tests [#133](https://github.com/puppetlabs/puppetlabs-java_ks/pull/133) ([DavidS](https://github.com/DavidS))
- Adding jceks support [#132](https://github.com/puppetlabs/puppetlabs-java_ks/pull/132) ([albac](https://github.com/albac))
- (MODULES-2561) resolve title properly when on windows [#131](https://github.com/puppetlabs/puppetlabs-java_ks/pull/131) ([cyberious](https://github.com/cyberious))
- Implement destkeypass option [#130](https://github.com/puppetlabs/puppetlabs-java_ks/pull/130) ([DavidS](https://github.com/DavidS))
- (maint) Remove ruby requirement for creating certs [#129](https://github.com/puppetlabs/puppetlabs-java_ks/pull/129) ([cyberious](https://github.com/cyberious))
- (maint) Removed setup parameter [#128](https://github.com/puppetlabs/puppetlabs-java_ks/pull/128) ([cyberious](https://github.com/cyberious))

## [1.3.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.3.1) - 2015-07-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.3.0...1.3.1)

### Other

- CHANGELOG and docs cleanup [#127](https://github.com/puppetlabs/puppetlabs-java_ks/pull/127) ([bmjen](https://github.com/bmjen))
- 1.3.1 prep [#126](https://github.com/puppetlabs/puppetlabs-java_ks/pull/126) ([bmjen](https://github.com/bmjen))
- adds pe path to ruby for acceptance tests [#125](https://github.com/puppetlabs/puppetlabs-java_ks/pull/125) ([bmjen](https://github.com/bmjen))
- Add helper to install puppet/pe/puppet-agent [#124](https://github.com/puppetlabs/puppetlabs-java_ks/pull/124) ([hunner](https://github.com/hunner))
- (maint) allow setting PUPPET_VERSION in acceptance [#123](https://github.com/puppetlabs/puppetlabs-java_ks/pull/123) ([justinstoller](https://github.com/justinstoller))
- Updated travisci file to remove allow_failures on Puppet 4 [#122](https://github.com/puppetlabs/puppetlabs-java_ks/pull/122) ([jonnytdevops](https://github.com/jonnytdevops))
- Modulesync updates [#121](https://github.com/puppetlabs/puppetlabs-java_ks/pull/121) ([underscorgan](https://github.com/underscorgan))
- (MODULES-2017) Fix Puppet.newtype deprecation warning [#120](https://github.com/puppetlabs/puppetlabs-java_ks/pull/120) ([roman-mueller](https://github.com/roman-mueller))
- Merge 1.3.x to master [#119](https://github.com/puppetlabs/puppetlabs-java_ks/pull/119) ([underscorgan](https://github.com/underscorgan))

## [1.3.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.3.0) - 2015-04-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.6...1.3.0)

### Other

- FM-2347 Release Prep [#118](https://github.com/puppetlabs/puppetlabs-java_ks/pull/118) ([cyberious](https://github.com/cyberious))
- (BKR-147) add Gemfile setting for BEAKER_VERSION for puppet... [#116](https://github.com/puppetlabs/puppetlabs-java_ks/pull/116) ([anodelman](https://github.com/anodelman))
- Test and future parser updates [#115](https://github.com/puppetlabs/puppetlabs-java_ks/pull/115) ([cmurphy](https://github.com/cmurphy))
- final formatting and wording changes [#114](https://github.com/puppetlabs/puppetlabs-java_ks/pull/114) ([jtappa](https://github.com/jtappa))
- reorganized README, markdown styling, grammar, and descriptions [#113](https://github.com/puppetlabs/puppetlabs-java_ks/pull/113) ([jtappa](https://github.com/jtappa))
- Adding puppet noop support [#112](https://github.com/puppetlabs/puppetlabs-java_ks/pull/112) ([jitran](https://github.com/jitran))
- edits to descriptions of params [#111](https://github.com/puppetlabs/puppetlabs-java_ks/pull/111) ([jtappa](https://github.com/jtappa))
- Pin rspec gems [#110](https://github.com/puppetlabs/puppetlabs-java_ks/pull/110) ([cmurphy](https://github.com/cmurphy))
- Add IntelliJ files to the ignore list [#109](https://github.com/puppetlabs/puppetlabs-java_ks/pull/109) ([cmurphy](https://github.com/cmurphy))
- More spec_helper_acceptance fixes [#108](https://github.com/puppetlabs/puppetlabs-java_ks/pull/108) ([underscorgan](https://github.com/underscorgan))
- Fix spec_helper_acceptance for pe [#107](https://github.com/puppetlabs/puppetlabs-java_ks/pull/107) ([underscorgan](https://github.com/underscorgan))
- Update .travis.yml, Gemfile, Rakefile, and CONTRIBUTING.md [#106](https://github.com/puppetlabs/puppetlabs-java_ks/pull/106) ([cmurphy](https://github.com/cmurphy))
- Update .sync.yml for new Gemfile template [#105](https://github.com/puppetlabs/puppetlabs-java_ks/pull/105) ([cmurphy](https://github.com/cmurphy))
- update README to reflect that java 7 works as of 1.0.0/310b89b [#104](https://github.com/puppetlabs/puppetlabs-java_ks/pull/104) ([rdark](https://github.com/rdark))
- MODULES-618 - fix java_ks when using password_file [#103](https://github.com/puppetlabs/puppetlabs-java_ks/pull/103) ([underscorgan](https://github.com/underscorgan))
- Merge 1.2.x [#102](https://github.com/puppetlabs/puppetlabs-java_ks/pull/102) ([underscorgan](https://github.com/underscorgan))
- Add tests for windows and remove usage of OPENSSL to check MD5 as keytool has that capability [#91](https://github.com/puppetlabs/puppetlabs-java_ks/pull/91) ([cyberious](https://github.com/cyberious))

## [1.2.6](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.6) - 2014-11-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.5...1.2.6)

### Other

- Fix for sles10 [#101](https://github.com/puppetlabs/puppetlabs-java_ks/pull/101) ([underscorgan](https://github.com/underscorgan))
- Fix path for PE [#100](https://github.com/puppetlabs/puppetlabs-java_ks/pull/100) ([underscorgan](https://github.com/underscorgan))
- Fix path for solaris [#99](https://github.com/puppetlabs/puppetlabs-java_ks/pull/99) ([underscorgan](https://github.com/underscorgan))
- Let the java module fail [#98](https://github.com/puppetlabs/puppetlabs-java_ks/pull/98) ([underscorgan](https://github.com/underscorgan))
- I had some rebase fail [#97](https://github.com/puppetlabs/puppetlabs-java_ks/pull/97) ([underscorgan](https://github.com/underscorgan))
- 1.2.6 prep [#96](https://github.com/puppetlabs/puppetlabs-java_ks/pull/96) ([underscorgan](https://github.com/underscorgan))
- 1.2.x rebase master [#95](https://github.com/puppetlabs/puppetlabs-java_ks/pull/95) ([underscorgan](https://github.com/underscorgan))
- Merge 1.2.x into master [#94](https://github.com/puppetlabs/puppetlabs-java_ks/pull/94) ([underscorgan](https://github.com/underscorgan))
- Update PE and OS compatibility info in metadata [#92](https://github.com/puppetlabs/puppetlabs-java_ks/pull/92) ([cmurphy](https://github.com/cmurphy))
- Only install modules on masters during tests [#89](https://github.com/puppetlabs/puppetlabs-java_ks/pull/89) ([cmurphy](https://github.com/cmurphy))
- Fix solaris 10 tests [#88](https://github.com/puppetlabs/puppetlabs-java_ks/pull/88) ([cmurphy](https://github.com/cmurphy))
- Stop depending on puppet certs to test java_ks [#87](https://github.com/puppetlabs/puppetlabs-java_ks/pull/87) ([cmurphy](https://github.com/cmurphy))
- Fix acceptance helper [#86](https://github.com/puppetlabs/puppetlabs-java_ks/pull/86) ([cmurphy](https://github.com/cmurphy))
- Remove puppet_module_install in favor of copy_module_to [#85](https://github.com/puppetlabs/puppetlabs-java_ks/pull/85) ([cyberious](https://github.com/cyberious))
- Update spec_helper for more consistency [#84](https://github.com/puppetlabs/puppetlabs-java_ks/pull/84) ([underscorgan](https://github.com/underscorgan))
- Capture back metadata.json reformating [#81](https://github.com/puppetlabs/puppetlabs-java_ks/pull/81) ([cyberious](https://github.com/cyberious))

## [1.2.5](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.5) - 2014-07-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.4...1.2.5)

### Other

- Remove AIX 5.3 support as we can't test against it. [#80](https://github.com/puppetlabs/puppetlabs-java_ks/pull/80) ([underscorgan](https://github.com/underscorgan))
- 1.2.5 prep. [#79](https://github.com/puppetlabs/puppetlabs-java_ks/pull/79) ([underscorgan](https://github.com/underscorgan))
- Add validate and lint tasks to travis script [#77](https://github.com/puppetlabs/puppetlabs-java_ks/pull/77) ([cmurphy](https://github.com/cmurphy))
- Synchronize .travis.yml [#76](https://github.com/puppetlabs/puppetlabs-java_ks/pull/76) ([cmurphy](https://github.com/cmurphy))
- Start synchronizing module files [#75](https://github.com/puppetlabs/puppetlabs-java_ks/pull/75) ([cmurphy](https://github.com/cmurphy))
- openssl on sol 11 is in /usr/bin [#74](https://github.com/puppetlabs/puppetlabs-java_ks/pull/74) ([hunner](https://github.com/hunner))
- Remove support for puppet:/// files. [#73](https://github.com/puppetlabs/puppetlabs-java_ks/pull/73) ([apenney](https://github.com/apenney))
- Remove windows support. [#72](https://github.com/puppetlabs/puppetlabs-java_ks/pull/72) ([underscorgan](https://github.com/underscorgan))
- Pin rspec ~> 2.99 due to bundle issues [#71](https://github.com/puppetlabs/puppetlabs-java_ks/pull/71) ([hunner](https://github.com/hunner))
- Pin to new beaker-rspec [#70](https://github.com/puppetlabs/puppetlabs-java_ks/pull/70) ([hunner](https://github.com/hunner))
- Rspec pinning [#69](https://github.com/puppetlabs/puppetlabs-java_ks/pull/69) ([underscorgan](https://github.com/underscorgan))
- Merge test [#68](https://github.com/puppetlabs/puppetlabs-java_ks/pull/68) ([underscorgan](https://github.com/underscorgan))
- Rspec3 [#67](https://github.com/puppetlabs/puppetlabs-java_ks/pull/67) ([apenney](https://github.com/apenney))

## [1.2.4](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.4) - 2014-06-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.3...1.2.4)

### Other

- Release 1.2.4 [#64](https://github.com/puppetlabs/puppetlabs-java_ks/pull/64) ([hunner](https://github.com/hunner))
- Add RHEL7 and Ubuntu 14.04. [#62](https://github.com/puppetlabs/puppetlabs-java_ks/pull/62) ([apenney](https://github.com/apenney))
- 12xmerge [#61](https://github.com/puppetlabs/puppetlabs-java_ks/pull/61) ([apenney](https://github.com/apenney))
- Fixing tests. [#60](https://github.com/puppetlabs/puppetlabs-java_ks/pull/60) ([underscorgan](https://github.com/underscorgan))

## [1.2.3](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.3) - 2014-03-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.2...1.2.3)

### Other

- Fix the { location in metadata.json [#57](https://github.com/puppetlabs/puppetlabs-java_ks/pull/57) ([hunner](https://github.com/hunner))
- Add Scientific linux as a supported platform [#56](https://github.com/puppetlabs/puppetlabs-java_ks/pull/56) ([hunner](https://github.com/hunner))
- Prepare a 1.2.3 supported release. [#55](https://github.com/puppetlabs/puppetlabs-java_ks/pull/55) ([apenney](https://github.com/apenney))
- Replace the symlink with the actual file to resolve a PMT issue. [#54](https://github.com/puppetlabs/puppetlabs-java_ks/pull/54) ([apenney](https://github.com/apenney))

## [1.2.2](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.2) - 2014-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.1...1.2.2)

### Other

- Add missing fields back to work around Puppet bug. [#53](https://github.com/puppetlabs/puppetlabs-java_ks/pull/53) ([apenney](https://github.com/apenney))
- Ensure this works in irb. [#52](https://github.com/puppetlabs/puppetlabs-java_ks/pull/52) ([apenney](https://github.com/apenney))
- Prepare supported 1.2.2 release. [#51](https://github.com/puppetlabs/puppetlabs-java_ks/pull/51) ([apenney](https://github.com/apenney))
- Adds "Release Notes/Known Bugs" to Changelog, updates file format to markdown, standardizes the format of previous entries [#50](https://github.com/puppetlabs/puppetlabs-java_ks/pull/50) ([lrnrthr](https://github.com/lrnrthr))
- Prepare metadata for supported modules. [#49](https://github.com/puppetlabs/puppetlabs-java_ks/pull/49) ([apenney](https://github.com/apenney))
- Adding AIX paths for java6 [#48](https://github.com/puppetlabs/puppetlabs-java_ks/pull/48) ([hunner](https://github.com/hunner))
- Make it all work on solaris... [#47](https://github.com/puppetlabs/puppetlabs-java_ks/pull/47) ([hunner](https://github.com/hunner))
- Fix stderr. [#46](https://github.com/puppetlabs/puppetlabs-java_ks/pull/46) ([apenney](https://github.com/apenney))
- Correct the wording here. [#45](https://github.com/puppetlabs/puppetlabs-java_ks/pull/45) ([apenney](https://github.com/apenney))
- Checking the stderr wasn't correct [#44](https://github.com/puppetlabs/puppetlabs-java_ks/pull/44) ([hunner](https://github.com/hunner))
- Switch to operatingsystem instead of osfamily for finer control. [#43](https://github.com/puppetlabs/puppetlabs-java_ks/pull/43) ([apenney](https://github.com/apenney))
- Fix up the tests for the extended platforms. [#42](https://github.com/puppetlabs/puppetlabs-java_ks/pull/42) ([apenney](https://github.com/apenney))
- Missing a ' [#41](https://github.com/puppetlabs/puppetlabs-java_ks/pull/41) ([hunner](https://github.com/hunner))
- Don't assume FOSS paths in java_ks tests [#39](https://github.com/puppetlabs/puppetlabs-java_ks/pull/39) ([justinstoller](https://github.com/justinstoller))
- Release 1.2.1 [#38](https://github.com/puppetlabs/puppetlabs-java_ks/pull/38) ([hunner](https://github.com/hunner))

## [1.2.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.1) - 2014-02-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.2.0...1.2.1)

### Other

- Allow custom gemsource [#37](https://github.com/puppetlabs/puppetlabs-java_ks/pull/37) ([hunner](https://github.com/hunner))
- include puppet-lint in the Gemfile [#36](https://github.com/puppetlabs/puppetlabs-java_ks/pull/36) ([justinstoller](https://github.com/justinstoller))
- Convert rspec-system tests to beaker. [#35](https://github.com/puppetlabs/puppetlabs-java_ks/pull/35) ([apenney](https://github.com/apenney))
- Release 1.2.0 [#30](https://github.com/puppetlabs/puppetlabs-java_ks/pull/30) ([hunner](https://github.com/hunner))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.2.0) - 2013-09-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.1.0...1.2.0)

### Other

- Validate password length [#29](https://github.com/puppetlabs/puppetlabs-java_ks/pull/29) ([hunner](https://github.com/hunner))
- Clean up PKCS12 generation and testing [#28](https://github.com/puppetlabs/puppetlabs-java_ks/pull/28) ([hunner](https://github.com/hunner))
- Add puppet:// type path support for certificate, private_key and chain [#27](https://github.com/puppetlabs/puppetlabs-java_ks/pull/27) ([hunner](https://github.com/hunner))
- Spec tests [#26](https://github.com/puppetlabs/puppetlabs-java_ks/pull/26) ([hunner](https://github.com/hunner))
- Use better `raise` syntax to suppress compatibility warnings. [#25](https://github.com/puppetlabs/puppetlabs-java_ks/pull/25) ([ojacobson](https://github.com/ojacobson))
- Use the openssl pkcs12 '-out' option to write pkcs12 keystore [#10](https://github.com/puppetlabs/puppetlabs-java_ks/pull/10) ([jcraigbrown](https://github.com/jcraigbrown))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.1.0) - 2013-06-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.0.1...1.1.0)

## [1.0.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.0.1) - 2013-06-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/1.0.0...1.0.1)

### Other

- Release 1.1.0 [#24](https://github.com/puppetlabs/puppetlabs-java_ks/pull/24) ([kbarber](https://github.com/kbarber))
- Travis ci support [#23](https://github.com/puppetlabs/puppetlabs-java_ks/pull/23) ([adrienthebo](https://github.com/adrienthebo))
- (maint) refactor keytool provider specs [#22](https://github.com/puppetlabs/puppetlabs-java_ks/pull/22) ([adrienthebo](https://github.com/adrienthebo))
- Add password_file to type [#20](https://github.com/puppetlabs/puppetlabs-java_ks/pull/20) ([raphink](https://github.com/raphink))
- Support for executables outside the system default path [#18](https://github.com/puppetlabs/puppetlabs-java_ks/pull/18) ([fhrbek](https://github.com/fhrbek))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-java_ks/tree/1.0.0) - 2013-02-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.6...1.0.0)

### Other

- 1.0.0 [#17](https://github.com/puppetlabs/puppetlabs-java_ks/pull/17) ([reidmv](https://github.com/reidmv))
- Updated content to conform to README best practices template [#16](https://github.com/puppetlabs/puppetlabs-java_ks/pull/16) ([lrnrthr](https://github.com/lrnrthr))

## [0.0.6](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.6) - 2013-01-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.5...0.0.6)

### Other

- Fix/empty target bug rm [#14](https://github.com/puppetlabs/puppetlabs-java_ks/pull/14) ([reidmv](https://github.com/reidmv))

## [0.0.5](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.5) - 2013-01-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.4...0.0.5)

### Other

- Fix/empty target bug [#13](https://github.com/puppetlabs/puppetlabs-java_ks/pull/13) ([reidmv](https://github.com/reidmv))

## [0.0.4](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.4) - 2013-01-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.3...0.0.4)

### Other

- Add LICENSE file. Update Modulefile to use ASL instead of APL to refer t... [#12](https://github.com/puppetlabs/puppetlabs-java_ks/pull/12) ([haus](https://github.com/haus))
- Allow non-composite title [#9](https://github.com/puppetlabs/puppetlabs-java_ks/pull/9) ([reidmv](https://github.com/reidmv))
- Update Modulefile release number [#8](https://github.com/puppetlabs/puppetlabs-java_ks/pull/8) ([reidmv](https://github.com/reidmv))

## [0.0.3](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.3) - 2012-06-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.2...0.0.3)

### Other

- Adds a chain parameter to the type. [#5](https://github.com/puppetlabs/puppetlabs-java_ks/pull/5) ([ody](https://github.com/ody))

## [0.0.2](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.2) - 2012-05-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/puppetlabs/puppetlabs-java_ks/tree/0.0.1) - 2012-05-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-java_ks/compare/f4aa4057597420c5fada555e5e5c8d9545826593...0.0.1)
