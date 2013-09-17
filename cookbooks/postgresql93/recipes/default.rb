#
# Cookbook Name:: postgresql93
# Recipe:: default
#
# Copyright 2013, Uptime Technologies, LLC.
#
# All rights reserved - Do Not Redistribute
#
template "iptables" do
  path "/etc/sysconfig/iptables"
  source "iptables.erb"
  owner "root"
  group "root"
  mode 0600
  notifies :restart, 'service[iptables]'
end

service "iptables" do
  supports :status => true , :restart => true , :reload => false
  action [ :enable, :start ]
end

cookbook_file "/tmp/pgdg-redhat93-9.3-1.noarch.rpm" do
  mode 00644
  checksum "52697bf42907b503faeaea199959bc711a493f4ed67d5f4c9ecf8a9066611c49"
end

package "pgdg-redhat93" do
action :install
  source "/tmp/pgdg-redhat93-9.3-1.noarch.rpm"
end

%w{postgresql93 postgresql93-contrib postgresql93-libs postgresql93-server postgresql93-devel}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "postgresql93-initdb" do
  not_if { File.exists?("/var/lib/pgsql/9.3/data/PG_VERSION") }
  code <<-EOC
    sudo -u postgres /usr/pgsql-9.3/bin/initdb -D /var/lib/pgsql/9.3/data --no-locale -E UTF-8 -k
  EOC
end

template "postgresql-9.3" do
  path "/etc/sysconfig/pgsql/postgresql-9.3"
  source "postgresql-9.3.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, 'service[postgresql-9.3]'
end

template "postgresql.conf" do
  path "/var/lib/pgsql/9.3/data/postgresql.conf"
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, 'service[postgresql-9.3]'
end

template "pg_hba.conf" do
  path "/var/lib/pgsql/9.3/data/pg_hba.conf"
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, 'service[postgresql-9.3]'
end

bash "postgresql93-password" do
  only_if { File.exists?("/var/lib/pgsql/9.3/data/PG_VERSION") }
  password = node['postgresql93']['password']
  code <<-EOC
    sudo -u postgres /usr/pgsql-9.3/bin/psql -U postgres -c "alter user postgres with unencrypted password '#{password}'" postgres
  EOC
end

service "postgresql-9.3" do
  supports :status => true , :restart => true , :reload => true
  action [ :enable, :start ]
end

