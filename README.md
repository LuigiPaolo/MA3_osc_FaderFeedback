# grandMA3 to Chataigne OSC Fader Feedback

[![Version](https://img.shields.io/badge/version-0.1.0-alpha-blue.svg)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

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

### 1. grandMA3 Configuration
1. Go to `Menu > In/Out > OSC`.
2. Configure a new line with `Destination IP` set to your local machine (e.g., `127.0.0.1` if Chataigne is on the same PC).
3. Set `Destination Port` to `8001` (or the port Chataigne is listening on).
4. **Important:** Disable all `Send`, `Send Cmd`, and `Send Executors` options in the OSC settings to prevent network flooding. Enable `Receive` and `Receive Cmd`.

### 2. Plugin Installation
1. Download the latest release from the [Releases page](https://github.com/LuigiPaolo/MA3_osc_FaderFeedback/releases).
2. Load the `fader_feedback.lua` script into a plugin slot in your grandMA3 project.
3. Edit the script and ensure the `osc_line` variable at the top matches your OSC line ID.

### 3. Chataigne Mapping
1. Create an OSC module in Chataigne listening on the selected port.
2. The incoming OSC paths will be `/xtouch/fader/[1-8]` and `/xtouch/master`.
3. Create a **Mapping** for each fader:
   - **Input:** OSC module -> `/xtouch/fader/X`.
   - **Output:** MIDI module -> `Send Control Change`.
   - **Filter:** Add a `Remap` filter. Set **Input Min: 0** to **Input Max: 1** (OSC range) and **Output Min: 0** to **Output Max: 127** (MIDI range).

## 🤝 Contributing
We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a Pull Request.
