# == Class: koji::utils
class koji::utils (
  $koji_filesystem_base = $koji_filesystem_base,
  $koji_utils_packages  = $koji_hub_packages,
) inherits koji {

  validate_absolute_path($koji_filesystem_base)
  validate_absolute_path($koji_utils_packages)

  ensure_packages($koji_utils_packages)

  file {'/etc/kojira/kojira.conf':
    ensure  => present,
    content => template('koji/etc/kojira/kojira.conf.erb'),
    notify  => Service['kojira'],
    require => Package[$koji_utils_packages],
  }

  file {'/etc/koji-shadow/koji-shadow.conf':
    ensure  => present,
    content => template('koji/etc/koji-shadow/koji-shadow.conf.erb'),
    require => Package[koji_utils_packages],
  }

  service {'kojira':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => [ Package[$koji_utils_packages], File['/etc/kojira/kojira.conf'], ],
  }

}
