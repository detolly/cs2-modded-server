docker run \
  --name='cs2' \
  --env-file ".env" \
  -p '27015:27015/tcp' \
  -p '27015:27015/udp' \
  -p '27020:27020/udp' \
  -v $PWD'/cs2':'/cs2':'rw' \
  -v $PWD'/custom_files':'/custom_files':'rw' \
  'cs2-modded-server' 

  # -p '27015:27015/tcp' \
  # -p '27015:27015/udp' \
  # -p '27020:27020/udp' \
