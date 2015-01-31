#! /bin/bash

BLOG_NAME=$1
BLOG_ADDR=`pwd`

cd $BLOG_ADDR/source/_posts;

rake new_post\["${BLOG_NAME}"\];

open $BLOG_ADDR/source/_posts

NEW_POST_NAME=`ls -t | head -1`
echo $NEW_POST_NAME
#open -a Marked $NEW_POST_NAME
open -a Sublime\ Text\ 2 $NEW_POST_NAME
cd -
