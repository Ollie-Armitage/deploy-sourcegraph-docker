#!/usr/bin/env bash
set -e
source ./replicas.sh

# Description: Backend for text search operations.
#
# Disk: 128GB / non-persistent SSD
# Network: 100mbps
# Liveness probe: HTTP GET http://searcher:3181/healthz
# Ports exposed to other Sourcegraph services: 3181/TCP 6060/TCP
# Ports exposed to the public internet: none
#
VOLUME="$HOME/sourcegraph-docker/searcher-$1-disk"
./ensure-volume.sh $VOLUME 100
docker run --detach \
    --name=searcher-$1 \
    --network=sourcegraph \
    --restart=always \
    --cpus=2 \
    --memory=2g \
    -e GOMAXPROCS=2 \
    -e SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090 \
    -e JAEGER_AGENT_HOST=jaeger \
    -v $VOLUME:/mnt/cache \
    index.docker.io/sourcegraph/searcher:3.22.1@sha256:d3cb9248baa10cb0a610716044d59bcece4718b50322ab274b0ad213ad8d8512

echo "Deployed searcher $1 service"
