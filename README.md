# 串口上位机-FPGA数码管计数板

## 上位机

设计软件：QT6.5.3

功能描述：扫描串口-->选择串口名-->设置串口配置-->打开串口-->下方两个框输入待发送数据-->点击对应发送键

## ![](README_md_files/f268cf50-7e60-11ef-b01b-4f4974341e26.jpeg?v=1&type=image)

## 下位机

设计软件：Quartus18.1

功能描述：阴极数码管，接收上位机串口发送的带帧头（FFFF）数据并解析得到频率数据，按照接收到的频率进行计数，递增和计满清零。

![](README_md_files/05a26bc0-7e62-11ef-b01b-4f4974341e26.jpeg?v=1&type=image)
