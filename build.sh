#!/bin/bash
protocol='https'
domain='blog.moroz.cc'
siteurl="$protocol://$domain"
rm -rf docs
mkdir docs
echo -n $domain >> docs/CNAME
hugo --config config.yaml -b $siteurl -d ./docs --gc -v
