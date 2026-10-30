state=${XDG_RUNTIME_DIR:-/tmp}/eww-gpu-idle

# CPU temperature from the first known sensor.
cpu_temp=""
for hwmon in /sys/class/hwmon/hwmon*; do
  case $(<"$hwmon/name") in
    coretemp | k10temp | zenpower)
      cpu_temp=$(($(<"$hwmon/temp1_input") / 1000))
      break
      ;;
  esac
done

# Busy percentage from an idle-time counter in milliseconds, using the
# value saved by the previous run.
busy_from_idle() {
  local idle=$1 now last_idle last_now
  now=$(date +%s%3N)
  read -r last_idle last_now 2>/dev/null <"$state" || true
  echo "$idle $now" >"$state"
  if [[ -n ${last_now:-} && $now -gt $last_now ]]; then
    local busy=$((100 - 100 * (idle - last_idle) / (now - last_now)))
    ((busy < 0)) && busy=0
    echo "$busy"
  fi
}

# GPU: NVIDIA through nvidia-smi, AMD and Intel through sysfs. Only polled
# while the info panel is open, nvidia-smi wakes up a sleeping GPU.
gpu_name="" gpu_usage="" gpu_temp=""
if command -v nvidia-smi >/dev/null; then
  gpu_name="NVIDIA"
  IFS=', ' read -r gpu_usage gpu_temp < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | head -n 1)
else
  for card in /sys/class/drm/card[0-9]; do
    if [[ -r $card/device/gpu_busy_percent ]]; then
      gpu_name="AMD"
      gpu_usage=$(<"$card/device/gpu_busy_percent")
      for hwmon in "$card"/device/hwmon/hwmon*; do
        [[ -r $hwmon/temp1_input ]] && gpu_temp=$(($(<"$hwmon/temp1_input") / 1000))
      done
      break
    elif [[ -r $card/gt/gt0/rc6_residency_ms ]]; then
      gpu_name="Intel"
      gpu_usage=$(busy_from_idle "$(<"$card/gt/gt0/rc6_residency_ms")")
      break
    elif [[ -r $card/device/tile0/gt0/gtidle/idle_residency_ms ]]; then
      gpu_name="Intel"
      gpu_usage=$(busy_from_idle "$(<"$card/device/tile0/gt0/gtidle/idle_residency_ms")")
      break
    fi
  done
fi

jq -n -c \
  --arg cpu_temp "$cpu_temp" \
  --arg gpu_name "$gpu_name" --arg gpu_usage "$gpu_usage" --arg gpu_temp "$gpu_temp" \
  '{cpu_temp: $cpu_temp, gpu: {name: $gpu_name, usage: $gpu_usage, temp: $gpu_temp}}'
