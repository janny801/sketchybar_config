#!/bin/bash

# Calculate memory usage matching macOS Activity Monitor
# Used = App Memory (Anonymous - Purgeable) + Wired + Compressed
# Generates live unicode sparkline bars ( ▂▃▄▅▆▇█) tracking live resource activity

STATS=$(python3 -c "
import subprocess, re, os

CACHE_FILE = '/tmp/sketchybar_mem_sparkline.txt'
bars = [' ', '▂', '▃', '▄', '▅', '▆', '▇', '█']

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

    # Activity metric for dynamic visible variation
    ps_out = subprocess.check_output(['ps', '-A', '-o', '%cpu']).decode()
    total_cpu = sum(float(x) for x in ps_out.splitlines()[1:] if x.strip())
    cores = int(subprocess.check_output(['sysctl', '-n', 'hw.logicalcpu']).decode().strip())
    activity_ratio = min(1.0, max(0.05, total_cpu / (cores * 75)))

    history = []
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r') as f:
                history = [float(x.strip()) for x in f.readlines() if x.strip()]
        except:
            history = []

    history.append(activity_ratio)
    history = history[-14:]
    with open(CACHE_FILE, 'w') as f:
        for h in history:
            f.write(f'{h}\n')

    display_hist = history[:]
    while len(display_hist) < 14:
        display_hist.insert(0, 0.05)

    def to_bar(val):
        idx = int(val * (len(bars) - 1))
        return bars[max(0, min(len(bars)-1, idx))]

    sparkline = ''.join(to_bar(v) for v in display_hist)

    print(f'{used_gb:.2f}G/{total_gb:.2f}G {sparkline}')
except Exception as e:
    print('0.00G/0.00G              ')
")

MEM_STR=$(echo "$STATS" | awk '{print $1}')
BARS_STR=$(echo "$STATS" | cut -d ' ' -f 2-)

ICON="󰍛"

# Update memory text and bars
sketchybar --set "$NAME" icon="$ICON" label="Mem used: $MEM_STR" \
           --set memory_graph label="$BARS_STR"
