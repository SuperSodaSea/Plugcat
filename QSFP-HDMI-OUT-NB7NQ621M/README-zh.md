# QSFP-HDMI-OUT-NB7NQ621M

![Module Photo 1](./images/Module-Photo-1.jpg)

<p align="center">
    <a href="./README.md">English</a> |
    中文
</p>

---

[![GitHub Stars](https://img.shields.io/github/stars/SuperSodaSea/Plugcat.svg?style=social)](https://github.com/SuperSodaSea/Plugcat/stargazers)
[![GitHub License](https://img.shields.io/github/license/SuperSodaSea/Plugcat)](https://github.com/SuperSodaSea/Plugcat/blob/main/LICENSE)

还在为 FPGA 板卡缺少视频输出接口而发愁吗？这款小巧精致的创新模块可以帮您！QSFP-HDMI-OUT-NB7NQ621M 是一款具有 HDMI 输出接口的 QSFP 模块：只需将其插入 FPGA 板卡上的 QSFP 插槽中，即可立即使板卡获得 HDMI 输出功能。这将极大提高您 FPGA 板卡的可扩展性。

## 特性

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
| ModPrsL | 为低电平时，HDMI 线缆为插入状态   |
| ResetL  | 为低电平时，重置 NB7NQ621M        |
| SCL     | NB7NQ621M 和 HDMI DDC 的 I2C 时钟 |
| SDA     | NB7NQ621M 和 HDMI DDC 的 I2C 数据 |

## PCB 信息

- 厚度: 1.00mm
- 叠层结构: JLC04101H-3313

## 已验证的 FPGA 板卡

- Xilinx Zynq 7000 SoC
  - 公子哥 玄武 ZYNQ7100 + FMC 转 QSFP 子板
- Xilinx Kintex Ultrascale
  - Alpha Data ADM-PCIE-KU3（含[示例代码](./examples/ADM-PCIE-KU3/)）
- Xilinx Kintex UltraScale+
  - 博宸精芯 KU5P（含[示例代码](./examples/BoChenJingXin-KU5P/)）
  - RIGUKE RK-XCKU5P-F（含[示例代码](./examples/RK-XCKU5P-F/)）
  - 米联客 MLK-H8-CU06-KU5P（含[示例代码](./examples/MLK-H8-CU06-KU5P/)）
- Xilinx Virtex UltraScale+
  - 阿里巴巴 VU13P（含[示例代码](./examples/Alibaba-VU13P/)）
- Altera Stratix V GS
  - 微软 Catapult v2 Storey Peak / X930613-001（含[示例代码](./examples/Storey-Peak/)）
- Altera Arria 10 GX
  - 微软 Catapult v3 Longs Peak / Model: 1768（含[示例代码](./examples/Longs-Peak/)）
- 紫光同创 Titan-2
  - 小眼睛泰坦 390H + FMC 转 QSFP 子板

## 示例代码

示例代码在 Windows 与 Linux 下均可构建。

### 依赖工具

- [Python 3](https://www.python.org/)（用于构建脚本）
- [Java](https://www.java.com/)（用于 Chisel）
- [Mill](https://mill-build.org/mill/index.html)（用于 Chisel）
- [Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html)（用于构建 Xilinx FPGA 工程）
- [Quartus Prime](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html)（用于构建 Altera FPGA 工程）

### 构建示例代码

在对应示例代码目录下运行以下命令即可构建示例代码：

```bash
python build.py build
```

示例代码的默认视频模式为 `1920x1080@60Hz`。若需要更改分辨率和刷新率，可通过命令行参数指定：

```bash
python build.py build --resolution 2560x1440 --refresh-rate 144
```

支持的视频模式：
 - `1920x1080@30/60/120/144/240Hz`
 - `2560x1440@30/60/120/144Hz`
 - `3840x2160@30/60Hz`

其他分辨率可自行修改代码实现。

### 下载位流

```shell
python build.py program
```

### 固化位流

```shell
python build.py flash
```

## 画廊

![Module Photo 2](./images/Module-Photo-2.jpg)
![Module Photo 3](./images/Module-Photo-3.jpg)
