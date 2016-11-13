name             "t3-base"
maintainer       "TYPO3 Association"
maintainer_email "steffen.gebert@typo3.org"
license          "Apache 2.0"
description      "Installs and updates basic software packages deployed to every node."
source_url       "https://github.com/typo3-cookbooks/t3-base"

version          "0.2.54"

recipe "t3-base::default",                  "Includes other recipes, some of them based on ohai detections"
recipe "t3-base::_physical",                "Recipes that we want on physical nodes"
recipe "t3-base::_users",                   "Creates users based on the `users` data bag"
recipe "t3-base::_software",                "Different software that we want o nevery node"
recipe "t3-base::_platform_debian",         "Debian-specific configuration (e.g. LTS repos)"
recipe "t3-base::_platform_family_debian",  "Debian/Ubuntu-specific configuration (e.g. incude `apt`)"
recipe "t3-base::_datacenter",             "Detects, in which data center a node is and applies specific attributes based on the `datacenters` data bag"
recipe "t3-base::_production",             "Configuration that is only needed for production nodes (e.g. backup, monitoring, chef-client config)"

supports         "debian"

# TYPO3 cookbooks (pin to minor version: "~> a.b.0")
depends "backuppc",   "~> 1.0.0"
depends "etckeeper",  "~> 1.0.0"
depends "hwraid",     "~> 1.1.0"
depends "locales",    "~> 1.1.0"
depends "ohmyzsh",    "~> 1.0.0"
depends "t3-chef-client",    "~> 0.4.0"
depends "t3-kvm",     "~> 0.2.0"
depends "t3-openvz",  "~> 1.1.0"
depends "t3-zabbix",  "~> 0.2.0"

# Upstream cookbooks (pin to patch-level version: "= a.b.c")
depends "apt",          "= 2.9.2"
depends "chef_handler", "= 1.0.6"
depends "git",          "= 4.2.4"
depends "logrotate",    "= 1.9.2"
depends "lvm",          "= 1.5.1"
depends "motd",         "= 0.6.4"
depends "ntp",          "= 1.8.6"
depends "openssh",      "= 1.3.4"
depends "postfix",      "= 3.7.0"
depends "rsync",        "= 0.7.0"
depends "screen",       "= 0.7.0"
depends "sudo",         "= 2.6.0"
depends "users",        "= 2.0.3"
