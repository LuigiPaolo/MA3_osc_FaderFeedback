# MA3_osc_FaderFeedback

## grandMA3 to Chataigne OSC Fader Feedback

A rock-solid, network-friendly Lua plugin for grandMA3 that bridges fader feedback to motorized MIDI controllers (like the Behringer X-Touch) via Chataigne.

Unlike direct MIDI routing, this plugin relies entirely on OSC to ensure clean communication, zero port conflicts on Windows, and highly efficient network usage.

## ⚠️ Disclaimer
* **AI-Generated Code:** The core logic of this plugin was written by an AI and subsequently refined for live environments.
* **Compatibility:** Currently, this script has **only been tested on grandMA3 version 2.4.2**. The MA3 Lua API is known to change between software releases. Please test thoroughly on your specific setup before deploying it in a live show environment!

## ✨ Key Features
* **Delta Tracking:** No network flooding. The plugin only transmits OSC data when a fader actually moves or a page changes, keeping the MA3 command line and the network quiet.
* **Active Page Awareness:** Automatically tracks the executors on the currently active page.
* **Ghost/Null Executor Handling:** Safely identifies empty or unassigned executors when switching pages and pulls the motorized faders down to zero, keeping your physical console state clean.
* **No MIDI Conflicts:** By routing data out via OSC to Chataigne, it bypasses the Windows single-client MIDI limitation, allowing Chataigne to exclusively handle the hardware bridging.

## 🚀 Setup & Installation

### 1. grandMA3 OSC Setup
1. Go to `Menu > In/Out > OSC`.
2. Configure a line with your local IP (`127.0.0.1`) and target the port Chataigne is listening to.
3. **Crucial:** Turn OFF all automatic `Send`, `Send Cmd`, and `Send Executors` options to prevent native MA3 network spam. Ensure `Receive` is ON.

### 2. Plugin Setup
1. Import the Lua script into a new plugin slot in MA3.
2. Edit the script and ensure the `osc_line` variable at the top matches the line number of your OSC configuration.
3. Run the plugin.

### 3. Chataigne Routing
1. Setup an OSC module listening on the correct port.
2. You will receive clean incoming paths formatted as `/xtouch/fader/[1-8]` and `/xtouch/master`.
3. Create a **Mapping** block for each fader. Target your MIDI controller's Control Change (CC) output.
4. Add a `Remap` filter in Chataigne to scale the OSC float values (`0` to `1`) to standard MIDI ranges (`0` to `127`).

## 🤝 Contributing
Community input is highly appreciated to add value to this project! If you test this script on different versions of grandMA3, discover edge cases, or have ideas to further optimize the Lua polling logic, please open an Issue or submit a Pull Request. Every suggestion helps make this tool more reliable for everyone.
