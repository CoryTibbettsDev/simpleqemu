#!/bin/sh

# Create image with the "qemu-img create" command

program_name="$0"

# Default variables
qemu_cmd="qemu-system-x86_64"

drive_file=
cdrom_file=

boot_options="-boot menu=on"

cpu="host"
vcpus="2"
cpu_options="-cpu ${cpu} -smp ${vcpus}"
# Default memory allocated with qemu-system-x86_64 appears to be too small and
# causes kernel panic with linux -m 2G worked not sure how little you can give
memory="2G"
memory_options="-m ${memory}"

video_options="-vga virtio -display sdl,gl=on"
audio_options="-soundhw all"
av_options="${video_options} ${audio_options}"

port_forwarding=
forward_port="2222"
qemu_monitoring=
monitor_port="55555"

usage() {
	cat << EOF
Usage
Test
EOF
}

# Parse command-line parameters
if [ $# -lt 1 ]; then
	usage
	exit 0
else
	while [ $# -gt 0 ]; do
		case "${1}" in
			-h|--help)
				usage
				exit 0
				;;
			-d|--disk)
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
				cpu="${2}"
				shift
				;;
			--vcpus)
				vcpus="${2}"
				shift
				;;
			--ram)
				memory="${2}"
				shift; shift
				;;
			-f|--forward)
				port_forwarding="true"
				shift
				;;
			--monitor)
				qemu_monitoring="true"
				shift
				;;
			-P)
				monitor_port="${2}"
				shift; shift
				;;
			-p)
				forward_port="${2}"
				shift; shift
				;;
			*)
				printf "ERROR! \"%s\" is not a supported parameter\n" "${1}"
				usage
				exit 1
				;;
		esac
	done
fi

# Options must be set after all options have had a chance to change from
# command line parameters
full_cmd="${qemu_cmd} -enable-kvm ${boot_options} ${cpu_options} ${memory_options} ${av_options} -drive file=${drive_file}"

[ -n "${cdrom_file}" ] && full_cmd="${full_cmd} -cdrom ${cdrom_file}"
[ "${port_forwarding}" = true ] &&
	full_cmd="${full_cmd} -netdev user,id=net0,hostfwd=tcp::${forward_port}-:22 -device e1000,netdev=net0"
[ "${qemu_monitoring}" ] &&
	full_cmd="${full_cmd} -monitor tcp:127.0.0.1:${monitor_port},server,nowait"

printf "QEMU command: %s\n" "${full_cmd}"
${full_cmd}
