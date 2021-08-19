# Tenejo data export and import
A short write-up for tenejo data export and import

## Steps
* export data 
* first intermission
* scp exported data
* import exported data
* second intermission
* test 

### Export

Connect to the source host via ssh as `ubuntu` user

```
$> ssh -i your_special_key.pem ubuntu@source_host.com
```

Change directories to the application root
```
$> cd /opt
```

Create a new directory called `utils`
```
$> mkdir utils
```

Open a browswer and travel to the `dce-cm ansible-samvera` <a href="https://github.com/curationexperts/ansible-samvera/tree/main/utils" target="blank">github page</a>.

Click the file named `export.rb`. Select and copy all the code.

Return to `/opt/utils` in the terminal. Open a new file called `export.rb`. This action requires elevated privileges.

```
$> sudo vi export.rb
```

Paste the contents of the file you copied from github into this file. Save and exit.

Execute the export script. This also requires elevated privileges.

```
$> sudo ruby export.rb
```

### Intermission

While the export is running, configure ssh keys for export file transfer via `scp`. This involves copying the `id_rsa.pub` to the ubuntu user's `authorized_keys`.

Open another terminal window or tab. Connect to the server that `export.rb` is running on. Expose the contents of the public key file to the terminal

```
$> cat .ssh/id_rsa.pub 
```

Copy the output. It should start with `ssh-rsa`. It may wrap several lines, depending on the format settings of your terminal.

In a new terminal session, connect to the host you want to import the tenejo data to. 

```
$> ssh ubuntu@destination_host.domain.tld
```

Open the `authorized_keys` text file
```
$> vi .ssh/authorized_keys
```
Paste the key data copied from source server into the bottom of this file. Save and exit.

### Secure Copy Exported Data

Reutrn to the terminal where the export has run. A file named `export.tgz` will be left behind once the script has completed. Copy this file to your new server

```
$> scp export.tgz destination_host.domain.tld:~
```
This will copy `export.tgz` to the ubuntu user's home directory on the new host. 

### Import Data

Return to the terminal window of the destination host. Switch to the tenejo application root. Create a `/utils` directory.

```
$> cd /opt
$> sudo mkdir /utils
```

Copy `export.tgz` into this diretory. Sudo required.

```
$> sudo cp ~/export.tgz .
```

Return to the dce-cm/ansible-samvera <a href="https://github.com/curationexperts/ansible-samvera/tree/main/utils" target="blank">github page</a>. Click `import.rb` and copy its contents. Open a new file in `/utils` named `import.rb`. The action requires sudo access.

```
$> sudo vi import.rb
```

Paste the contents of `import.rb` from the github page into this file. Save and exit. Run the import script as sudo. Note that the command takes no arguments.

```
$> sudo ruby import.rb
```

This script will unpack the archived data, move data to where it belongs on its new home, restart needed services, and clean up after itself. 
### Second Intermission

The import script may require ten or more minutes to run. There really is nothing to do at this point until it finishes. Perhaps verify tha the new host has been configured with an elastic ip and / or in dnssimple.

### Test

Open a new browser window. Enter the url of the new destination host. Verify logins and content and performance. 

