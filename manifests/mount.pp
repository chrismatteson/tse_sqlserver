# This class is used to mount an ISO containing the SQL Server 2014 Code.
class tse_sqlserver::mount (
  $iso,
  $iso_drive,
) {

  $iso_path = "${::staging_windir}\\${module_name}\\${iso}"

  acl { $iso_path :
    permissions => [
      {
        identity => 'Everyone',
        rights   => [ 'full' ]
      },
      {
        identity => $::staging::owner,
        rights   => [ 'full' ]
      },
    ],
    require     => Staging::File[$iso],
    before      => Mount_iso[$iso_path],
  }

  mount_iso { $iso_path :
    drive_letter => $iso_drive,
    before       => Class['tse_sqlserver::sql'],
  }

}
