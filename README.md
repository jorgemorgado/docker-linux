# Docker Linux

Run a Linux distribution on Docker. Useful in case you need to test some specific distro.

## Configuration

Update the variables in the `setup.conf` file.

## Build And Run

Makefile targets:

```bash
# Show existing targets
make

# Build the Docker image (see other examples in Makefile)
make build [NAME=name [VER=ver] [TAG=tag]]

# Start the container
make run [NAME=name [VER=ver] [TAG=tag]]

# Enter the container (with your account)
make enter [NAME=name [VER=ver] [TAG=tag]]

# Enter the container (as root)
make root [NAME=name [VER=ver] [TAG=tag]]

# Stop the container
make stop [NAME=name [VER=ver] [TAG=tag]]
```

## Connect Via SSH

Check the Dockerfile for each distribution on how to start the SSH service.

Usually the process is as simple as:

```bash
# Enter the container
make enter

# Start SSH service in the container
sudo systemctl enable sshd && \
sudo systemctl start sshd && \
systemctl status sshd

# Check the port mapping and connect via SSH
make show
ssh -p PORT 127.0.0.1
```
