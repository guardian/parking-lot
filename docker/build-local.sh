cd $(dirname $0)
cp ../scripts/setup.sh .
docker build -t="parking-lot" .
