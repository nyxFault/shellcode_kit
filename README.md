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
./shellcode_kit.sh -a x86 --compile hello_x86.s

# Extract shellcode from a binary and shellcode is saved in a .txt file
./shellcode_kit.sh --extract hello_x86

# Run with specific architecture (64-bit by default)
./shellcode_kit.sh -a x86 --run hello_x86

# Debug generated code without execution
./shellcode_kit.sh --debug hello_x86
```
