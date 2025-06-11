ARG ROS_DISTRO=rolling
FROM osrf/ros:${ROS_DISTRO}-desktop-full

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install OS and ROS development tools, NVIDIA libs, Gazebo bridge
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      # ROS dev tools
      ros-dev-tools \
      # general utilities
      bash-completion build-essential git glmark2 gnupg iputils-ping \
      lsb-release software-properties-common sudo wget vim \
      # NVIDIA / graphics
      libglvnd0 libgl1 libglx0 libegl1 libxext6 libx11-6 \
      # ZeroMQ and ROS-gz bridge
      cppzmq-dev ros-${ROS_DISTRO}-ros-gz \
    && rm -rf /var/lib/apt/lists/*

# NVIDIA settings
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
    QT_X11_NO_MITSHM=1

# Create and populate a Nav2 workspace
WORKDIR /root/nav2_ws
RUN mkdir -p src

ARG VERSION_TAG=latest
RUN if [[ "${ROS_DISTRO}" == "rolling" ]]; then \
      git clone https://github.com/ros-planning/navigation2.git --branch main src/navigation2 && \
      vcs import src < src/navigation2/tools/underlay.repos; \
    elif [[ "${VERSION_TAG}" == "latest" ]]; then \
      git clone https://github.com/ros-planning/navigation2.git --branch ${ROS_DISTRO} src/navigation2; \
    else \
      git clone https://github.com/ros-planning/navigation2.git --branch ${VERSION_TAG} src/navigation2; \
    fi

# Initialize rosdep and install Nav2 dependencies
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    apt-get update && \
    rosdep update && \
    rosdep install -y --ignore-src --from-paths src -r \
      --skip-keys "slam_toolbox turtlebot3_gazebo" && \
    rm -rf /var/lib/apt/lists/*

# Optionally build Nav2
ARG BUILD=true
ARG COLCON_BUILD_ARGS=""
RUN if [[ "${BUILD}" == "true" ]]; then \
      source /opt/ros/${ROS_DISTRO}/setup.bash && \
      colcon build ${COLCON_BUILD_ARGS}; \
    fi

WORKDIR /root/nav2_ws
