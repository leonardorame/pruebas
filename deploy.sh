#!/bin/sh
# deploy to cpvs
scp cgi/tir cpvs:/home/leonardo/offirad/cgi
scp js/*.js cpvs:/home/leonardo/offirad/js
scp js/controllers/*.js cpvs:/home/leonardo/offirad/js/controllers
scp css/*.css cpvs:/home/leonardo/offirad/css
scp swf/*.swf cpvs:/home/leonardo/offirad/swf
scp html/*.html cpvs:/home/leonardo/offirad/html
scp html/partials/*.html cpvs:/home/leonardo/offirad/html/partials
