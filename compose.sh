# https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose:latest $@