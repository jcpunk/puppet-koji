# == Class: koji::user
class koji::user (
  $make_local_user    = $koji::make_local_user,
  $koji_user          = $koji::koji_user,
  $koji_group         = $koji::koji_group,
  $koji_gid           = $koji::koji_gid,
  $koji_groups        = $koji::koji_groups,
  $koji_uid           = $koji::koji_uid,
  $koji_user_home     = $koji::koji_user_home,
  $koji_user_password = $koji::koji_user_password,
  $mock_packages      = $koji::mock_packages,
) inherits koji {

  validate_bool($make_local_user)
  validate_string($koji_user)
  validate_string($koji_group)
  validate_integer($koji_gid)
  validate_array($koji_groups)
  validate_integer($koji_uid)
  validate_absolute_path($koji_user_home)
  validate_string($koji_user_password)
  validate_array($mock_packages)

  ensure_packages($mock_packages)

  if $make_local_user {
    group {'koji':
      ensure => 'present',
      name   => $koji_group,
      gid    => $koji_gid,
    }

    user {'koji':
      ensure   => 'present',
      name     => $koji_user,
      comment  => 'Koji Management Account',
      shell    => '/bin/bash',
      uid      => $koji_uid,
      gid      => $koji_gid,
      groups   => $koji_groups,
      home     => $koji_user_home,
      password => $koji_user_password,
      require  => Package[$mock_packages],
    }

    file {'/home/koji':
      ensure => 'directory',
      path   => $koji_user_home,
      owner  => $koji_user,
      group  => $koji_group,
      mode   => '0750',
    }

    file {'/home/koji/.koji':
      ensure => 'directory',
      path   => "${koji_user_home}/.koji",
      owner  => $koji_user,
      group  => $koji_group,
      mode   => '0700',
    }
  }

}
