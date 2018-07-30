# ansible-samvera
Prototype Configuration Management Scripts for Samvera based servers

This repository provides predefined ansible roles to install and configure a typical set of dependencies 
required to run a Hyrax-based repository, including:

* Solr
* Fedora
* Postgres SQL
* Apache webserver
* Ruby
* FITS
* FFMpeg and it's dependencies
* ImageMagick and it's dependencies

## Prerequisites
Tested with [Ansible](http://docs.ansible.com/intro_installation.html) 2.5.4. Please note that ansible is *very* picky about version numbers. You will get better results if you use pip to install ansible. To upgrade do: `pip install ansible==2.5.4`

## Contributing
Contributions are welcome in the form of issues (including bug reports, use cases) and pull requests.

## Origins
This Ansible project was preceeded by [ansible-hydra](https://github.com/curationexperts/ansible-hydra/blob/master/README.md), a project created by Data Curation Experts for the Chemical Heritage Foundation.

## Usage
Here is an example playbook that uses these roles (plus a few extra internal-to-dce roles) to build a single box running all the Samvera components:
```
- hosts: '{{ host }}'
  name: ensure python is installed for ansible
  user: ubuntu
  gather_facts: false
  pre_tasks:
      - name: update apt-get
        raw: sudo apt-get update
      - name: install python for ansible
        raw: sudo apt-get -y install python-simplejson

- hosts: '{{ host }}'
  name: configure server
  user: ubuntu
  gather_facts: true
  vars:
    keys_to_add:
      - https://github.com/user1.keys
      - https://github.com/user2.keys
    db_user: 'db_user'
    db_pass: 'whatever'
    postgres_pass: 'whatever'
  roles:
    - { role: packages }
    - { role: capybara-webkit }
    - { role: set_timezone, timezone: America/Chicago }
    - { role: set_hostname, hostname: stage-demo }
    - { role: sshd_config }
    - { role: setup_logrotation }
    - { role: clamav }
    - { role: nrpe, nrpe_version: '3.1.1', nagios_plugins_version: '2.2.1' }
    - { role: ruby, ruby_version: '2.4.2', ruby_sha_256: '93b9e75e00b262bc4def6b26b7ae8717efc252c47154abb7392e54357e6c8c9c' }
    - { role: postgres }
    - { role: fedora, fedora_version: '4.7.5' }
    - { role: solr, solr_version: '6.6.2' }
    - { role: pip }
    - { role: fits, fits_version: '0.8.4' }
    - { role: apache, passenger_ver: '5.1.11'}
    - { role: apache_with_mod_ssl }
    - { role: capistrano_setup }
    - { role: dotenv, hostname: stage-demo }
    - { role: sidekiq }
    - { role: imagemagick, imagemagick_ver: '7.0.7', gs_ver: '9.19', openjpg_ver: '2.1.0', libtiff_ver: '4.0.5', libpng_ver: '1.6.28' }
    - { role: ffmpeg, ffmpeg_version: '3.4' }
    - { role: solr-schema }
    - { role: first_deploy }
    - { role: dce_ssl }
    - { role: force_ssl }
    - { role: restart }
    - { role: splunkuforwarder }
```
