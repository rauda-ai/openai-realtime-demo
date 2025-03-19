# Running the OpenAI Realtime Demo as a Systemd Service

This guide helps you set up the OpenAI Realtime Demo to run automatically using systemd.

## Installation

1. Copy the service file to systemd:

```bash
sudo cp realtime-demo.service /etc/systemd/system/
```

2. Reload systemd to recognize the new service:

```bash
sudo systemctl daemon-reload
```

3. Enable the service to start on boot:

```bash
sudo systemctl enable realtime-demo.service
```

4. Start the service:

```bash
sudo systemctl start realtime-demo.service
```

## Managing the Service

- Check status:
  ```bash
  sudo systemctl status realtime-demo.service
  ```

- View logs:
  ```bash
  sudo journalctl -u realtime-demo.service -f
  ```

- Stop the service:
  ```bash
  sudo systemctl stop realtime-demo.service
  ```

- Restart the service:
  ```bash
  sudo systemctl restart realtime-demo.service
  ```

## Configuration

If you need to modify the service configuration:

1. Edit the service file:
   ```bash
   sudo nano /etc/systemd/system/realtime-demo.service
   ```

2. Always reload systemd after changes:
   ```bash
   sudo systemctl daemon-reload
   ```

3. Restart the service:
   ```bash
   sudo systemctl restart realtime-demo.service
   ```

## Environment Variables

For security, it's best to manage environment variables using systemd:

1. Create an environment file:
   ```bash
   sudo nano /etc/systemd/system/realtime-demo.service.d/override.conf
   ```

   Add content:
   ```
   [Service]
   Environment="OPENAI_API_KEY=your_key_here"
   ```

2. Reload and restart:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart realtime-demo.service
   ```

This approach keeps your service running even after server reboots and maintains logs for troubleshooting.