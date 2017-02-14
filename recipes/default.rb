
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

#Normally I would nest the "if not" or convert to boolen for simple "if then", but could not find docs for next 3 operations

#download the file
remote_file 'tmp/apache-tomcat-8.0.33.tar.gz' do
	source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.tar.gz'
	not_if '/opt/tomcat/bin/version.sh | grep "Apache Tomcat/8.0.33"'
end

# create the directory
directory 'opt/tomcat' do
	action :create
	recursive true
	not_if '/opt/tomcat/bin/version.sh | grep "Apache Tomcat/8.0.33"'
end

#extract the file - only if the version is not 8.0.33
execute 'extract_tomcat' do
	command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
	cwd '/tmp'
	not_if '/opt/tomcat/bin/version.sh | grep "Apache Tomcat/8.0.33"'
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



#Setup Guard statement to test tomcat-users.xml to allow for admin user access to admn roles in GUI
template '/opt/tomcat/conf/tomcat-users.xml' do
	source 'tomcat-users.xml.erb'	
	not_if 'grep "###-chef-auto-install-###" /opt/tomcat/conf/tomcat-users.xml'
end



#Setup Tomcat Service

# Get Service file template from Chef template repository
template 'etc/systemd/system/tomcat.service' do
	source 'tomcat.service.erb'
end


# reload deamons
execute 'systemctl daemon-reload'

# add tomcat service
service 'tomcat' do
	action [:start, :enable]
end








