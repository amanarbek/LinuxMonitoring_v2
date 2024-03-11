#!/bin/bash
sudo apt install sysstat
CPU_INFO=$(mpstat | tail -1)
CPU_SYS=$(echo $CPU_INFO | awk '{print $6}')
CPU_USR=$(echo $CPU_INFO | awk '{print $4}')
AVAIL_MEM=$(cat /proc/meminfo | awk 'NR == 2{print$2}')
FREE_SPACE=$(df / | tail -1 | awk '{print $4}')
echo -e "<pre>my_mpstat_cpu_sys $CPU_SYS
my_mpstat_cpu_usr $CPU_USR
my_available_ram $AVAIL_MEM
my_df_available $FREE_SPACE</pre>" > /var/www/html/index.html