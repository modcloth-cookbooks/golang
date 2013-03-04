action :create do
  manage_deps(:action => :install)

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
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
      tar -zxvf #{tarball}
      mv go/* #{install_path}
      (cd #{install_path}/src && ./all.bash)
      (cd #{install_path}/bin && ln -s * #{node['install_prefix']}/bin)
    EOF

    not_if do
      ::File.exists?("#{golang_install_bin}/go") &&
        ::File.symlink?("#{golang_install_bin}/go") &&
        ::File.mtime("#{golang_install_bin}/go") > ::File.mtime(tarball)
    end
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  manage_deps(:action => :uninstall)

  Dir["#{install_path}/bin"].each do |f|
    file "#{golang_install_bin}/#{f}" do
      action :delete
    end
  end

  directory install_path do
    recursive true
    action :delete
  end

  file tarball do
    action :delete
  end

  new_resource.updated_by_last_action(true)
end

def manage_deps(opts)
  deps.each do |dev_pkg|
    package dev_pkg do
      action opts[:action]
    end
  end
end

def deps
  value_for_platform_family(
    'default' => ['gcc', 'libc6-dev']
  )
end

def version
  @version ||= new_resource.name
end

def tarball
  @tarball ||= "#{Chef::Config[:file_cache_path]}/golang-#{version}.tar.gz"
end

def install_path
  @install_path ||= "#{node['install_prefix']}/share/go/#{version}"
end

def golang_install_bin
  @golang_install_bin ||= "#{node['install_prefix']}/bin"
end
