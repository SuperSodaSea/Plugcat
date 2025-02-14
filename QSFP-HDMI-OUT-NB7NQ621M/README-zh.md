# QSFP-HDMI-OUT-NB7NQ621M

![Module Photo 1](./images/Module-Photo-1.jpg)

<p align="center">
    <a href="./README.md">English</a> |
    中文
</p>

---

[![GitHub Stars](https://img.shields.io/github/stars/SuperSodaSea/Plugcat.svg?style=social)](https://github.com/SuperSodaSea/Plugcat/stargazers)
[![GitHub License](https://img.shields.io/github/license/SuperSodaSea/Plugcat)](https://github.com/SuperSodaSea/Plugcat/blob/main/LICENSE)

您是否为 FPGA 板卡缺少视频输出接口而烦恼？这款小巧精致的模块可以帮到您！QSFP-HDMI-OUT-NB7NQ621M 是一款具有 HDMI 输出功能的创新 QSFP 模块：只需将其插入 FPGA 板卡上的 QSFP 插槽中，即可立即获得一个 HDMI 输出接口。这将极大拓展您 FPGA 板卡的功能。

- 使用 [NB7NQ621M](https://www.onsemi.com/products/signal-conditioning-control/redrivers/NB7NQ621M) 重驱动器芯片，支持HDMI 2.1 视频信号输出，带宽高达 48Gbps
- 提供 HDMI 2.0 TMDS 示例代码，支持 1920x1080@240Hz、2560x1440@144Hz、3840x2160@60Hz 等显示模式
- HDMI 2.1 FRL 待后续提供，您可以使用任意 HDMI 2.1 IP 核

## 引脚描述

| 名称    | 描述                              |
|---------|-----------------------------------|
| TX1p    | HDMI CK+                          |
| TX1n    | HDMI CK-                          |
| TX2p    | HDMI D0+                          |
| TX2n    | HDMI D0-                          |
| TX3p    | HDMI D1+                          |
| TX3n    | HDMI D1-                          |
| TX4p    | HDMI D2+                          |
| TX4n    | HDMI D2-                          |
| ModPrsL | 为低电平时，HDMI 线缆为插入状态    |
| ResetL  | 为低电平时，重置 NB7NQ621M         |
| SCL     | NB7NQ621M 和 HDMI DDC 的 I2C 时钟 |
| SDA     | NB7NQ621M 和 HDMI DDC 的 I2C 数据 |

## PCB 信息

- 厚度: 1.00mm
- 叠层结构: JLC04101H-3313

## 已验证 FPGA 板卡

- Xilinx UltraScale+ (GTY)
  - 博宸精芯 KU5P
  - 阿里巴巴 VU13P

## 画廊

![Module Photo 2](./images/Module-Photo-2.jpg)
![Module Photo 3](./images/Module-Photo-3.jpg)
