FROM ros:lunar-ros-core-xenial

#Set the working directory to /files
WORKDIR /files

#Add files
ADD . /files

ENV DISPLAY :0

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
	wget \
	x11vnc \
	xvfb \
	xinit \
	xterm 

RUN  mkdir ~/.vnc

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

RUN git clone https://github.com/KenYF/Files_GENG5508.git  && \
	rm Dockerfile \
	requirements.txt \
	requirements_2.txt \
	cloudbuild.yaml \
	README.md
	
RUN addgroup --system xusers \
  && adduser \
			--home /home/xuser \
			--disabled-password \
			--shell /bin/bash \
			--gecos "user for running X Window stuff" \
			--ingroup xusers \
			--quiet \
			xuser

# Install xvfb as X-Server and x11vnc as VNC-Server
RUN apt-get update && apt-get install -y --no-install-recommends \
				xvfb \
				xauth \
				x11vnc \
				x11-utils \
				x11-xserver-utils \
		&& rm -rf /var/lib/apt/lists/*

# create or use the volume depending on how container is run
# ensure that server and client can access the cookie
RUN mkdir -p /Xauthority && chown -R xuser:xusers /Xauthority
VOLUME /Xauthority

# start x11vnc and expose its port
ENV DISPLAY :0.0
EXPOSE 5900
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# switch to user and start
USER xuser
ENTRYPOINT ["/entrypoint.sh"]

	
#CMD ["jupyter","lab","--allow-root","--ip=0.0.0.0"]
#CMD ["bash"]
