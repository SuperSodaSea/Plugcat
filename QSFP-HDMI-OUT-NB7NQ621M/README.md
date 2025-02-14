# QSFP-HDMI-OUT-NB7NQ621M

![Module Photo 1](./images/Module-Photo-1.jpg)

<p align="center">
    English |
    <a href="./README-zh.md">中文</a>
</p>

---

[![GitHub Stars](https://img.shields.io/github/stars/SuperSodaSea/Plugcat.svg?style=social)](https://github.com/SuperSodaSea/Plugcat/stargazers)
[![GitHub License](https://img.shields.io/github/license/SuperSodaSea/Plugcat)](https://github.com/SuperSodaSea/Plugcat/blob/main/LICENSE)

Bothered by the lack of video output interface on your FPGA boards? This tiny innovative module can help you! QSFP-HDMI-OUT-NB7NQ621M is a QSFP module with HDMI output connector: simply plug it into the QSFP socket on your FPGA boards and get HDMI output capability instantly. This greatly enhances the extensibility of your FPGA boards.

- Uses [NB7NQ621M](https://www.onsemi.com/products/signal-conditioning-control/redrivers/NB7NQ621M) redriver chip, supports HDMI 2.1 video signal output, bandwidth up to 48Gbps
- HDMI 2.0 TMDS example code provided, supports display modes such as 1920x1080@240Hz, 2560x1440@144Hz, 3840x2160@60Hz, etc.
- HDMI 2.1 FRL example code TBA, you can use arbitrary HDMI 2.1 IP core

## Pin Description

| Name    | Description                                   |
|---------|-----------------------------------------------|
| TX1p    | HDMI CK+                                      |
| TX1n    | HDMI CK-                                      |
| TX2p    | HDMI D0+                                      |
| TX2n    | HDMI D0-                                      |
| TX3p    | HDMI D1+                                      |
| TX3n    | HDMI D1-                                      |
| TX4p    | HDMI D2+                                      |
| TX4n    | HDMI D2-                                      |
| ModPrsL | HDMI cable is plugged in when low             |
| ResetL  | Reset NB7NQ621M when low                      |
| SCL     | I2C clock for both the NB7NQ621M and HDMI DDC |
| SDA     | I2C data for both the NB7NQ621M and HDMI DDC  |

## PCB Information

- Thickness: 1.00mm
- Layer Stackup: JLC04101H-3313

## Verified FPGA Boards

- Xilinx UltraScale+ (GTY)
  - BoChenJingXin KU5P
  - Alibaba VU13P

## Gallery

![Module Photo 2](./images/Module-Photo-2.jpg)
![Module Photo 3](./images/Module-Photo-3.jpg)
