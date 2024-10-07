
UART16550的部分实现
===============
实现一个使用APB总线控制的UART模块

--------设计--------
**波特率产生模块**
	*根据功能时钟和配置，产生收发波特率计数值。
**数据接收**
	*根据波特率计数值数据，进行奇偶校验，存放数据到接收数据寄存器，再由CPU经过APB总线读取数据。
**数据发送**
	*CPU通过APB总线将需要发送的数据放到发送数据寄存器，根据波特率计数值数据进行数据发送。
**寄存器配置**
	*实现APB读写寄存器功能。


--------验证--------
	*为每个模块编写了相应的tb文件


##用户寄存器中已实现的功能
<div align=center><img src="https://github.com/twomonkeyclub/UART/blob/master/utils/frame.png" height="200"/> </div>