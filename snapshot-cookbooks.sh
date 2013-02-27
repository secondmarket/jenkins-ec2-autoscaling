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

# Create a bundle of cookbooks needed to build a Jenkins node in Chef Solo
# mode.

gitserver=gitolite@OBFUSCATED

today=`date "+%Y%m%d"`
tmpdir=`mktemp -d /tmp/tmpdir.XXXXXX`

cookbooks='jenkins yum selinux java windows runit apache2 git smpostgresql postgresql builder mongodb openssl phantomjs ark sudo timezone redis'

mkdir $tmpdir/cookbooks
for i in $cookbooks ; do git clone -q $gitserver:chef-cookbooks/$i.git $tmpdir/cookbooks/$i; done
# Use gnutar on Macs rather than Apple tar because it creates resource fork
# nonsense (SCHILY.*) in tarballs
gnutar -C $tmpdir -z -c -f ./chef-cookbooks-$today.tar.gz cookbooks

rm -rf $tmpdir
