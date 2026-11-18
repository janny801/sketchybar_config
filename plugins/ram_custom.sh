#!/bin/bash

# Calculate memory usage matching macOS Activity Monitor
# Used = App Memory (Anonymous - Purgeable) + Wired + Compressed

STATS=$(python3 -c "
import subprocess, re

try:
    total_bytes = int(subprocess.check_output(['sysctl', '-n', 'hw.memsize']).decode().strip())
    vm_out = subprocess.check_output(['vm_stat']).decode()
    page_size = 4096
    stats = {}

    for line in vm_out.splitlines():
        m = re.search(r'page size of (\d+) bytes', line)
        if m:
            page_size = int(m.group(1))
            continue
        parts = line.split(':')
        if len(parts) == 2:
            k = parts[0].strip().strip('\"')
            v = parts[1].strip().rstrip('.')
            if v.isdigit():
                stats[k] = int(v)

    app_mem = (stats.get('Anonymous pages', 0) - stats.get('Pages purgeable', 0)) * page_size
    wired = stats.get('Pages wired down', 0) * page_size
    compressed = stats.get('Pages occupied by compressor', 0) * page_size
    used_bytes = app_mem + wired + compressed

    ratio = max(0.0, min(1.0, used_bytes / total_bytes))
    used_gb = used_bytes / (1024**3)
    total_gb = total_bytes / (1024**3)

    print(f'{ratio:.3f} {used_gb:.2f}G/{total_gb:.2f}G')
except Exception:
    print('0.000 0.00G/0.00G')
")

RATIO=$(echo "$STATS" | awk '{print $1}')
MEM_STR=$(echo "$STATS" | awk '{print $2}')

ICON="󰍛"

# Update memory text and push live data point to memory_graph
sketchybar --set "$NAME" icon="$ICON" label="Mem used: $MEM_STR" \
           --push memory_graph "$RATIO"
