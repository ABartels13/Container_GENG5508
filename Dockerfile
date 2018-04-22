FROM ros:lunar-ros-core-xenial

#Set the working directory to /files
WORKDIR /files

#Add files
ADD . /files

RUN apt-get update && apt-get install -y \ 
	git-core \
	nano \
	python-argparse \ 
	python-wstool \ 
	python-vcstools \ 
	python-rosdep \
	python-rosinstall \ 
	ros-kinetic-control-msgs \
	ros-kinetic-joystick-drivers \
	python3 \
	python \
	wget 

#RUN rosdep init && rosdep update

RUN apt-get install -y python3-pip python-pip && \
	pip3 install --trusted-host pypi.python.org -r requirements.txt && \
	pip install --trusted-host pypi.python.org -r requirements_2.txt

RUN . /opt/ros/lunar/setup.sh && \
	mkdir -p ros_ws/src && \
	cd ros_ws && \
	catkin_make && \
	catkin_make install

 RUN cd ros_ws/src && \
	wstool init . && \
	wstool merge https://raw.githubusercontent.com/RethinkRobotics/baxter/master/baxter_sdk.rosinstall && \
	wstool update

#RUN . /opt/ros/lunar/setup.sh && \
#	cd ros_ws && \
#	catkin_make && \
#	catkin_make install

RUN apt install -y libsm6 \
	libxext6 \
	libgtk2.0-dev && \ 
	pip3 install opencv-python && \
	pip install opencv-python

RUN cd ros_ws && \
	wget https://github.com/RethinkRobotics/baxter/raw/master/baxter.sh && \
	chmod u+x baxter.sh 
	
CMD ["jupyter","lab","--allow-root","--ip=0.0.0.0"]
#CMD ["bash"]
