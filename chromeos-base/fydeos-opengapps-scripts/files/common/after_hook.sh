#!/bin/bash

# ${after_hook_sh} ${update_zip} ${system_rw_dir} ${tmp_dir}


update_zip=$1
system_rw_dir=$2
tmp_dir=$3


sudo install -o 655360 -g 655360 -d ${system_rw_dir}/system/usr/share/opengapps
sudo setfilecon u:object_r:system_file:s0 ${system_rw_dir}/system/usr/share/opengapps

sudo echo '#!/system/bin/sh

counter=200

while [[ ! $counter -eq 0 ]];
do
	sleep 0.2
	pm disable "org.chromium.arc.applauncher/org.chromium.arc.applauncher.ChromeOsAccountManagerActivity"
	pm disable "com.google.android.setupwizard"
	((counter=$counter-1))
done

pm grant com.android.vending android.permission.WRITE_EXTERNAL_STORAGE
pm grant com.android.vending android.permission.READ_SMS
pm grant com.android.vending android.permission.RECEIVE_SMS
pm grant com.android.vending android.permission.READ_EXTERNAL_STORAGE
pm grant com.android.vending android.permission.ACCESS_COARSE_LOCATION
pm grant com.android.vending android.permission.READ_PHONE_STATE
pm grant com.android.vending android.permission.SEND_SMS
pm grant com.android.vending android.permission.WRITE_EXTERNAL_STORAGE
pm grant com.android.vending android.permission.READ_CONTACTS

' > ${tmp_dir}/patch_opengapps.sh

sudo install -o 655360 -g 655360 ${tmp_dir}/patch_opengapps.sh ${system_rw_dir}/system/usr/share/opengapps/
sudo setfilecon u:object_r:system_file:s0 ${system_rw_dir}/system/usr/share/opengapps/patch_opengapps.sh
sudo rm -f ${tmp_dir}/patch_opengapps.sh

sudo grep "service patch_opengapps" ${system_rw_dir}/init.rc
if [ ! $? -eq 0 ]; then

	sudo echo '
# >>> Configure Open GApps

service patch_opengapps /system/usr/share/opengapps/patch_opengapps.sh
	disabled
	user root
	seclabel u:r:shell:s0
	oneshot

on property:sys.boot_completed=1
	start patch_opengapps

# <<< Configure Open GApps

	' | sudo tee -a ${system_rw_dir}/init.rc

fi


