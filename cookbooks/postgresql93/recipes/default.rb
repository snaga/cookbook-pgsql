#
# Cookbook Name:: postgresql93
# Recipe:: default
#
# Copyright 2013, Uptime Technologies, LLC.
#
# All rights reserved - Do Not Redistribute
#
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

template "postgresql.conf" do
  path "/var/lib/pgsql/9.3/data/postgresql.conf"
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
#  notifies :reload, 'service[postgresql-9.3]'
end

