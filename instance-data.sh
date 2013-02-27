#!/bin/sh
#
# Author:: Julian C. Dunn (<jdunn@secondmarket.com>)
#
# Copyright (C) 2013, SecondMarket Labs, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# instance-data script to be run by cloud-init on bootup of EC2 machines, in order to create the "Jenkins node golden image"

chef_version="10.24.0"

echo "Starting instance-data run on `date`"

yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install -y ruby ruby-devel gcc gcc-c++ automake autoconf make
yum install -y rubygems

gem install ohai --no-rdoc --no-ri --verbose
gem install chef --no-rdoc --no-ri --verbose --version $chef_version

(
cat <<'EOP'
[secondmarket]
name=SecondMarket RHEL6 Repository - $basearch
baseurl=http://OBFUSCATED
gpgcheck=0
enabled=1
EOP
) > /etc/yum.repos.d/secondmarket.repo

mkdir /etc/chef

(
cat <<'EOP'
file_cache_path "/var/chef-solo/cache"
cookbook_path "/var/chef-solo/cookbooks"
role_path "/var/chef-solo/roles"
EOP
) > /etc/chef/solo.rb

for i in cache cookbooks roles ; do mkdir -p /var/chef-solo/$i ; done

(
cat <<'EOP'
{
  "name": "jenkins-node-solo-role",
  "description": "Jenkins Node Role in Chef Solo mode",
  "default_attributes": {
    "authorization": {
      "sudo": {
        "users": [ "ec2-user", "jenkins-node" ],
        "passwordless": true
        }
    },
    "builder": {
      "gitserver": "OBFUSCATED"
    },
    "java": {
      "install_flavor": "oracle",
      "oracle": {
        "accept_oracle_download_terms": true
      }
    },
    "jenkins": {
      "server": {
        "pubkey": "ssh-rsa OBFUSCATED jenkins-node\n"
      }
    },
    "postgresql": {
      "password": {
        "postgres": "whatevs"
      }
    },
    "tz": "America/New_York"
  },
  "run_list": [
    "recipe[selinux::disabled]",
    "recipe[timezone]",
    "recipe[sudo]",
    "recipe[java]",
    "recipe[jenkins::node_ssh_simple]",
    "recipe[mongodb::standalone]",
    "recipe[smpostgresql::pgdg]",
    "recipe[postgresql::server]",
    "recipe[redis::server]",
    "recipe[builder::agent]"
  ],
  "json_class": "Chef::Role"
}
EOP
) > /var/chef-solo/roles/jenkins-node-solo-role.json

# Run Chef Solo to set up the node!
chef-solo -j http://OBFUSCATED/chef-cookbook-snapshots/jenkins-node-solo-runlist.json -r http://OBFUSCATED/chef-cookbook-snapshots/latest.tar.gz

echo "Finishing instance-data run on `date`"
