#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


package 'java-1.7.0-openjdk-devel'

#create required users : user and group chef
group 'chef' do
	action :create
end

user 'chef' do
	group 'chef'
end

#Setup Tomcat Service * orig d/l site mirror.sdunix.com not avaliable

#download the file
remote_file 'tmp/apache-tomcat-8.0.33.tar.gz' do
	source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz'
end

# create the directory
directory 'opt/tomcat' do
	action :create
	recursive true
end

#extract the file
execute 'extrace tomcat' do
	command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
	cwd '/tmp'
end


# Adding execute resources / permissions, needed to chage mod from 0474 to 0777 - tomcat was failing

execute 'chgrp -R chef /opt/tomcat/conf'

directory 'opt/tomcat/conf' do
	group 'chef'
	mode '0777'
end

execute 'chmod g+r conf/*' do
	cwd 'opt/tomcat'
end

# change ownership to chef - updated from tomcat from docs
execute 'chown -R chef webapps/ work/ temp/ logs/ conf/' do
	cwd 'opt/tomcat'
end
