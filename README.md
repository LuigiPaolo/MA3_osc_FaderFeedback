# grandMA3 to Chataigne OSC Fader Feedback

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A rock-solid, network-friendly Lua plugin for grandMA3 that bridges fader feedback to motorized MIDI controllers via Chataigne.

## 📋 Table of Contents
1. [Disclaimer](#-disclaimer)
2. [Features](#-features)
3. [Setup](#-setup)
4. [Contributing](#-contributing)

## ⚠️ Disclaimer
**AI-Assisted Code:** This plugin core logic was generated with AI assistance and refined for production. 
**Tested Version:** Currently tested and validated on **grandMA3 v2.4.2**. 
*Usage is at your own risk. Always test in a safe environment before live shows.*

## ✨ Features
* **Delta Tracking:** No network flooding. Data transmits only when values change.
* **Active Page Awareness:** Dynamically tracks executors on the current page.
* **Safety First:** Handles empty executors by force-resetting faders to zero.
* **No Conflicts:** Bypasses MIDI single-client Windows limitations via OSC bridging.

## 🚀 Setup
Detailed instructions on how to set up the OSC lines and Chataigne mappings can be found in the [Wiki/Documentation](link-to-docs-if-you-have-them) (or follow the standard installation steps below).

1. **MA3 Config:** Disable all auto-sending in OSC settings.
2. **Plugin:** Load the Lua script and set `osc_line` to your OSC output ID.
3. **Chataigne:** Route OSC input to your MIDI controller Output.

## 🤝 Contributing
We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a Pull Request.
