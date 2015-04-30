class tse_sqlserver::extract (
  $installer,
  $filename,
  $iso_drive,
  ) {

  $extract = grep(["${installer}"], '.exe')
  $iso = grep(["${installer}"], '.iso')

  if empty($iso) == false {
    class { 'tse_sqlserver::mount':
      iso => $filename,
      iso_drive => $iso_drive,
    }
    $installsource = "${iso_drive}:\\"
  }
  elsif empty($extract) {
    $installsource = $source
  }
  else {
    exec { 'extract':
      command => "${installer} /q",
      creates => chop(chop(chop(chop($installer)))),
      provider => powershell,
      cwd      => "${::staging_windir}\\${module_name}",
      require => Staging::File[$filename],
    }
    $installsource = chop(chop(chop(chop($installer))))
  }
}
