#!/bin/bash
 
# 显式source ROS2和工作空间环境
source /opt/ros/humble/setup.bash
source /workspace/install/setup.bash
 
# 设置TurtleBot3模型
export TURTLEBOT3_MODEL=burger
 
# 启动多机器人仿真
echo "正在启动TurtleBot3多机器人仿真..."
ros2 launch my_turtlebot3_sim multi_robot.launch.py
 
