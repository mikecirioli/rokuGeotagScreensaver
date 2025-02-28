# rokuGeotagScreensaver
docker run -dit --name my-apache-app -p 8888:80 -v /export/git/rokuGeotagScreensaver/images:/usr/local/apache2/htdocs/ httpd:2.4
docker run -dit --name my-apache-app -p 8888:80 -v /export/images:/usr/local/apache2/htdocs/ httpd:2.4
