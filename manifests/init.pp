# Main class that declares SQL, IISDB, and creates an
# instance of the attachDB defined type.
class tse_sqlserver (
  $mount_iso=true,
  $iso='SQLEXPRWT_x64_ENU.exe',
  $iso_drive='Q',
  $source='http://care.dlservice.microsoft.com/dl/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/ExpressAndTools%2064BIT/SQLEXPRWT_x64_ENU.exe',
  $stagingowner='BUILTIN\Administrators',
  $admin_user='vagrant',
  $db_instance='MYINSTANCE',
  $sa_pass='Azure$123',
  $db_name='adventureworks'
) {

  $filename = staging_parse($source, 'filename')
  $installer = "${::staging_windir}\\${module_name}\\${filename}"
  staging::file { $filename:
    source => $source,
  }

  acl { "${::staging_windir}\\${module_name}" :
    permissions => [
      {
        identity => 'Everyone',
        rights => [ 'full' ]
      },
      {
        identity => $stagingowner,
        rights => [ 'full' ]
      },
    ],
    require => Staging::File[$filename],
  }

  $extract = grep(["${installer}"], '.exe')
  if empty($extract) {
    $installsource = $source
  }
  else {
    exec { 'extract':
      command => "${installer} /q",
      creates => chop(chop(chop(chop($installer)))),
      provider => powershell,
      require => Staging::File[$filename],
    }
    $installsource = chop(chop(chop(chop($installer))))
  }

  class { 'tse_sqlserver::sql':
    source => $installsource,
    admin_user => $admin_user,
    db_instance => $db_instance,
    sa_pass => $sa_pass,
    db_name => $dbname,
  }

  contain tse_sqlserver::sql
  tse_sqlserver::attachdb { 'AdventureWorks2012': }
}
