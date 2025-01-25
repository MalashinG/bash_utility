#!/usr/bin/env bash


show_help(){
    echo "Usage: $0 [command] [option]"
    echo ""
    echo "  -h,   --help          Show this help message"
    echo ""
    echo "  -p,   --proc          Work with /proc"
    echo "       Available options: version, cpuinfo, meminfo, uptime"
    echo "       (shows raw /proc/uptime content in seconds)                                                    "
    echo ""
    echo "  -c,   --cpu           Show CPU info"
    echo "       Available options: lscpu, usage, mpstat"
    echo ""
    echo "  -m,   --memory        Show memory info"
    echo "       Available options: free, top, swap"
    echo ""
    echo "  -d,   --disks         Show disks info"
    echo "       Available options: df, lsblk, fdisk"
    echo ""
    echo "  -n,   --network       Show network info"
    echo "       Available options: ip, netstat, ping <hostname>"
    echo ""
    echo "  -la,  --loadaverage   Show system load average"
    echo "       Available options: uptime, loadavg, w"
    echo "       (shows current time, system uptime and load average)"
    echo ""
    echo "  -k,   --kill          Kill a process"
    echo "       Available options: ps, kill <PID>, pkill <name>"
    echo ""
    echo "  -o,   --output        Save system info to file"
    echo "       Usage: $0 --output [filename] (default: output.log)"
}

if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi


process_output(){
    local filename="$1"
    if [[ -z "$filename" ]]; then
    filename="$(pwd)/output.log"
    else
        filename="$(realpath "$filename")"
    fi
    echo "Saving system info to $filename"

    {
        echo "cpu"
        lscpu
        echo "memory"
        free -h
        echo "=== Disks ==="
        lsblk
        echo "=== Network ==="
        ip a
    } > "$filename"

}

process_kill(){
    local option="$1"
    case "$option" in
    "") echo "Available options: ps, kill <PID>, pkill <name>" ;;
    ps) ps aux --sort=-%mem | head -n 10 ;;
    kill) 
    if [[ -z "$2" ]]; then
    echo "Usage: $0 -k --kill kill <PID>"
    return 1
    fi
    kill "$2" ;;
    pkill)
    if [[ -z "$2" ]]; then
    echo "Usage: $0 -k --kill pkill <name>"
    return 1
    fi
    pkill "$2" ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

process_loadaverage(){
    local option="$1"
    case "$option" in
    "") echo "Available options: uptime, loadavg, w" ;;
    uptime) uptime ;;
    loadavg) cat /proc/loadavg ;;
    w) w ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

process_network(){
    local option="$1"
    case "$option" in
    "") echo "Available options: ip, netstat, ping <hostname/IP>" ;;
    ip) ip a ;;
    netstat)
    if ! command -v netstat &>/dev/null; then
        echo "Error: netstat is not installed."
        return 1
    fi
    netstat -tulnp ;;
    ping) 
    if ! command -v ping &>/dev/null; then
        echo "Error: ping is not installed."
        return 1
    fi
    if [[ -z "$2" ]]; then
        echo "Usage: $0 -n --network ping <hostname/IP>"
        return 1
        fi
    ping -c 4 "$2" ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

process_disks(){
    local option="$1"
    case "$option" in
    "") echo "Available options: df, lsblk, fdisk" ;;
    df) sudo df -h || { echo "Error: Need sudo privileges"; return 1; } ;;
    lsblk) lsblk ;;
    fdisk) sudo fdisk -l ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac

}

process_memory(){
    local option="$1"
    case "$option" in
    "") echo "Available options: free, top, swap" ;;
    free) free -h ;;
    top) ps aux --sort=-%mem | head -n 10 ;;
    swap)   
    if ! command -v vmstat &>/dev/null; then
        echo "Error: vmstat is not installed."
        return 1
    fi
    
    echo "Swap Memory Usage:"
    for stat in "total swap memory" "used swap memory" "free swap memory"; do
        vmstat -s | grep -E "$stat"
    done
    ;;  
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

process_cpu(){
    local option="$1"
    case "$option" in
    "") echo "Available options: lscpu, usage, mpstat" ;;
    lscpu) lscpu ;;
    usage) top -bn1 |grep "Cpu(s)" ;;
    mpstat)
    if ! command -v mpstat &>/dev/null; then
        echo "Error: mpstat is not installed."
        return 1
    fi
    mpstat 1 5 ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

proc_process() {
    local option="$1"
    case "$option" in
    "") echo "Available options: version, cpuinfo, meminfo, uptime" ;;
    version) cat /proc/version ;;
    cpuinfo) cat /proc/cpuinfo ;;
    meminfo) cat /proc/meminfo ;;
    uptime) cat /proc/uptime ;;
    *)
    echo "Error: Unknown option '$option'" ;;
    esac
}

#Проверка аргументов
case "$1" in
    -h|--help) show_help ;;
    -p|--proc) proc_process "$2";;
    -c|--cpu)  process_cpu "$2";;
    -m|--memory) process_memory "$2" ;;
    -d|--disks) process_disks "$2" ;;
    -n|--network) process_network "$2" "$3" ;;
    -la|--loadaverage) process_loadaverage "$2" ;;
    -k|--kill) process_kill "$2" "$3";;
    -o|--output) process_output "$2" ;;
    *)
    echo "Error: Unknown option '$1'" ;;
esac


