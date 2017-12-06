# == Class: koji
class koji (
  $koji_client_packages     = $koji::params::koji_client_packages,
  $koji_web_packages        = $koji::params::koji_web_packages,
  $koji_builder_packages    = $koji::params::koji_builder_packages,
  $koji_hub_packages        = $koji::params::koji_hub_packages,
  $koji_secureboot_packages = $koji::params::koji_secureboot_packages,
  $mock_packages            = $koji::params::mock_packages,

  $koji_pki_base       = $koji::params::koji_pki_base,
  $koji_client_cert    = $koji::params::koji_client_cert,
  $koji_client_ca_cert = $koji::params::koji_client_ca_cert,

  $make_local_user    = $koji::params::make_local_user,
  $koji_user          = $koji::params::koji_user,
  $koji_group         = $koji::params::koji_group,
  $koji_gid           = $koji::params::koji_gid,
  $koji_groups        = $koji::params::koji_groups,
  $koji_uid           = $koji::params::koji_uid,
  $koji_user_home     = $koji::params::koji_user_home,
  $koji_user_password = $koji::params::koji_user_password,

  $mock_dirs         = $koji::params::mock_dirs,
  $mock_builddir     = $koji::params::mock_builddir,
  $mock_cachedir     = $koji::params::mock_cachedir,
  $mock_builduser    = $koji::params::mock_builduser,
  $mock_buildgroup   = $koji::params::mock_buildgroup,
  $mock_vendor       = $koji::params::mock_vendor,
  $mock_packager     = $koji::params::mock_packager,
  $mock_distribution = $koji::params::mock_distribution,
  $mock_host         = $koji::params::mock_host,
  $mock_plugin_path  = $koji::params::mock_plugin_path,

  $koji_allowed_scms = $koji::params::koji_allowed_scms,
  $koji_hubserver    = $koji::params::koji_hubserver,
  $koji_dbserver     = $koji::params::koji_dbserver,
  $koji_webserver    = $koji::params::koji_webserver,
  $koji_builders     = $koji::params::koji_builders,
  $koji_database          = $koji::params::koji_database,
  $koji_database_owner    = $koji::params::koji_database_owner,
  $koji_database_password = $koji::params::koji_database_password,
  $koji_database_schema   = $koji::params::koji_database_schema,

  $koji_hub_active_plugins    = $koji::params::koji_hub_active_plugins,
  $koji_secureboot_hosts      = $koji::params::koji_secureboot_hosts,
  $koji_hub_securebootchannel = $koji::params::koji_hub_securebootchannel,
  $koji_filesystem_base       = $koji::params::koji_filesystem_base,

  $koji_web_secret  = $koji::params::koji_web_secret,
  $koji_ca_cert_url = $koji::params::koji_ca_cert_url,
  $koji_plugin_path = $koji::params::koji_plugin_path,
) inherits koji::params {

  if ($::fqdn in $koji_builders) {
    include koji::builder
  }
  if ($::fqdn == $koji_dbserver) {
    include koji::database
  }
  if ($::fqdn == $koji_hubserver) {
    include koji::hub
  }
  if ($::fqdn == $koji_webserver) {
    include koji::web
  }

  ensure_packages($koji_client_packages)

  file { '/etc/koji.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('koji/etc/koji.conf.erb'),
    require => Package[$koji_client_packages],
  }

  exec {'make pki base for koji client':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "mkdir -p ${koji_pki_base}",
    creates => $koji_pki_base,
    before  => Exec["get koji public key from ${koji_ca_cert_url}"],
  }

  exec {"get koji public key from ${koji_ca_cert_url}":
    command => "curl ${koji_ca_cert_url} > ${koji_client_ca_cert}",
    creates => $koji_client_ca_cert,
  }

  file {$koji_client_ca_cert:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec["get koji public key from ${koji_ca_cert_url}"],
  }

  file {'/etc/pki/tls/certs/koji_ca_cert.crt':
    ensure  => 'link',
    target  => $koji_client_ca_cert,
    require => File['/etc/pki/koji/ca_cert.crt'],
  }

}
