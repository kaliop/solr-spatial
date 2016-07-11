#!/bin/bash

DAY=$((3600 * 24))
NOW=$(date +%s)
MAX=2524607999
START_DATE=$(($NOW - $NOW % $DAY - 20 * DAY))

_cleanContainer() {
    echo "removing Solr container"
    docker stop solr &> /dev/null
    docker rm solr &> /dev/null
}

trap _cleanContainer SIGINT SIGTERM

_cleanContainer
echo "Starting Solr"
docker run -d \
    --name solr \
    -p 8983:8983 \
    -v `pwd`/jts-1.14.jar:/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/jts-1.14.jar \
    solr:alpine

echo "Giving some time for solr to start..."
docker exec -t solr /opt/docker-solr/scripts/wait-for-solr.sh

echo "Solr can be reached on http://localhost:8983/"

echo "Creating core"
docker exec -t --user=solr solr bin/solr create_core -c core &> /dev/null

echo "Creating multivalued geopoint type"
read -r -d '' DATA <<-EOF
{
  "add-field-type" : {
    "name": "vector_2d",
    "class": "solr.SpatialRecursivePrefixTreeFieldType",
    "spatialContextFactory": "org.locationtech.spatial4j.context.jts.JtsSpatialContextFactory",
    "geo": false,
    "distErrPct": 0,
    "maxDistErr": 1,
    "distanceUnits": "degrees",
    "worldBounds": "ENVELOPE(0, $MAX, $MAX, 0)"
  }
}
EOF
curl -H "Content-type: application/json" -d "$DATA" http://localhost:8983/solr/core/schema  -s -o /dev/null

echo "Adding field"
DATA='{
  "add-field":{
    "name": "date_intervals",
    "type": "vector_2d",
    "stored": true,
    "indexed": true,
    "multiValued": true
  }
}'
curl -H "Content-type: application/json" -d "$DATA" http://localhost:8983/solr/core/schema -s -o /dev/null

SHELDON="\"$START_DATE $(($START_DATE + $DAY))\""
PENNY="\"$START_DATE $(($START_DATE + 2 * $DAY))\""
LEONARD="\"$START_DATE $(($STARt_DATE + 3 * $DAY))\""
RAJ="\"$START_DATE $(($START_DATE + 4 * $DAY))\""
HOWARD="\"$START_DATE $(($START_DATE + 5 * $DAY))\""

for i in {1..100}; do
    SHELDON="$SHELDON, \"$(($START_DATE + $i * 3 * $DAY)) $(($START_DATE + (3 * ($i + 1) - 2) * $DAY))\""
    PENNY="$PENNY, \"$(($START_DATE + $i * 4 * $DAY)) $(($START_DATE + (4 * ($i + 1) - 2) * $DAY))\""
    LEONARD="$LEONARD, \"$(($START_DATE + $i * 5 * $DAY)) $(($START_DATE + (5 * ($i + 1) - 2) * $DAY))\""
    RAJ="$RAJ, \"$(($START_DATE + $i * 6 * $DAY)) $(($START_DATE + (6 * ($i + 1) - 2) * $DAY))\""
    HOWARD="$HOWARD, \"$(($START_DATE + $i * 7 * $DAY)) $(($START_DATE + (7 * ($i + 1) - 2) * $DAY))\""
done

SHELDON="{\"id\": \"sheldon\", \"date_intervals\": [ $SHELDON ] }"
PENNY="{\"id\": \"penny\", \"date_intervals\": [ $PENNY ] }"
LEONARD="{\"id\": \"leonard\", \"date_intervals\": [ $LEONARD ] }"
RAJ="{\"id\": \"raj\", \"date_intervals\": [ $RAJ ] }"
HOWARD="{\"id\": \"howard\", \"date_intervals\": [ $HOWARD ] }"

echo "Adding documents"
for who in SHELDON PENNY LEONARD RAJ HOWARD; do
    echo "  $who"
    curl \
        -o /dev/nul -s \
        -H "Content-type: application/json" \
        -d "$(eval "echo \$$who")" http://localhost:8983/solr/core/update/json/docs -o /dev/null -s \
        http://localhost:8983/solr/core/update/json/docs
done
curl http://localhost:8983/solr/core/update?commit=true -o /dev/null -s


echo "



_______________________________________________________________________________

Get who is in now:

    curl http://localhost:8983/solr/core/select?q=*:*&fl=id&fq=date_intervals:\"Intersects(POLYGON((0+$NOW,+$NOW+$NOW,+$NOW+$MAX,+0+$MAX,+0+$NOW)))\"&wt=json&indent=on


"

curl "http://localhost:8983/solr/core/select?q=*:*&fl=id&fq=date_intervals:\"Intersects(POLYGON((0+$NOW,+$NOW+$NOW,+$NOW+$MAX,+0+$MAX,+0+$NOW)))\"&wt=json&indent=on"

echo "

Solr query back-office can be reached on http://localhost:8983/solr/#/core/query

Press Enter to exit and shut Solr down"

read e
_cleanContainer

