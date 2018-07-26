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
