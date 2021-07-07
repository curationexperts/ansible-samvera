#usage: ruby export.rb

# This script loads credentials from the standard tenejo installation, and does
# not require any processes to be stopped. Derivatives are assumed to live in 
# /opt/uploads and /opt/derivatives. You may need to modify this script if
# the source system is in some way different than expected.
# when running. 
require 'fileutils'
require 'json'

abort "Error: curl not found" unless system("which curl > /dev/null")
config = "/opt/tenejo/current/.env.production"
abort "config file not found: #{config}" unless File.exists?(config)

FileUtils.mkdir_p(%w(solr fedora psql redis derivatives))
FileUtils.chmod(0777, "fedora") # no telling who fedora happens to be running as
FileUtils.chown("postgres","postgres", "./psql")
FileUtils.chown("solr","solr", "./solr")
dbstuff = Hash[*File.read(config).split.find_all{|x| x=~/^DATABASE_.*/}.map{|x| x.split("=")}.flatten]
fedora_pid = Process.spawn("curl -s -X POST -d #{Dir.pwd}/fedora http://localhost:8080/fedora/rest/fcr:backup")
tar_pid = Process.spawn("tar -czf derivatives/derivatives.tgz -C /opt/ derivatives")
uploads_pid = Process.spawn("tar -czf derivatives/uploads.tgz -C /opt/uploads hyrax")
system("su postgres -c 'pg_dump -C -Fc -d #{dbstuff['DATABASE_NAME']} > psql/pg.dump'", exception:true) 
reply=JSON.parse(%x(curl -s 'http://localhost:8983/solr/tenejo/replication?command=backup&location=#{Dir.pwd}/solr&name=tenejo'))
abort "Solr backup failed: #{reply}" unless reply['status']=="OK"

reply = %x/echo "SAVE" | redis-cli/
abort "Redis dump failed #{reply}" unless reply.chomp == "OK"
FileUtils.cp("/var/lib/redis/dump.rdb", "redis/dump.rdb")



puts "Waiting for processes to finish..."
Process.waitall

loop do
  puts "checking solr backup status..."
  reply = JSON.parse(%x(curl -s  http://localhost:8983/solr/tenejo/replication?command=details))
  reply = Hash[*reply['details']['backup']]
  puts reply['status']
  break if reply['status'] == 'success'
  sleep 10
end

puts "Everything looks hunky dory. packaging up..."
abort "Failed to create backup package!" unless system("tar -czf export.tgz solr fedora psql redis derivatives")
puts "done!"
system 'ls -lh export.tgz'
puts 'Cleaning up...'
puts 'Done!'
FileUtils.rm_rf(%w(solr fedora psql redis derivatives))
