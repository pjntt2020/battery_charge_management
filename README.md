手边的MBP,平时就放在家里当台式机用.也因为这样电源是一直插着，很担心因此会影响电池的寿命,加上对苹果的电池充电管理功能也不是很放心.本着能省则省的原则,看看有没有第三方的免费充电管理软件能解决此问题.
功夫不负有心人,在https://github.com/zackelia/bclm 上找到一个MBP的SMC设置软件,还是没办法能达到Thinkpad的充电管理那样能设置充电范围,低于某值开始充电,高于某值停止充电.又在 https://github.com/Timelord-Enterprises/Battery-Drain-Monitor 找到了读取当前电池的电量的方法,于是两者合并,手撮一个小脚本达到自己目标.
程序原理很简单,在ROOT下设置一个定时任务，就是每一分钟运行battery_monitor.sh
当低于设定值时改变MBP的SMC充电值,此时MBP开始充电.当电池高于设定值时,重新改变定MBP的SMC充电值,此时MBP停止充电.从而达到预期效果.
