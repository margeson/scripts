# Tested on RHEL 7
# This script configures a BINDS DNS server
# It forwards DNS queries for ec2.internal and the VPC CIDR block. 
# It also forwards DNS queries to an on-premise DNS server for their domain and reverse zone.
# The unbound server described by 
# AWS document https://aws.amazon.com/blogs/security/how-to-set-up-dns-resolution-between-on-premises-networks-and-aws-by-using-unbound/ 
# does not support reverse dns
# This provide the same thing with addition to reverse dns

#!/bin/bash
# Set the variables for your environment
vpc_dns=172.17.1.2
vpc_dns_reverse=17.172.in-addr.arpa
onprem_domain=onprem.local
onprem_dns="10.0.0.1; 10.0.0.2;"
onprem_dns_reverse=10.in-addr.arpa


# Install updates and dependencies
yum update -y
yum remove dnsmasq -y
yum install bind bind-utils -y

# Write Unbound configuration file with values from variables
cat << EOF | tee /etc/named.conf
options {
		directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
		forwarders { $vpc_dns; };
		
        recursion yes;
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "ec2.internal" {
    type forward;
    forward only;
    forwarders { $vpc_dns; };
};

zone "$vpc_dns_reverse" {
    type forward;
    forward only;
    forwarders { $vpc_dns; };
};

zone "$onprem_domain" {
    type forward;
    forward only;
    forwarders { $onprem_dns };
};

zone "$onprem_dns_reverse" {
    type forward;
    forward only;
    forwarders { $onprem_dns };
};
EOF

systemctl restart named
systemctl enable named

