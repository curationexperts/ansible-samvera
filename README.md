# ansible-samvera
Prototype Configuration Management Scripts for Samvera based servers

This is an ansible build script optimized for Ubuntu Linux 16.04 LTS (long term support). It will install:

* Hyrax pre-requisites
* solr on port 8983
* fedora on port 8080
* ffmpeg for video transcoding of video derivatives
* imagemagick, ghostscript, and other image libraries for creating image derivatives

## Prerequisites
[Ansible](http://docs.ansible.com/intro_installation.html) 2.0 or above.

## Contributing
Contributions are welcome in the form of issues (including bug reports, use cases) and pull requests.

## Origins
This Ansible project was preceeded by [ansible-hydra](https://github.com/curationexperts/ansible-hydra/blob/master/README.md), a project created by Data Curation Experts for the Chemical Heritage Foundation.
