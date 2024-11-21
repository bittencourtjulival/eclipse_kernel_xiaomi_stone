### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Paimon Kernel By Taki/Amrito
do.devicecheck=1
device.name1=veux
device.name2=peux
do.cleanup=1
supported.versions=11.0-15.0
'; } # end properties

override_cmdline() {
local cmdline='androidboot.hardware=qcom lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.usbcontroller=4e00000.dwc3 swiotlb=noforce loop.max_part=7 iptable_raw.raw_before_defrag=1 ip6table_raw.raw_before_defrag=1 firmware_class.path=/vendor/firmware buildvariant=user'
sed -i '/^cmdline/d' $split_img/header;
echo cmdline=$cmdline >> $split_img/header;
}

### AnyKernel install
# boot shell variables
block=boot;
is_slot_device=auto;
no_block_display=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot;
flash_boot;
## end boot install

# vendor_boot shell variables
block=vendor_boot;
is_slot_device=auto;

# reset for vendor_boot patching
reset_ak;

# vendor_boot install
split_boot;
override_cmdline;
flash_boot;
## end vendor_boot install

