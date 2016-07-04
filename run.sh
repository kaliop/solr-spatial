#!/bin/bash

START_DATE=1451606400
DAY=$((3600 * 24))

docker stop solr 2>/dev/null
docker rm solr 2>/dev/null
docker run --name solr -d -p 8983:8983 solr:alpine

echo "Giving some time for solr to start..."
sleep 10

echo "Solr can be reached on http://localhost:8983/"

echo "Creating our core"
docker exec -t --user=solr solr bin/solr create_core -c core

echo "Creating multivalued geopoint type"
DATA='{
  "add-field-type" : {
    "name": "vector_2d",
    "class": "solr.SpatialRecursivePrefixTreeFieldType",
    "geo": false,
    "distErrPct": 0,
    "maxDistErr": 1,
    "distanceUnits": "degrees",
    "worldBounds": "ENVELOPE(0, 2524607999, 2524607999, 0)",
    "prefixTree": "packedQuad"
  }
}'
echo $DATA

curl -H "Content-type: application/json" -d "$DATA" http://localhost:8983/solr/core/schema 

echo "Adding our field"
DATA='{
  "add-field":{
    "name": "date_intervals",
    "type": "vector_2d",
    "stored": true,
    "indexed": true,
    "multiValued": true
  }
}'
echo $DATA
curl -H "Content-type: application/json" -d "$DATA" http://localhost:8983/solr/core/schema

SHELDON="\"$START_DATE $(($START_DATE + $DAY))\""
PENNY="\"$START_DATE $(($START_DATE + 2 * $DAY))\""
LEONARD="\"$START_DATE $(($STARt_DATE + 3 * $DAY))\""
RAJ="\"$START_DATE $(($START_DATE + 4 * $DAY))\""
HOWARD="\"$START_DATE $(($START_DATE + 5 * $DAY))\""

for i in {1..100}; do
  SHELDON="$SHELDON, \"$(($START_DATE + $i * 3 * $DAY)) $(($START_DATE + ($i * 3 + 1) * $DAY))\""
  PENNY="$PENNY, \"$(($START_DATE + $i * 4 * $DAY)) $(($START_DATE + ($i * 4 + 1) * $DAY))\""
  LEONARD="$LEONARD, \"$(($START_DATE + $i * 5 * $DAY)) $(($START_DATE + ($i * 5 + 1) * $DAY))\""
  RAJ="$RAJ, \"$(($START_DATE + $i * 6 * $DAY)) $(($START_DATE + ($i * 6 + 1) * $DAY))\""
  HOWARD="$HOWARD, \"$(($START_DATE + $i * 7 * $DAY)) $(($START_DATE + ($i * 7 + 1) * $DAY))\""
done

SHELDON="{\"id\": \"sheldon\", \"date_intervals\": [ $SHELDON ] }"
PENNY="{\"id\": \"penny\", \"date_intervals\": [ $PENNY ] }"
LEONARD="{\"id\": \"leonard\", \"date_intervals\": [ $LEONARD ] }"
RAJ="{\"id\": \"raj\", \"date_intervals\": [ $RAJ ] }"
HOWARD="{\"id\": \"howard\", \"date_intervals\": [ $HOWARD ] }"

echo $SHELDON

curl -H "Content-type: application/json" -d "$SHELDON" http://localhost:8983/solr/core/update/json/docs
curl -H "Content-type: application/json" -d "$PENNY" http://localhost:8983/solr/core/update/json/docs
curl -H "Content-type: application/json" -d "$LEONARD" http://localhost:8983/solr/core/update/json/docs
curl -H "Content-type: application/json" -d "$RAJ" http://localhost:8983/solr/core/update/json/docs
curl -H "Content-type: application/json" -d "$HOWARD" http://localhost:8983/solr/core/update/json/docs
curl http://localhost:8983/solr/core/update?commit=true
