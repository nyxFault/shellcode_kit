# shellcode_kit
An automation tool for shellcode development and analysis. Streamlines the entire workflow from assembly code to live execution with multi-architecture support.

## Installation

```bash
git clone https://github.com/nyxFault/shellcode_kit.git
cd shellcode_kit
chmod +x shellcode_kit.sh
```

## Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install gcc nasm ld binutils

# For 32-bit support (x86)
sudo apt install gcc-multilib
```
## Usage

```bash
# Compile assembly for 32-bit (64-bit by default)
./shellcode_kit.sh --compile hello.s -a x86

# Extract shellcode from a binary
./shellcode_kit.sh --extract /bin/ls

# Run with specific architecture (64-bit by default)
./shellcode_kit.sh --run hello -a x86

# Debug and execute
./shellcode_kit.sh --debug examples/hello
```
