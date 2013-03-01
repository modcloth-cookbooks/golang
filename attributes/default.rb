default['app']['name'] = 'undefined'
default['app']['gid'] = 1337
default['install_prefix'] = (
  {
    'solaris2' => '/opt/local',
    'smartos' => '/opt/local'
  }.fetch(node['platform'], '/usr/local')
)
default['golang'] = (
  {
    'version' => '1.0.3',
    'url' => 'https://go.googlecode.com/files/go',
    'checksum' => '1a67293c10d6c06c633c078a7ca67e98c8b58471',
  }
)
