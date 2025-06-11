# Buildroot
A Docker image for using [Buildroot][buildroot]. It can be found on [Docker
Hub][hub]. This version supports building multiple firmware images in parallel.

## Get started
To get started build the Docker image.

``` shell
$ docker build -t "advancedclimatesystems/buildroot" .
```

The system will automatically create Docker volumes when needed:
- A shared download volume `buildroot_dl` at `/root/buildroot/dl`
- Separate output volumes for each firmware named `buildroot_output_{firmware_name}` at `/buildroot_output_{firmware_name}`

Each firmware will have its own build cache, cross compiler and build results, but all will share the same download directory to save resources.

## Usage
A small script has been provided to make using the container a little easier.
It's located at [scripts/run.sh][run.sh]. You must provide a firmware name as the first argument.
Instructions below show how to build a kernel for the Raspberry Pi using the defconfig provided by Buildroot.

``` shell
$ ./scripts/run.sh rpi make raspberrypi2_defconfig menuconfig
$ ./scripts/run.sh rpi make
```

Build products are stored inside the container at `/buildroot_output_{firmware_name}/images`.
Because `run.sh` mounts the local folder `images/` at this place, the
build products are also stored on the host.

### Building Multiple Firmware Images in Parallel

You can build multiple firmware images in parallel by running multiple instances of the script with different firmware names:

```shell
# Terminal 1
$ ./scripts/run.sh rpi make raspberrypi2_defconfig
$ ./scripts/run.sh rpi make

# Terminal 2
$ ./scripts/run.sh qemu_arm make qemu_arm_versatile_defconfig
$ ./scripts/run.sh qemu_arm make
```

Each firmware will have its own isolated build environment, but they will share the same download directory.

## Build with existing config
It is possible to build from a custom configuration. To demonstrate this, the
repository contains a configuration to build a minimal root filesystem, around
25 mb, with Python 2. This config is located at
[external/configs/docker_python2_defconfig][docker_python2_defconfig].

The `external/` directory contains a set of modifications for Buildroot. The
modifications can be applied with the environment variable `BR2_EXTERNAL`.
Read [here][br2_external] more about customizations of Buildroot.

```shell
$ ./scripts/run.sh python2 make "BR2_EXTERNAL=/root/buildroot/external docker_python2_defconfig menuconfig"
$ ./scripts/run.sh python2 make
```

If you've modified the configuration using `menuconfig` and you want to save
those changes run:

```shell
$ ./scripts/run.sh python2 make BR2_DEFCONFIG=/root/buildroot/external/configs/docker_python2_defconfig savedefconfig
```
## Docker image from root fileystem
Import the root filesystem in to Docker to create an image, run it and start
a container. Note that the images are now stored in the output directory for each firmware.

```shell
# If using the host's images directory
$ docker import - dietfs < images/rootfs.tar
$ docker run --rm -ti dietfs sh

# Or directly from the container volume
$ docker import - dietfs < /buildroot_output_{firmware_name}/images/rootfs.tar
$ docker run --rm -ti dietfs sh
```
## License
This software is licensed under Mozila Public License.
&copy; 2017 Auke Willem Oosterhoff and [Advanced Climate Systems][acs].

[acs]:http://advancedclimate.nl
[buildroot]:http://buildroot.uclibc.org/
[data-only]:https://docs.docker.com/userguide/dockervolumes/
[hub]:https://hub.docker.com/r/advancedclimatesystems/docker-buildroot/builds/
[run.sh]:scripts/run.sh
[docker_python2_defconfig]:external/configs/docker_python2_defconfig
[br2_external]:http://buildroot.uclibc.org/downloads/manual/manual.html#outside-br-custom
[docker_blog]:https://blog.docker.com/2013/06/create-light-weight-docker-containers-buildroot/
