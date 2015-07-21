SRC=$(cd $(dirname "$0"); pwd)
docker run -t -v $SRC/../sites:/etc/apache2/sites-enabled -p 18080:80 parking-lot
