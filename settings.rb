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
end

# mysqlの設定
remote_file '/etc/my.cnf' do
  mode '644'
  owner 'root'
  group 'root'
end

# mysqlのルート設定
root_password = node['mysql']['users'][0]['user_password']
execute "password set for root" do
  command "mysql -u root -p#{root_password} -e \"UPDATE mysql.user SET Password=PASSWORD(\'#{root_password}\') WHERE User='root';\""
  not_if "mysql -u root -e \"UPDATE mysql.user SET Password=PASSWORD(\'#{root_password}\') WHERE User='root';\""
end

# mysqlデータベース作成
db_name = node['mysql']['db_name']
execute "create database" do
  command "mysql -u root -p#{root_password} -e \"CREATE DATABASE #{db_name}\""
  not_if "mysql -u root -p#{root_password} -e \"SHOW DATABASES\" | grep #{db_name}"
end

# mysqlユーザ作成
node['mysql']['users'].length.times do |i|
  user_name = node['mysql']['users'][i]['user_name']
  user_password = node['mysql']['users'][i]['user_password']
  
  if user_name == "root" then
    execute "databases setting" do
      command <<-EOL
        mysql -u root -p#{user_password} -e "DELETE FROM mysql.user WHERE User='';"
        mysql -u root -p#{user_password} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');"
        mysql -u root -p#{user_password} -e "DROP DATABASE test;"
        mysql -u root -p#{user_password} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
        mysql -u root -p#{user_password} -e "FLUSH PRIVILEGES;"
      EOL
    end
  else
    execute "create users" do
      command <<-EOL
        mysql -u root -p#{root_password} -e "GRANT ALL ON #{db_name}.* TO \'#{user_name}\'@localhost IDENTIFIED BY \'#{user_password}\';"
      EOL
    end
  end
end