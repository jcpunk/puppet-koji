# == Class: koji::params
class koji::params {

  $koji_web_packages        = ['koji-web']
  $koji_builder_packages    = ['mock', 'createrepo_c', 'koji-builder', 'imagefactory', 'imagefactory-plugins', 'pesign', 'oz']
  $koji_hub_packages        = ['koji', 'koji-hub', 'koji-hub-plugins', 'koji-utils', 'hub']
  $koji_secureboot_packages = ['opensc', 'engine_pkcs11', 'pkcs11-helper', 'nss-tools', 'shim', 'pesign']
  $mock_packages            = ['mock']

  $koji_pki_base = '/etc/pki/koji'
  $koji_client_cert = '~/.koji/koji-user-cert.pem'
  $koji_client_ca_cert = "${koji_pki_base}/server_ca_cert.crt"

  $make_local_user = true
  $koji_user = 'koji'
  $koji_group = 'koji'
  $koji_gid = 65300
  $koji_groups = ['mockbuild']
  $koji_uid = 65300
  $koji_user_home = '/home/koji'
  $koji_user_password = '$1$invalid$1hash'

  $mock_dirs = ['/etc/mock', '/var/lib/mock', '/var/cache/mock']
  $mock_builddir = '/var/lib/mock'
  $mock_cachedir = '/var/cache/mock'
  $mock_builduser = 'kojibuilder'
  $mock_buildgroup = 'kojibuilder'
  $mock_vendor = 'VENDOR'
  $mock_packager = 'PACKAGER'
  $mock_distribution = 'DISTRIBUTION'
  $mock_host = 'redhat-linux-gnu'

  $koji_allowed_scms = 'myscm.example.com:/projects/*:false'

  $koji_client_packages = ['koji']

  $koji_hubserver = 'kojihub.example.com'
  $koji_dbserver  = 'kojidb.example.com'
  $koji_webserver = 'kojiweb.example.com'
  if is_array($::content_view_hosts) {
    $koji_builders = $::content_view_hosts
  } else {
    $koji_builders = parseyaml($::content_view_hosts)
  }

  $koji_database          = 'koji'
  $koji_database_owner    = 'koji'
  $koji_database_password = 'koji'
  $koji_database_schema   = '/usr/share/doc/koji*/docs/schema.sql'

  $koji_hub_active_plugins = []
  $koji_secureboot_hosts = ['secureboot-builder.example.com']
  $koji_hub_securebootchannel = 'secure-boot'

  if $::mock_plugin_path {
    $mock_plugin_path = $::mock_plugin_path
  } else {
    $mock_plugin_path = '/usr/lib/python2.7/site-packages/mockbuild/plugins'
  }

  $koji_filesystem_base = '/mnt/koji'
  $koji_web_secret  = 'CHANGEME'
  $koji_ca_cert_url = "http://${koji_webserver}/ca_cert.crt"

  if $::koji_plugin_path {
    $koji_plugin_path = $::koji_plugin_path
  } else {
    $koji_plugin_path = '/usr/lib/koji-hub-plugins'
  }

}
