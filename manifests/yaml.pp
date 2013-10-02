class trocla::yaml(
  $password_length  = 16
  $random_passwords = true,
  $data_file        = "{$settings::server_datadir}/trocla_data.yaml",
) {

  class{'trocla::config':
    password_length   => $password_length,
    random_passwords  => $random_passwords,
    adapter           => 'YAML',
    adapter_options   => {
      file => $data_file,
    },
  }

  file{$data_file:
    ensure  => file,
    owner   => puppet,
    group   => 0,
    mode    => 0600;
  }
}
