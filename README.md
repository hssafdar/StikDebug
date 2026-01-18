<div align="center">
   <img width="217" height="217" src="/assets/StikJIT.png" alt="Logo">
</div>
   

<div align="center">
  <h1><b>StikDebug</b></h1>
  <p><i> An on-device debugger/JIT enabler for iOS versions 17.4+ powered by <a href="https://github.com/jkcoxson/idevice">idevice.</a> </i></p>
</div>

<h6 align="center">

  <a href="https://discord.gg/ZnNcrRT3M8">
    <img src="https://img.shields.io/badge/Discord-join%20us-7289DA?logo=discord&logoColor=white&style=for-the-badge&labelColor=23272A" />
  </a>
  <a href="https://github.com/StephenDev0/StikDebug/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/0-Blu/StikJIT?label=License&color=5865F2&style=for-the-badge&labelColor=23272A" />
  </a>
  </a>
  <a href="https://github.com/StephenDev0/StikDebug/stargazers">
    <img src="https://img.shields.io/github/stars/0-Blu/StikJIT?label=Stars&color=FEE75C&style=for-the-badge&labelColor=23272A" />
  </a>
  <br />
</h6>

# Download
<div align="center" style="display: flex; justify-content: center; align-items: center; gap: 16px; flex-wrap: wrap;">
   <a href="https://celloserenity.github.io/altdirect/?url=https://stikdebug.xyz/index.json" target="_blank">
  <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/AltSource_Blue.png?raw=true" alt="Add AltSource" width="200">
   </a>
   <a href="https://github.com/StephenDev0/StikDebug/releases/download/2.3.7/StikDebug-2.3.7.ipa" target="_blank">
  <img src="https://github.com/CelloSerenity/altdirect/blob/main/assets/png/Download_Blue.png?raw=true" alt="Download .ipa" width="200">
   </a>
</div>

## Code Help
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/stephendev0/stikdebug)

## Features  
- On-device debugging/Just-In-Time (JIT) compilation for supported apps via [`idevice`](https://github.com/jkcoxson/idevice).  
- No special VPN/Network Extension entitlements required.  
- Native UI for managing debugging/JIT-enabling.  
- No data collection—ensuring full privacy.
- **iOS Shortcuts support** - Kill the `backboardd` process (soft SpringBoard restart) via Siri or the Shortcuts app. 

## Using iOS Shortcuts

StikDebug now supports iOS Shortcuts (iOS 16.0+), allowing you to trigger a SpringBoard restart via Siri or the Shortcuts app without opening the app:

### Setup
1. Ensure your device is connected and the heartbeat is active in StikDebug
2. Open the **Shortcuts** app on your iOS device
3. The "Kill Backboardd" action will appear automatically in your shortcuts library

### Usage
You can invoke the shortcut by:
- Saying to Siri: **"Kill backboardd with StikDebug"** or **"Restart SpringBoard with StikDebug"**
- Running the shortcut manually from the Shortcuts app
- Adding it to automation workflows

**Note:** The heartbeat connection must be active for the shortcut to work. If the heartbeat is not active, you'll receive an error message.

## License  
StikDebug is licensed under **AGPL-3.0**. See [`LICENSE`](LICENSE) for details.  
