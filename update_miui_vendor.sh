#/bin/sh

# Set of few device/setup specific variables
device=gemini
vendor=xiaomi
backup_dir=/media/louis/SAUVEGARDE/MIUI/
really_want_backup=1
package=$1
local_dir="$(pwd)"

# Script
if [ -e $package.zip ]; then
	sudo "Granting sudo acess ..."; # Could be usefull later

	# Backup
	if ["$really_want_backup" = "1"]; then
		cp $package.zip $backup_dir
	fi

	# Unpack
	unzip $package.zip
	cd $package
	# If the block based method is used
	if [ -e system.new.dat ]; then
		wget https://github.com/xpirt/sdat2img/blob/master/sdat2img.py # Credits to @xpirt for sdat2img
		python sdat2img.py system.transfer.list system.new.dat system.img
		rm sdat2img.py system.transfer.list system.new.dat
	fi
	mkdir sys # Temporary dir
	sudo mount -o loop system.img sys/
	mkdir system # Real dir
	cp -R sys/* system/
	sudo umount sys/
	rm -rf sys
	zip -r ../"$package"-NEW.zip *
	mv system/ ../
	cd .. # Done working here

	# Making vendor
	mkdir android
	git clone git@git.aosparadox.org:CyanogenMod/android_device_xiaomi_gemini.git android/device/xiaomi/gemini
	cd android/device/xiaomi/gemini
	./extract-files.sh -d $local_dir/	
	mv vendor/xiaomi $local_dir/proprietary_vendor_xiaomi

	# Cleanup
	cd $local_dir
	rm -rf $package.zip $package/ system* android/

	# TODO
	echo "TODO :"
	echo "- Updating device tree files"
	echo "- Updating ramdisk"
	echo "- Clarifying code with goto ?"
	echo "- Specific goto in case of missing file"
else
	echo 'File '$package'.zip do not exist'

