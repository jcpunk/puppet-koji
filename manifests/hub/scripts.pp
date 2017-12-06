# == Class: koji::hub::scripts
class koji::hub::scripts (
  $koji_filesystem_base = $koji::hub::koji_filesystem_base,
  $koji_user            = $koji::koji_user,
  $koji_group           = $koji::koji_group,
  $koji_user_home       = $koji::koji_user_home,
  $make_local_user      = $koji::make_local_user,
) inherits koji::hub {

  validate_absolute_path($koji_filesystem_base)
  validate_string($koji_user)
  validate_string($koji_group)
  validate_absolute_path($koji_user_home)
  validate_bool($make_local_user)

  file {'/root/.koji':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  if $make_local_user {

    file {'/home/koji/README.koji':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0640',
      source => 'puppet:///modules/koji/home/koji/README.koji',
    }

    exec {'make koji bin for koji hub':
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      command => 'mkdir -p /home/koji/bin',
      creates => '/home/koji/bin',
      before  => File['/home/koji/bin/add_koji_user'],
    }

    file {'/home/koji/bin/add_koji_user':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/koji/home/koji/bin/add_koji_user',
    }
    # setup the koji unix user as koji-admin koji user
    file {'/home/koji/.koji/koji-user-cert.pem':
      ensure  => 'link',
      path    => "${koji_user_home}/.koji/koji-user-cert.pem",
      target  => '/etc/pki/koji/pems/koji-admin.pem',
      require => User['koji'],
    }

    file {'/home/koji/koji-data':
      ensure  => 'link',
      path    => "${koji_user_home}/koji-data",
      target  => $koji_filesystem_base,
      require => File['/mnt/koji'],
    }

    file {'/home/koji/cleanup-koji-host':
      ensure => 'file',
      path   => "${koji_user_home}/cleanup-koji-host",
      owner  => $koji_user,
      group  => $koji_group,
      mode   => '0755',
      source => 'puppet:///modules/koji/home/koji/cleanup-koji-host',
    }

    file {'/home/koji/regen-repos':
      ensure => 'file',
      path   => "${koji_user_home}/regen-repos",
      owner  => $koji_user,
      group  => $koji_group,
      mode   => '0755',
      source => 'puppet:///modules/koji/home/koji/regen-repos',
    }

    file {'/etc/cron.d/regen-repos':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      replace => true,
      source  => 'puppet:///modules/koji/etc/cron.d/regen-repos',
      require => File['/home/koji/regen-repos'],
    }
  }

}
