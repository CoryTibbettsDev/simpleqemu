#!/bin/sh

prog="simpleqemu"

# Default variables
qemu_cmd="qemu-system-x86_64"

drive_file=
cdrom_file=

boot_options="-boot menu=on"

cpu=
vcpus=2
cpu_options="-smp ${vcpus}"
kvm=0
# Default memory allocated with qemu-system-x86_64 appears to be too small and
# causes kernel panic with linux -m 2G worked not sure how little you can give
memory="2G"
memory_options="-m ${memory}"

# video_options="-vga virtio -display gtk,gl=on"
video_options="-vga virtio -display sdl,gl=on"

port_forwarding=0
forward_port=2222
qemu_monitoring=0
monitor_port=55555

extra_options=

usage() {
	cat << EOF
Example usage: ${prog} --drive-file example.qcow2
EOF
}

# Parse command-line parameters
if [ "$#" -lt 1 ]; then
	usage
	exit 0
else
	while [ "$#" -gt 0 ]; do
		case "${1}" in
			-h|--help)
				usage
				exit 0
				;;
			-e|--extra-options)
				extra_options="${extra_options} ${2}"
				shift; shift
				;;
			-b|--boot_options)
				boot_options="${2}"
				shift; shift
				;;
			-d|--drive-file)
				drive_file="${2}"
				shift; shift
				;;
			-r|--cdrom)
				cdrom_file="${2}"
				shift; shift
				;;
			--qemu-command)
				qemu_cmd="${2}"
				shift; shift
				;;
			--cpu)
				# Only change cpu if it is null so --enable-kvm setting cpu to
				# host is not overriden
				cpu="${cpu:-${2}}"
				shift; shift
				;;
			--vcpus)
				vcpus="${2}"
				shift; shift
				;;
			-m|--ram)
				memory="${2}"
				shift; shift
				;;
			-f|--forward)
				port_forwarding=1
				shift
				;;
			--monitor)
				qemu_monitoring=1
				shift
				;;
			-P|--monitor-port)
				monitor_port="${2}"
				shift; shift
				;;
			-p|--forwarding-port)
				forward_port="${2}"
				port_forwarding=1
				shift; shift
				;;
			-k|--enable-kvm)
				kvm=1
				cpu="host"
				shift
				;;
			*)
				printf "ERROR: \"%s\" is not a supported parameter\n" "${1}"
				usage
				exit 1
				;;
		esac
	done
fi

# Contruct our command from all the options specified
full_cmd="${qemu_cmd}"

[ -n "${boot_options}" ] && full_cmd="${full_cmd} ${boot_options}"
[ -n "${cpu_options}" ] && full_cmd="${full_cmd} ${cpu_options}"
[ -n "${video_options}" ] && full_cmd="${full_cmd} ${video_options}"
[ -n "${memory_options}" ] && full_cmd="${full_cmd} ${memory_options}"

if [ -n "${drive_file}" ]; then
	full_cmd="${full_cmd} -drive file=${drive_file},format=raw,index=0,media=disk"
else
	printf "ERROR: need a non null drive file\n" "${1}"
	usage
	exit 1
fi
[ -n "${cdrom_file}" ] && full_cmd="${full_cmd} -cdrom ${cdrom_file}"

[ "${kvm}" -eq 1 ] && full_cmd="${full_cmd} -enable-kvm"
[ -n "${cpu}" ] && full_cmd="${full_cmd} -cpu ${cpu}"

[ "${port_forwarding}" -eq 1 ] &&
	full_cmd="${full_cmd} -netdev user,id=net0,hostfwd=tcp::${forward_port}-:22 -device e1000,netdev=net0"
[ "${qemu_monitoring}" -eq 1 ] &&
	full_cmd="${full_cmd} -monitor tcp:127.0.0.1:${monitor_port},server,nowait"

[ -n "${extra_options}" ] && full_cmd="${full_cmd} ${extra_options}"

printf "=====\nGenerated QEMU command is:\n%s\n=====\n" "${full_cmd}"
eval "${full_cmd}"
