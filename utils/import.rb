# Usage: ruby import.rb
# This script imports the export package created by export.rb
require 'fileutils'
require 'json'

abort "Error: curl not found" unless system("which curl > /dev/null")
config = "/opt/tenejo/current/.env.production"
abort "config file not found: #{config}" unless File.exists?(config)

puts "Extracting"
system("tar -xzf export.tgz")
FileUtils.chown_R("tomcat", "tomcat", "fedora")
fedora_pid = Process.spawn(%Q{curl -X POST -d "#{Dir.pwd}/fedora" "localhost:8080/fedora/rest/fcr:restore"})
dbstuff = Hash[*File.read(config).split.find_all{|x| x=~/^DATABASE_.*/}.map{|x| x.split("=")}.flatten]
system("curl 'http://localhost:8983/solr/tenejo/replication?command=restore&name=tenejo&location=#{Dir.pwd}/solr'")
system("/etc/init.d/redis-server stop")
FileUtils.cp("redis/dump.rdb", "/var/lib/redis/dump.db")
FileUtils.chown("redis", "redis", "/var/lib/redis/dump.db")
system("/etc/init.d/redis-server restart")
system("systemctl stop apache2")
system(%Q{su postgres -c "dropdb --if-exists #{dbstuff['DATABASE_NAME']} && createdb -O db_user #{dbstuff['DATABASE_NAME']} && pg_restore -d #{dbstuff['DATABASE_NAME']} psql/pg.dump"}, exception:true)
system("systemctl start apache2")
system("tar -xzf derivatives/derivatives.tgz -C /opt")
system("tar -xzf derivatives/uploads.tgz -C /opt/uploads")

puts "Waiting for processes to finish"
Process.waitall
FileUtils.rm_rf(%w(solr fedora psql redis derivatives))
FileUtils.rm('export.tgz')
