#!/bin/sh
# deploy to risweb
scp cgi/tir risweb:/home/risweb/offirad/cgi
scp js/*.js risweb:/home/risweb/offirad/js
scp js/controllers/*.js risweb:/home/risweb/offirad/js/controllers
scp css/*.css risweb:/home/risweb/offirad/css
scp swf/*.swf risweb:/home/risweb/offirad/swf
scp html/*.html risweb:/home/risweb/offirad/html
scp html/partials/*.html risweb:/home/risweb/offirad/html/partials
