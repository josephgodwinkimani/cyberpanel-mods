#!/usr/bin/env python3
# This script will monitor kworker processes and terminate any that exceed a specified CPU usage threshold

import os
import time
import subprocess

# CPU usage threshold
THRESHOLD = 80


def get_kworker_processes(threshold):
    """Get a list of kworker processes exceeding the CPU usage threshold."""
    # Run the ps command to get process information
    result = subprocess.run(
        ["ps", "-e", "-o", "pid,comm,pcpu"], capture_output=True, text=True
    )

    # Split the output into lines and filter for kworker processes
    processes = []
    for line in result.stdout.splitlines()[1:]:  # Skip the header line
        parts = line.split()
        if len(parts) >= 3:
            pid = parts[0]
            command = parts[1]
            cpu_usage = float(parts[2])
            if command.startswith("kworker") and cpu_usage > threshold:
                processes.append((pid, cpu_usage))

    return processes


def kill_process(pid):
    """Kill the process with the given PID."""
    try:
        os.kill(int(pid), 9)  # Send SIGKILL signal
        print(f"Killed kworker process with PID {pid}")
    except Exception as e:
        print(f"Failed to kill process {pid}: {e}")


def main():
    """Main function to monitor kworker processes."""
    while True:
        kworker_processes = get_kworker_processes(THRESHOLD)

        for pid, cpu_usage in kworker_processes:
            print(f"Killing kworker process with PID {pid}, CPU usage: {cpu_usage}%")
            kill_process(pid)

        time.sleep(5)  # Sleep for a few seconds before checking again


if __name__ == "__main__":
    main()
