#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Style definitions
BOLD='\033[1m'
UNDERLINE='\033[4m'

TEMPLATE_FILE="shellcode_loader.c"
OUTPUT_FILE="shellcode_runner"

# Color functions
print_error() {
    echo -e "${RED}${BOLD}Error:${NC} $1"
}

print_success() {
    echo -e "${GREEN}${BOLD}Success:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}Warning:${NC} $1"
}

print_info() {
    echo -e "${BLUE}${BOLD}Info:${NC} $1"
}

print_debug() {
    echo -e "${PURPLE}${BOLD}Debug:${NC} $1"
}

print_header() {
    echo -e "${CYAN}${BOLD}${UNDERLINE}$1${NC}"
}

print_step() {
    echo -e "${ORANGE}${BOLD}==>${NC} $1"
}

print_code() {
    echo -e "${WHITE}$1${NC}"
}

print_shellcode() {
    echo -e "${GREEN}$1${NC}"
}

# Banner
print_banner(){
    echo -e "${CYAN}"
    echo '███████╗██╗  ██╗███████╗██╗     ██╗      ██████╗ ██████╗ ██████╗ ███████╗    ██╗  ██╗██╗████████╗'
    echo '██╔════╝██║  ██║██╔════╝██║     ██║     ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██║ ██╔╝██║╚══██╔══╝'
    echo '███████╗███████║█████╗  ██║     ██║     ██║     ██║   ██║██║  ██║█████╗      █████╔╝ ██║   ██║   '
    echo '╚════██║██╔══██║██╔══╝  ██║     ██║     ██║     ██║   ██║██║  ██║██╔══╝      ██╔═██╗ ██║   ██║   '
    echo '███████║██║  ██║███████╗███████╗███████╗╚██████╗╚██████╔╝██████╔╝███████╗    ██║  ██╗██║   ██║   '
    echo '╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═╝  ╚═╝╚═╝   ╚═╝   '
    echo -e "${NC}"                                                                                             
}


print_usage() {
    echo -e "${CYAN}${BOLD}Shellcode Kit${NC}"
    echo -e "${BLUE}${BOLD}Usage:${NC} $0 ${YELLOW}--extract <binary>${NC}"
    echo -e "       $0 ${YELLOW}--run <binary> ${RED}[-a x86|x64]${NC}"
    echo -e "       $0 ${YELLOW}--debug <binary>${NC}"
    echo -e "       $0 ${YELLOW}--compile <assembly_file> ${RED}[-a x86|x64]${NC}"
    echo ""
    echo -e "${BLUE}${BOLD}Examples:${NC}"
    echo -e "  $0 ${YELLOW}--extract /bin/ls${NC}"
    echo -e "  $0 ${YELLOW}--run my_shellcode_binary${NC}"
    echo -e "  $0 ${YELLOW}--run hello -a x86${NC}"
    echo -e "  $0 ${YELLOW}--debug examples/hello${NC}"
    echo -e "  $0 ${YELLOW}--compile hello.s -a x86${NC}"
    echo ""
    echo -e "${GREEN}${BOLD}Options:${NC}"
    echo -e "  ${YELLOW}--extract${NC}    Extract shellcode from binary and save to file"
    echo -e "  ${YELLOW}--run${NC}        Create loader and execute shellcode immediately"
    echo -e "  ${YELLOW}--debug${NC}      Show generated C code without execution"
    echo -e "  ${YELLOW}--compile${NC}    Compile assembly file to executable"
    echo -e "  ${RED}-a ARCH${NC}       Architecture: x86 (32-bit) or x64 (64-bit, default)"
    exit 1
}

extract_shellcode() {
    local binary="$1"
    
    if [[ ! -f "$binary" ]]; then
        print_error "Binary file '$binary' not found"
        exit 1
    fi
    
    print_header "Extracting Shellcode"
    print_step "Source: $binary"
    
    # Extract Shellcode
    local shellcode=$(objdump -d "$binary" | grep -Po '\s\K[a-f0-9]{2}(?=\s)' | tr -d '\n' | sed 's/\(..\)/\\x\1/g')
    
    if [[ -z "$shellcode" ]]; then
        print_error "Could not extract shellcode from binary"
        exit 1
    fi
    
    echo -e "${CYAN}${BOLD}Extracted shellcode:${NC}"
    print_shellcode "$shellcode"
    echo ""
    echo -e "${CYAN}${BOLD}Length:${NC} $((${#shellcode} / 4)) bytes"
    
    # Save to file
    local output_file="shellcode_$(basename "$binary").txt"
    echo "$shellcode" > "$output_file"
    print_success "Shellcode saved to: $output_file"
}

# Assembly compilation functions
compile_assembly() {
    local source_file="$1"
    local arch="$2"
    
    if [[ ! -f "$source_file" ]]; then
        print_error "Assembly file '$source_file' not found"
        exit 1
    fi
    
    print_header "Compiling Assembly"
    print_step "Source: $source_file"
    print_step "Architecture: $arch"
    
    local object_file="${source_file%.*}.o"
    local output_file="${source_file%.*}"
    
    # Compile based on architecture
    if [[ "$arch" == "x86" ]]; then
        print_step "Assembling for x86 (32-bit)"
        if nasm -f elf32 "$source_file" -o "$object_file"; then
            print_success "Assembly successful: $object_file"
        else
            print_error "Assembly failed"
            exit 1
        fi
        
        print_step "Linking for x86 (32-bit)"
        if ld -m elf_i386 "$object_file" -o "$output_file"; then
            print_success "Linking successful: $output_file"
            chmod +x "$output_file"
        else
            print_error "Linking failed"
            exit 1
        fi
    else
        print_step "Assembling for x64 (64-bit)"
        if nasm -f elf64 "$source_file" -o "$object_file"; then
            print_success "Assembly successful: $object_file"
        else
            print_error "Assembly failed"
            exit 1
        fi
        
        print_step "Linking for x64 (64-bit)"
        if ld "$object_file" -o "$output_file"; then
            print_success "Linking successful: $output_file"
            chmod +x "$output_file"
        else
            print_error "Linking failed"
            exit 1
        fi
    fi
    
    print_success "Compilation complete: $output_file"
}

create_loader_with_arch() {
    local binary="$1"
    local arch="$2"
    
    if [[ ! -f "$binary" ]]; then
        print_error "Binary file '$binary' not found"
        exit 1
    fi
    
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        print_warning "Template file '$TEMPLATE_FILE' not found"
        print_step "Creating default template..."
        create_template
    fi
    
    print_header "Creating Shellcode Loader"
    print_step "Binary: $binary"
    print_step "Architecture: $arch"
    
    local shellcode=$(objdump -d "$binary" | grep -Po '\s\K[a-f0-9]{2}(?=\s)' | tr -d '\n' | sed 's/\(..\)/\\x\1/g')
    
    if [[ -z "$shellcode" ]]; then
        print_error "Could not extract shellcode from binary"
        exit 1
    fi
    
    echo -e "${CYAN}${BOLD}Shellcode length:${NC} $((${#shellcode} / 4)) bytes"
    
    # Create temporary C file with actual shellcode
    local temp_c_file=$(mktemp --suffix=.c)
    
    # Read the template and replace the placeholder
    while IFS= read -r line; do
        if [[ "$line" == *"SHELLCODE_PLACEHOLDER"* ]]; then
            echo "const char shellcode[] = \"$shellcode\";"
        else
            echo "$line"
        fi
    done < "$TEMPLATE_FILE" > "$temp_c_file"
    
    print_step "Created temporary C file: $temp_c_file"
    
    # Compile the loader with architecture flag
    print_step "Compiling loader..."
    local compile_cmd="gcc -o "$OUTPUT_FILE" "$temp_c_file" -z execstack -fno-stack-protector -no-pie"
    
    if [[ "$arch" == "x86" ]]; then
        compile_cmd="$compile_cmd -m32"
        print_step "Using 32-bit compilation flags"
    fi
    
    if $compile_cmd; then
        print_success "Loader compiled successfully: $OUTPUT_FILE"
        chmod +x "$OUTPUT_FILE"
    else
        print_error "Compilation failed"
        if [[ "$arch" == "x86" ]]; then
            print_warning "Make sure you have 32-bit libraries installed:"
            print_warning "sudo apt install gcc-multilib"
        fi
        rm -f "$temp_c_file"
        exit 1
    fi
    
    # Cleanup
    rm -f "$temp_c_file"
}

create_loader() {
    local binary="$1"
    local debug_mode="$2"
    
    if [[ ! -f "$binary" ]]; then
        print_error "Binary file '$binary' not found"
        exit 1
    fi
    
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        print_warning "Template file '$TEMPLATE_FILE' not found"
        print_step "Creating default template..."
        create_template
    fi
    
    print_header "Creating Shellcode Loader"
    print_step "Binary: $binary"
    
    local shellcode=$(objdump -d "$binary" | grep -Po '\s\K[a-f0-9]{2}(?=\s)' | tr -d '\n' | sed 's/\(..\)/\\x\1/g')
    
    if [[ -z "$shellcode" ]]; then
        print_error "Could not extract shellcode from binary"
        exit 1
    fi
    
    echo -e "${CYAN}${BOLD}Shellcode length:${NC} $((${#shellcode} / 4)) bytes"
    
    # Create temporary C file with actual shellcode
    local temp_c_file=$(mktemp --suffix=.c)
    
    # Read the template and replace the placeholder
    while IFS= read -r line; do
        if [[ "$line" == *"SHELLCODE_PLACEHOLDER"* ]]; then
            echo "const char shellcode[] = \"$shellcode\";"
        else
            echo "$line"
        fi
    done < "$TEMPLATE_FILE" > "$temp_c_file"
    
    print_step "Created temporary C file: $temp_c_file"
    
    # Debug Mode
    if [[ "$debug_mode" == "true" ]]; then
        print_header "DEBUG: Full Generated C Code"
        echo -e "${PURPLE}"
        cat "$temp_c_file"
        echo -e "${NC}"
        print_success "Debug output complete - no compilation performed"
        rm -f "$temp_c_file"
        return 0
    fi
    
    # Compile the loader
    print_step "Compiling loader..."
    if gcc -o "$OUTPUT_FILE" "$temp_c_file" -z execstack -fno-stack-protector -no-pie; then
        print_success "Loader compiled successfully: $OUTPUT_FILE"
        chmod +x "$OUTPUT_FILE"
    else
        print_error "Compilation failed"
        print_header "Full Temporary File Content"
        echo -e "${RED}"
        cat "$temp_c_file"
        echo -e "${NC}"
        rm -f "$temp_c_file"
        exit 1
    fi
    
    # Cleanup
    rm -f "$temp_c_file"
}

create_template() {
    cat > "$TEMPLATE_FILE" << 'EOF'
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

// shellcode
const char shellcode[] = "SHELLCODE_PLACEHOLDER";

int main() {
    printf("Shellcode Length: %zu bytes\n", strlen(shellcode));
    
    // Allocate executable memory
    void *exec_mem = mmap(NULL, sizeof(shellcode), 
                         PROT_READ | PROT_WRITE | PROT_EXEC,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    
    if (exec_mem == MAP_FAILED) {
        perror("mmap failed");
        return 1;
    }
    
    printf("Allocated executable memory at: %p\n", exec_mem);
    
    // Copy shellcode to executable memory
    memcpy(exec_mem, shellcode, sizeof(shellcode));
    
    printf("Executing shellcode...\n");
    
    // Cast to function pointer and execute
    int (*func)() = (int(*)())exec_mem;
    func();
    
    // Cleanup (though we may not reach this)
    munmap(exec_mem, sizeof(shellcode));
    
    return 0;
}
EOF
    print_success "Created template file: $TEMPLATE_FILE"
}

run_loader() {
    local binary="$1"
    
    # First create the loader
    create_loader "$binary" "false"
    
    # Then run it
    echo ""
    print_header "Executing Shellcode"
    echo -e "${CYAN}${BOLD}----------------------------------------${NC}"
    ./"$OUTPUT_FILE"
}

debug_loader() {
    local binary="$1"
    
    print_header "DEBUG MODE"
    print_step "Binary: $binary"
    echo ""
    
    # Extract and show shellcode
    local shellcode=$(objdump -d "$binary" | grep -Po '\s\K[a-f0-9]{2}(?=\s)' | tr -d '\n' | sed 's/\(..\)/\\x\1/g')
    
    if [[ -z "$shellcode" ]]; then
        print_error "Could not extract shellcode from binary"
        exit 1
    fi
    
    echo -e "${CYAN}${BOLD}Extracted shellcode:${NC}"
    print_shellcode "$shellcode"
    echo ""
    echo -e "${CYAN}${BOLD}Shellcode length:${NC} $((${#shellcode} / 4)) bytes"
    echo ""
    
    # Create and display the loader code
    create_loader "$binary" "true"
}

# Script Starts here
print_banner

# Parse additional arguments
ARCH="x64"  # Default architecture
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -lt 2 ]]; then
    print_usage
fi

case "$1" in
    --extract)
        extract_shellcode "$2"
        ;;
    --run)
        if [[ "$ARCH" != "x64" && "$ARCH" != "x86" ]]; then
            print_error "Invalid architecture: $ARCH. Use x86 or x64"
            exit 1
        fi
        create_loader_with_arch "$2" "$ARCH"
        echo ""
        print_header "Executing Shellcode"
        echo -e "${CYAN}${BOLD}----------------------------------------${NC}"
        ./"$OUTPUT_FILE"
        ;;
    --debug)
        debug_loader "$2"
        ;;
    --compile)
        if [[ "$ARCH" != "x64" && "$ARCH" != "x86" ]]; then
            print_error "Invalid architecture: $ARCH. Use x86 or x64"
            exit 1
        fi
        compile_assembly "$2" "$ARCH"
        ;;
    *)
        print_usage
        ;;
esac