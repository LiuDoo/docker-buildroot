#!/bin/bash
# Start container and start process inside container.
#
# Example:
#   ./run.sh firmware_name            Start a sh shell inside container for specified firmware.
#   ./run.sh firmware_name ls -la     Run `ls -la` inside container for specified firmware.
#
# Calls to `make` are intercepted and the "O=/buildroot_output_{firmware_name}" is added to
# command. So calling `./run.sh my_firmware make savedefconfig` will run `make
# savedefconfig O=/buildroot_output_my_firmware` inside the container.
#
# Example:
#   ./run.sh my_firmware make       Run `make O=/buildroot_output_my_firmware` in container.
#   ./run.sh my_firmware make docker_python2_defconfig menuconfig
#                       Build config based on docker_python2_defconfig for my_firmware.
#
# When working with Buildroot you probably want to create a config, build
# some products based on that config and save the config for future use.
# Your workflow will look something like this:
#
# ./run.sh my_firmware make docker_python2_defconfig defconfig
# ./run.sh my_firmware make menuconfig
# ./run.sh my_firmware make BR2_DEFCONFIG=/root/buildroot/external/configs/docker_python2_defconfig savedefconfig
# ./run.sh my_firmware make
set -e

# Check if firmware name is provided
if [ -z "$1" ]; then
    echo "Error: Firmware name must be provided as the first argument"
    echo "Usage: $0 <firmware_name> [command]"
    exit 1
fi

FIRMWARE_NAME=$1
shift

# Set output directory based on firmware name
OUTPUT_DIR="/buildroot_output_${FIRMWARE_NAME}"
BUILDROOT_DIR=/root/buildroot
BUILDROOT_DL=buildroot_dl
# Create output volume if it doesn't exist
if ! docker volume inspect buildroot_output_${FIRMWARE_NAME} &>/dev/null; then
    echo "Creating volume buildroot_output_${FIRMWARE_NAME}"
    docker volume create buildroot_output_${FIRMWARE_NAME}
fi

# Create dl volume if it doesn't exist
if ! docker volume inspect ${BUILDROOT_DL} &>/dev/null; then
    echo "Creating volume ${$BUILDROOT_DL}"
    docker volume create {$BUILDROOT_DL}
fi

# Run the container with appropriate volumes
DOCKER_RUN="docker run
    -ti
    --mount source=buildroot_output_${FIRMWARE_NAME},target=${OUTPUT_DIR}
    --mount source=$BUILDROOT_DL,target=${BUILDROOT_DIR}/dl
    -v $(pwd)/data:${BUILDROOT_DIR}/data
    -v $(pwd)/external:${BUILDROOT_DIR}/external
    -v $(pwd)/rootfs_overlay:${BUILDROOT_DIR}/rootfs_overlay
    -v $(pwd)/images_${FIRMWARE_NAME}:${OUTPUT_DIR}/images
    -e O=${OUTPUT_DIR}
    advancedclimatesystems/buildroot"

make() {
    echo "make O=$OUTPUT_DIR"
}

echo "Building firmware: ${FIRMWARE_NAME}"
echo "Output directory: ${OUTPUT_DIR}"
echo $DOCKER_RUN

if [ "$1" == "make" ]; then
    eval $DOCKER_RUN $(make) ${@:2}
else
    eval $DOCKER_RUN $@
fi
