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
* FFMpeg and its dependencies
* ImageMagick and its dependencies

## Shibboleth
The repository also contains roles that can be used to build a shibboleth authentication system. `shibboleth-idp` will build a shibboleth identity provider, and `shibboleth-sp` will configure a system to authenticate against shibboleth. In combination with the guide in the [DCE playbook](https://curationexperts.github.io/playbook/), this can be used to configure Hyrax to authenticate against Shibboleth.

## Prerequisites
[Ansible](http://docs.ansible.com/intro_installation.html) 2.4 or above.

## Contributing
Contributions are welcome in the form of issues (including bug reports, use cases) and pull requests.

## Origins
This Ansible project was preceeded by [ansible-hydra](https://github.com/curationexperts/ansible-hydra/blob/master/README.md), a project created by Data Curation Experts for the Chemical Heritage Foundation.
