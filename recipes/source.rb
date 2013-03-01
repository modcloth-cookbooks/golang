packages = value_for_platform_family(
  'default' => ['gcc', 'libc6-dev']
)

packages.each do |dev_pkg|
  package dev_pkg
end

version = node['golang']['version']
tarball = "#{Chef::Config[:file_cache_path]}/golang-#{version}.tar.gz"
install_path = "#{node['install_prefix']}/share/go/#{version}"

directory install_path do
  owner 'root'
  group 'root'
  mode 0755
  recursive true

  action :create
end

remote_file tarball do
  source "#{node['golang']['url']}#{version}.src.tar.gz"
  checksum node['golang']['checksum']
  mode 0644
end

bash 'build-and-install-golang' do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOF
    tar -zxvf #{tarball}
    mv go/* #{install_path}
    (cd #{install_path}/src && ./all.bash)
    (cd #{install_path}/bin && ln -s * #{install_prefix}/bin)
  EOF

  not_if do
    ::File.exists?("#{install_prefix}/bin/go") &&
      ::File.symlink?("#{install_prefix}/bin/go") &&
      ::File.mtime("#{install_prefix}/bin/go") > ::File.mtime(tarball)
  end
end
