# == Class: koji::builder
class koji::builder (
  $koji_hubserver           = $koji::koji_hubserver,
  $koji_builder_packages    = $koji::koji_builder_packages,
  $koji_filesystem_base     = $koji::koji_filesystem_base,
  $mock_cachedir            = $koji::mock_cachedir,
  $mock_builddir            = $koji::mock_builddir,
  $mock_builduser           = $koji::mock_builduser,
  $mock_buildgroup          = $koji::mock_buildgroup,
  $mock_vendor              = $koji::mock_vendor,
  $mock_packager            = $koji::mock_packager,
  $mock_distribution        = $koji::mock_distribution,
  $mock_host                = $koji::mock_host,
  $koji_secureboot_hosts    = $koji::koji_secureboot_hosts,
  $koji_secureboot_packages = $koji::koji_secureboot_packages,
) inherits koji {

  validate_string($koji_hubserver)
  validate_array($koji_builder_packages)
  validate_absolute_path($koji_filesystem_base)
  validate_absolute_path($mock_cachedir)
  validate_absolute_path($mock_builddir)
  validate_string($mock_builduser)
  validate_string($mock_buildgroup)
  validate_string($mock_vendor)
  validate_string($mock_packager)
  validate_string($mock_distribution)
  validate_string($mock_host)
  validate_array($koji_secureboot_hosts)
  validate_array($koji_secureboot_packages)

  ensure_packages($koji_builder_packages)

  service {'kojid':
    ensure     => 'running',
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => [File[$koji_filesystem_base], Package[$koji_builder_packages], ],
  }

  file { '/etc/kojid/kojid.conf':
    ensure  => present,
    content => template('koji/etc/kojid/kojid.conf.erb'),
    notify  => Service['kojid'],
    require => Package[$koji_builder_packages],
  }

  # make sure /var/lib/mock is set correctly
  file {'/var/lib/mock':
    ensure  => 'directory',
    path    => $mock_builddir,
    owner   => 'root',
    group   => 'mock',
    mode    => '2775',
    require => Package[$koji_builder_packages],
  }

  # make sure /var/cache/mock is set correctly
  file {'/var/cache/mock':
    ensure  => 'directory',
    path    => $mock_cachedir,
    owner   => 'root',
    group   => 'mock',
    mode    => '2775',
    require => Package[$koji_builder_packages],
  }

  file {$::mock_plugin_path:
    source  => "puppet:///modules/koji/mockbuild/plugins/${::content_view}",
    recurse => true,
    require => Package[$koji_builder_packages],
  }

  augeas{ 'setup libvirt for kojid':
    context => '/files/etc/libvirt/libvirtd.conf',
    changes => [
                'set auth_unix_rw none',
                'set unix_sock_group mock',
                'set unix_sock_rw_perms 0770',],
  }

  # Oz lense isn't always on the host, avahi is the same syntax
  augeas{ 'setup oz for better defaults':
    context => '/files/etc/oz/oz.cfg',
    lens    => 'Avahi.lns',
    changes => [
                'set libvirt/cpus 2',
                'set libvirt/memory 4096',],
  }


  if ($::fqdn in $koji_secureboot_hosts) {
    ensure_packages($koji_secureboot_packages)

    service {'pesign':
      ensure     => 'running',
      hasrestart => true,
      hasstatus  => true,
      enable     => true,
      require    => Package[$koji_builder_packages],
    }

    file {'/etc/pesign/groups':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "${mock_buildgroup}
",
      notify  => Service['pesign'],
      require => Package[$koji_builder_packages],
    }

  } else {
    service {'pesign':
      ensure  => 'stopped',
      enable  => false,
      require => Package[$koji_builder_packages],
    }

  }


}
