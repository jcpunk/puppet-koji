# == Class: koji::hub
class koji::hub (
  $koji_hub_packages          = $koji::koji_hub_packages,
  $koji_dbserver              = $koji::koji_dbserver,
  $koji_database              = $koji::koji_database,
  $koji_database_owner        = $koji::koji_database_owner,
  $koji_database_password     = $koji::koji_database_password,
  $koji_filesystem_base       = $koji::koji_filesystem_base,
  $koji_hub_active_plugins    = $koji::koji_hub_active_plugins,
  $koji_hub_securebootchannel = $koji::koji_hub_securebootchannel,
) inherits koji {

  validate_string($koji_dbserver)
  validate_string($koji_database)
  validate_string($koji_database_owner)
  validate_string($koji_database_password)
  validate_string($koji_database_password)
  validate_absolute_path($koji_filesystem_base)
  validate_array($koji_hub_packages)
  validate_array($koji_hub_active_plugins)
  validate_string($koji_hub_securebootchannel)

  if $::fqdn == $koji_dbserver {
    $koji_dbserver_real = 'localhost'
  } else {
    $koji_dbserver_real = $koji_dbserver
  }

  include koji::user

  ensure_packages($koji_hub_packages)

  file {'/etc/httpd/conf.d/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    recurse => true,
    source  => 'puppet:///modules/koji/etc/httpd/koji-hub/etc/httpd/conf.d/',
  }

  file {'/etc/httpd/conf.modules.d/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    recurse => true,
    source  => 'puppet:///modules/koji/etc/httpd/koji-hub/etc/httpd/conf.modules.d/',
  }


  class {'koji::hub::scripts':
    koji_filesystem_base => $koji_filesystem_base,
  }

  file {'/etc/exports.d/koji-hub.exports':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('koji/etc/exports.d/export.erb'),
  }

  selboolean {'httpd_anon_write':
    persistent => true,
    value      => 'on',
  }

  selboolean {'httpd_can_network_connect_db':
    persistent => true,
    value      => 'on',
  }

  file {'/etc/koji-hub':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0750',
    require => Package[$koji_hub_packages],
  }

  file {'/etc/koji-hub/hub.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    content => template('koji/etc/koji-hub/hub.conf.erb'),
    notify  => Service['httpd'],
    require => Package[$koji_hub_packages],
  }

  file {'/etc/koji-hub/plugins/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    replace => true,
    notify  => Service['httpd'],
    source  => "puppet:///modules/koji/etc/koji-hub/plugins/${::fqdn}",
    require => Package[$koji_hub_packages],
    recurse => true,
  }

  file {'/usr/lib/koji-hub/plugins/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    replace => true,
    notify  => Service['httpd'],
    source  => "puppet:///modules/koji/usr/lib/koji-hub/plugins/${::fqdn}",
    require => Package[$koji_hub_packages],
    recurse => true,
  }

  file {'/mnt/koji':
    ensure  => 'directory',
    path    => $koji_filesystem_base,
    owner   => 'apache',
    group   => 'apache',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }
  file {'/mnt/koji/packages':
    ensure  => 'directory',
    path    => "${koji_filesystem_base}/packages",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }
  file {'/mnt/koji/repos':
    ensure  => 'directory',
    path    => "${koji_filesystem_base}/repos",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }
  file {'/mnt/koji/scratch':
    ensure  => 'directory',
    path    => "${koji_filesystem_base}/scratch",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }
  file {'/mnt/koji/work':
    ensure  => 'directory',
    path    => "${koji_filesystem_base}/work",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }

  # For now we bundle kojira with the hub
  class {'koji::utils':
    koji_filesystem_base => $koji_filesystem_base,
    koji_utils_packages  => $koji_hub_packages,
  }


}
