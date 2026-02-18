# RPI-waveshare-tft-clock

A simple set of scripts to install and launch a full screen clock ...  great for Raspberry Pi's using the waveshare TFT display over GPIO.

## Features

- **Full screen clock display** - Shows time and date in an easy-to-read format
- **Waveshare TFT support** - Optimized for Waveshare TFT displays over GPIO
- **Auto-update** - Clock updates every second
- **Auto-start option** - Optional systemd service for automatic launch on boot
- **Lightweight** - Minimal resource usage, perfect for Raspberry Pi

## Hardware Requirements

- Raspberry Pi (any model with GPIO)
- Waveshare TFT display (tested with 3.5" LCD)
- MicroSD card with Raspberry Pi OS

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mr-tbot/RPI-waveshare-tft-clock.git
   cd RPI-waveshare-tft-clock
   ```

2. **Run the installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   The installer will:
   - Update system packages
   - Install Python 3 and required dependencies
   - Install pygame and SDL libraries
   - Optionally set up the clock as a systemd service

3. **Configure the Waveshare display:**
   
   Edit the Raspberry Pi configuration file and add the appropriate overlay for your display:
   - For newer OS (Bookworm and later): Edit `/boot/firmware/config.txt`
   - For older OS (Bullseye and earlier): Edit `/boot/config.txt`
   
   For Waveshare 3.5" LCD (B):
   ```
   dtparam=spi=on
   dtoverlay=waveshare35b
   ```
   
   For other Waveshare displays, check the [Waveshare wiki](https://www.waveshare.com/wiki/Main_Page) for the correct overlay.

4. **Reboot:**
   ```bash
   sudo reboot
   ```

## Usage

### Manual Launch

To start the clock manually:
```bash
./launch.sh
```

To stop the clock, press `Ctrl+C` or press `ESC` or `Q` key.

### Automatic Launch (Systemd Service)

If you installed the systemd service during installation:

**Start the clock:**
```bash
sudo systemctl start clock.service
```

**Stop the clock:**
```bash
sudo systemctl stop clock.service
```

**Check status:**
```bash
sudo systemctl status clock.service
```

**Enable auto-start on boot:** (already done during installation if you chose 'yes')
```bash
sudo systemctl enable clock.service
```

**Disable auto-start:**
```bash
sudo systemctl disable clock.service
```

## File Structure

```
RPI-waveshare-tft-clock/
├── clock.py          # Main clock application
├── launch.sh         # Launch script
├── install.sh        # Installation script
├── clock.service     # Systemd service file
├── requirements.txt  # Python dependencies
└── README.md         # This file
```

## Customization

You can customize the clock by editing `clock.py`:

- **Display size:** Modify `DISPLAY_WIDTH` and `DISPLAY_HEIGHT`
- **Colors:** Change `BLACK`, `WHITE`, and `GRAY` color values
- **Font sizes:** Adjust font sizes in the `draw_clock()` function
- **Time format:** Modify the `strftime()` format strings
- **Framebuffer device:** Change `SDL_FBDEV` if your display uses a different framebuffer

## Troubleshooting

**Clock doesn't display on TFT:**
- Ensure the correct display overlay is enabled in the config file:
  - Newer OS (Bookworm+): `/boot/firmware/config.txt`
  - Older OS (Bullseye and earlier): `/boot/config.txt`
- Check that the framebuffer device exists: `ls /dev/fb*`
- Try manually specifying the framebuffer: `SDL_FBDEV=/dev/fb0 python3 clock.py`

**Permission denied errors:**
- Make sure scripts are executable: `chmod +x install.sh launch.sh clock.py`
- Run the clock as the pi user or with appropriate permissions

**Display shows but is garbled:**
- Check display resolution settings in `clock.py`
- Ensure the correct display driver is loaded

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
