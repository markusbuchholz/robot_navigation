#!/usr/bin/env bash

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist $DISPLAY)
    xauth_list=$(sed -e 's/^..../ffff/' <<< "$xauth_list")
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

# Mount the host binary and related directories
host_ollama_bin="/usr/local/bin/ollama"
host_ollama_lib="/usr/local/lib/ollama"
host_ollama_dir="/usr/local/ollama"
host_ollama_models="/usr/share/ollama/.ollama/models" 


local_gz_ws="/home/markus/simulation_ardupilot_SITL/gz_ws"
local_SITL_Models="/home/markus/simulation_ardupilot_SITL/SITL_Models"
#-v "$local_gz_ws:/home/blueboat_sitl/gz_ws" \
#-v "$local_SITL_Models:/home/blueboat_sitl/SITL_Models" \
# Running the Docker container with new volume mounts
    #-v "$local_gz_ws:/home/blueboat_sitl/gz_ws" \
    #-v "$local_SITL_Models:/home/blueboat_sitl/SITL_Models" \
docker run -it \
    --rm \
    --name robot_nav \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=$XAUTH \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -v "$XAUTH:$XAUTH" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/dev/input:/dev/input" \
    -v "$host_ollama_bin:/usr/local/bin/ollama:ro" \
    -v "$host_ollama_lib:/usr/local/lib/ollama:ro" \
    -v "$host_ollama_dir:/usr/local/ollama:ro" \
    -v "$host_ollama_models:/usr/share/ollama/.ollama/models" \
    --device /dev/dri/card1:/dev/dri/card1 \
    --device /dev/dri/card1:/dev/dri/card2 \
    --privileged \
    --security-opt seccomp=unconfined \
    --network host \
    --gpus all \
    robot_nav:latest





