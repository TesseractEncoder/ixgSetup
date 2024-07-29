

install_dependencies()
{
sudo apt-get update -qq && sudo apt-get -y install autoconf automake build-essential cmake git libass-dev libfreetype6-dev libgnutls28-dev libtool libva-dev \
libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev libunistring-dev libaom-dev nasm libx264-dev \
libx265-dev libnuma-dev libvpx-dev libfdk-aac-dev libmp3lame-dev libva-dev libvdpau-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev tclsh libssl-dev
#sudo apt install libsdl2-dev
}
#<<cmt
setup_cuda_envirnment()
{

#Disable the Nouveau drivers
if [ -f "$file_nouveau" ]; then
	echo "file exist"
else 
    	echo "$FILE does not exist."
cat <<EOF >/etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF

	sudo update-initramfs -u
	sudo reboo

cat <<EOT >> /home/tess/.profile
# set PATH for cuda 12.2 installation
if [ -d "/usr/local/cuda-12.2/bin/" ]; then
    export PATH=/usr/local/cuda-12.2/bin\${PATH:+:\${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}
fi
EOT

fi

}
#cmt

install_cuda_driver()
{
#nvidia driver
if [ -f "$file_cuda" ]; then
	echo "Cuda file exits"
	sudo sh cuda_12.2.2_535.104.05_linux.run --silent --driver --toolkit
else
	echo "Cuda file doesn't exits"
	wget https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run
	sudo sh cuda_12.2.2_535.104.05_linux.run --silent --driver --toolkit
fi

if [ $? != 0 ]; 
then
	echo "Cuda + nvidia driver not installed"
fi

}




install_decklink_driver()
{
#install Decklink driver
sudo dpkg -i desktopvideo_12.4.1a15_amd64.deb

if [ $? != 0 ]; 
then
	echo "Decklink driver not installed try new method"
	sudo apt install -f -y
	if [ $? != 0 ]; 
	then
		echo "Decklink driver not installed by new method"
	fi
fi

}


install_gstreamer()
{
sudo apt install -y libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio gstreamer1.0-fdkaac
}

install_pm2()
{

sudo apt install -y npm
sudo npm install --unsafe-perm
sudo npm install -g pm2

}

install_ffmpeg()
{
sudo mkdir -p /home/tess/tessProj/ffmpeg
cd srt-master
sudo ./configure
sudo make
sudo make install
	
cd ../librist-master
sudo meson build/
sudo ninja -C build/
sudo ninja -C build/ install

cd `pwd`/encoder
sudo cp -r ffmpeg/* /home/tess/tessProj/ffmpeg/

sudo ldconfig -v
}

nvidia_patch()
{
	cd /opt
	sudo git clone https://github.com/keylase/nvidia-patch.git
	cd nvidia-patch
	sudo ./patch.sh
}

<<cmt2
decklink_setup()
{
	
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 0 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 1 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 2 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 3 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 4 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 5 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 6 -p 1
	`pwd`/BMDSDK/Linux/Samples/bin/x86_64/ActivateProfile -d 7 -p 1
}
cmt2

setup_ixg_agent()
{
	sudo cp ixg_agent/ixg-agent /usr/local/bin/
	sudo cp ixg_agent/ixg-agent.service  /etc/systemd/system/
	sudo chmod 744 /usr/local/bin/ixg-agent
	sudo chmod 664 /etc/systemd/system/ixg-agent.service
	sudo systemctl daemon-reload
	sudo systemctl enable ixg-agent.service
	sudo systemctl start ixg-agent.service
}


cuda_ver=12.2

file_nouveau=/etc/modprobe.d/blacklist-nouveau.conf

file_cuda=cuda_12.2.2_535.104.05_linux.run


install_dependencies
setup_cuda_envirnment
install_cuda_driver
install_decklink_driver
install_gstreamer
#install_ffmpeg
decklink_setup
install_pm2




