# Rsync

sudo mkdir /mnt/usb

sudo mount /dev/sdp1 /mnt/usb

sudo rsync --verbose --progress --log-file=/var/log/rsync.log --archive /mnt/usb/backup /mnt/rusty/
sudo rsync --verbose --progress --log-file=/var/log/rsync.log --archive /mnt/usb/data /mnt/rusty/
sudo rsync --verbose --progress --log-file=/var/log/rsync.log --archive /mnt/usb/iso /mnt/rusty/

sudo rsync --verbose --progress --log-file=/var/log/rsync.log --archive /mnt/usb/media /mnt/rusty/
