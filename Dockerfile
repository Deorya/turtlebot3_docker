# 使用ROS2 Humble + Gazebo的基础镜像
FROM osrf/ros:humble-desktop
 
# 设置工作目录
WORKDIR /workspace
 
# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 优化点 1: 首先修改APT源和hosts以加速后续下载
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
 
 
# 优化点 2: 拆分 RUN 以便调试
# 步骤 2.1: 更新包列表
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    wget  \
    ros-humble-turtlebot3* \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-rviz2 \
    ros-humble-nav2-bringup \
    ros-humble-slam-toolbox \
    && rm -rf /var/lib/apt/lists/*
   
# 优化点 3: 将模型下载与源设置分离
RUN mkdir -p /root/.gazebo/models && \
    cd /root/.gazebo/models && \
    wget -q https://github.com/osrf/gazebo_models/archive/refs/heads/master.tar.gz -O gazebo_models.tar.gz && \
    tar -xzf gazebo_models.tar.gz --strip-components=1 && \
    rm gazebo_models.tar.gz
 
# 复制所有源码到容器工作空间
COPY ./src /workspace/src
 
# 编译工作空间 - 使用bash -c来正确source环境
RUN bash -c "cd /workspace && source /opt/ros/humble/setup.bash && colcon build"
 
# 设置启动时自动source环境
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /workspace/install/setup.bash" >> ~/.bashrc
