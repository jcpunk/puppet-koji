# == Class: koji::database
class koji::database (
  $koji_client_packages   = koji::koji_client_packages,
  $koji_database          = koji::koji_database,
  $koji_database_owner    = koji::koji_database_owner,
  $koji_database_password = koji::koji_database_password,
  $koji_database_schema   = koji::koji_database_schema,
  $koji_hubserver         = koji::koji_hubserver,
) inherits koji {

  validate_array($koji_client_packages)
  validate_string($koji_database)
  validate_string($koji_database_owner)
  validate_string($koji_database_password)
  validate_string($koji_hubserver)
  validate_absolute_path($koji_database_schema)

  include koji::user

  ensure_packages($koji_client_packages)

  class { 'postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => false,
  }

  class { 'postgresql::server':
    require => User['koji'],
  }

  postgresql::server::db { $koji_database:
    user     => $koji_database_owner,
    password => postgresql_password($koji_database_owner, $koji_database_password),
    require  => Package[$koji_client_packages]
  }

  postgresql::server::schema {$koji_database_schema:
    db     => $koji_database,
    notify => [ Postgresql_psql['Make koji-admin account'], Postgresql_psql['Make kojira account'] ],
  }

  postgresql::server::pg_hba_rule { "allow ${koji_hubserver} to access koji database":
    description => "Open up PostgreSQL for ${koji_database} for ${koji_hubserver}",
    type        => 'host',
    database    => $koji_database,
    user        => $koji_database_owner,
    address     => koji_hostname_to_cidr($koji_hubserver),
    auth_method => 'md5',
  }

  postgresql::server::pg_hba_rule { 'allow 127.0.0.1 to access koji database':
    description => "Open up PostgreSQL for ${koji_database} for 127.0.0.1",
    type        => 'host',
    database    => $koji_database,
    user        => $koji_database_owner,
    address     => '127.0.0.1/32',
    auth_method => 'md5',
  }

  postgresql_psql {'Make koji-admin account':
    db          => $koji_database,
    command     => 'insert into users (name, status, usertype) values ("koji-admin", 0, 0);',
    refreshonly => true,
    notify      => Postgresql_psql['Grant koji-admin admin role'],
  }
  postgresql_psql {'Grant koji-admin admin role':
    db          => $koji_database,
    command     => 'insert into user_perms (user_id, perm_id, creator_id) select users.id, permissions.id, "1" from users, permissions where users.name in ("koji-admin") and permissions.name = "admin";',
    refreshonly => true,
  }

  postgresql_psql {'Make kojira account':
    db          => $koji_database,
    command     => 'insert into users (name, status, usertype) values ("kojira", 0, 0);',
    refreshonly => true,
    notify      => Postgresql_psql['Grant kojira repo role'],
  }
  postgresql_psql {'Grant kojira repo role':
    db          => $koji_database,
    command     => 'insert into user_perms (user_id, perm_id, creator_id) select users.id, permissions.id, "1" from users, permissions where users.name in ("kojira") and permissions.name = "repo";',
    refreshonly => true,
  }

  exec {'make root bin for koji database':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => 'mkdir -p /root/bin',
    creates => '/root/bin',
    before  => File['/root/bin/backup_database'],
  }

  file {'/root/bin/backup_database':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/koji/root/bin/backup_database',
  }

  file { '/etc/cron.daily/backup_database':
    ensure  => 'link',
    target  => '/root/bin/backup_database',
    require => File['/root/bin/backup_database'],
  }

}
