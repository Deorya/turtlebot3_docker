# 使用ROS2 Humble + Gazebo的基础镜像
FROM osrf/ros:humble-desktop
 
# 设置工作目录
WORKDIR /workspace
 
# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive
 
# 安装必要的工具和TurtleBot3包
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    ros-humble-turtlebot3* \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-rviz2 \
    ros-humble-nav2-bringup \
    ros-humble-slam-toolbox \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*
   
# 创建Gazebo模型目录并下载模型
RUN mkdir -p /root/.gazebo/models && \
    cd /root/.gazebo/models && \
    wget -q https://github.com/osrf/gazebo_models/archive/refs/heads/master.tar.gz -O gazebo_models.tar.gz && \
    tar -xzf gazebo_models.tar.gz --strip-components=1 && \
    rm gazebo_models.tar.gz &&\
    sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list &&\
    sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list &&\
    echo "202.38.95.110 mirrors.ustc.edu.cn" >> /etc/hosts &&\
    echo "101.6.15.130 mirrors.tuna.tsinghua.edu.cn" >> /etc/hosts &&\
    echo "64.50.233.100 packages.ros.org" >> /etc/hosts

 
# 复制所有源码到容器工作空间
COPY ./src /workspace/src
 
# 编译工作空间 - 使用bash -c来正确source环境
RUN bash -c "cd /workspace && source /opt/ros/humble/setup.bash && colcon build"
 
# 设置环境变量
ENV TURTLEBOT3_MODEL=burger
 
# 设置启动时自动source环境
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /workspace/install/setup.bash" >> ~/.bashrc
# 复制启动脚本
COPY start_simulation.sh /workspace/start_simulation.sh
RUN chmod +x /workspace/start_simulation.sh
 
# 设置容器启动命令
CMD ["/bin/bash", "-c", "source ~/.bashrc && /workspace/start_simulation.sh"]
