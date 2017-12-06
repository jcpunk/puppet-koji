# == Define: koji::ca::makecert
define koji::ca::makecert (
  $host = $name,
  $koji_pki_base = '/etc/pki/koji',
) {

  validate_absolute_path($koji_pki_base)

  exec {"Make Koji cert for ${host}":
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "${koji_pki_base}/make_koji_service_cert.sh ${host}",
    creates => "${koji_pki_base}/certs/${host}.crt"
  }

}

