# == Class: koji::ca
class koji::ca (
  $koji_pki_base = $koji::koji_pki_base,
  $koji_builders = $koji::koji_builders,
) inherits koji {

  validate_absolute_path($koji_pki_base)
  validate_array($koji_builders)

  file {'/etc/pki/koji':
    ensure => 'directory',
    path   => $koji_pki_base,
    owner  => 'root',
    group  => 'koji',
    mode   => '0751',
  }

  file {'/etc/pki/koji/private':
    ensure => 'directory',
    path   => "${koji_pki_base}/private",
    owner  => 'root',
    group  => 'koji',
    mode   => '0750',
  }

  file {'/etc/pki/koji/openssl.cnf':
    ensure  => 'present',
    path    => "${koji_pki_base}/openssl.cnf",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/koji/etc/pki/koji/openssl.cnf',
    require => File['/etc/pki/koji/private'],
  }

  file {'/etc/pki/koji/make_koji_service_cert.sh':
    ensure => 'present',
    path   => "${koji_pki_base}/make_koji_service_cert.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/koji/etc/pki/koji/make_koji_service_cert.sh',
  }

  file {'/etc/pki/koji/make_CA.sh':
    ensure => 'present',
    path   => "${koji_pki_base}/make_CA.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/koji/etc/pki/koji/make_CA.sh',
  }

  file {'/etc/pki/koji/make_default_koji_certs.sh':
    ensure  => 'present',
    path    => "${koji_pki_base}/make_default_koji_certs.sh",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/koji/etc/pki/koji/make_default_koji_certs.sh',
    require => File['/etc/pki/koji/make_CA.sh','/etc/pki/koji/openssl.cnf','/etc/pki/koji/make_koji_service_cert.sh']
  }

  exec {'Make Koji Keys':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "${koji_pki_base}/make_default_koji_certs.sh",
    creates => "${koji_pki_base}/ca_cert.crt",
    require => File['/etc/pki/koji/make_default_koji_certs.sh'],
  }

  ensure_resources('koji::ca::makecert', koji_array_to_hash($koji_builders), { require => Exec['Make Koji Keys'], })

}
