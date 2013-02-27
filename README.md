Autoscaling Jenkins with the EC2 Plugin
=======================================

Scripts and tools used to build Jenkins slave AMIs for autoscaling with the Jenkins EC2 plugin.

Note that these aren't the exact scripts we use; I've obfuscated some of the server names for security reasons.

Usage
=====

Snapshot your cookbooks using the `snapshot-cookbooks.sh` script. Put the tarball somewhere that the node can access them.

Start a new node in Amazon EC2, using the instance-data script. For example:

    % ec2-run-instances -f instance-data.sh -g whatever -k some-key -t m1.small ami-XXXXXXXX

You can then use `ec2-describe-instances` to find the hostname of this node and log into it; the instance data output will be in `/var/log/cloud-init.log`

Once satisfied, create a new AMI from the build box:

    % ec2-create-image -n "jenkins-node-image-20130226" i-XXXXXXXX

Don't forget to kill off the build node after you're done.

    % ec2-terminate-instances i-XXXXXXXX
