# 言語設定
remote_file '/etc/sysconfig/i18n' do
  mode '644'
  owner 'root'
  group 'root'
end

# sudo権限をwheelグループに付与
execute "wheel group permission change" do
  command "sudo sed -i 's/^#\s%wheel\tALL=(ALL)\tALL$/%wheel\tALL=(ALL)\tALL/g' /etc/sudoers"
end

# SSHの設定
remote_file '/etc/ssh/sshd_config' do
  mode '600'
  owner 'root'
  group 'root'
end

# yumのアップデート対象を設定
remote_file '/etc/yum.conf' do
  mode '644'
  owner 'root'
  group 'root'
end

# phpの設定
remote_file '/etc/php.ini' do
  mode '644'
  owner 'root'
  group 'root'
  notifies :reload, 'service[httpd]'
end

# mysqlの設定
remote_file '/etc/my.cnf' do
  mode '644'
  owner 'root'
  group 'root'
end
