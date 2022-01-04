## FlintOS overlay
1. Change flash logo
   chromeos-base/flintos-assets
2. Create hardware porting overlay structures
   chromeos-base/flintos-arch-spec
   chromeos-base/flintos-chip-spec
   chromeos-base/flintos-board-spec
   chromeos-base/flintos-variant-spec

# How to build different Flint OS editions

## What are editions

We create and release different Flint OS for PC images with different features and configurations. It is mainly for pre-installing different apps/extensions/programs for different regions or group of users. See this [Flint OS Editions Matrix page](https://docs.google.com/spreadsheets/d/1E8ATsK9ve9xRi_KjFEu2slqxuGJcmsMpTfurNkXfxXM/edit#gid=0) for up to date editions list and their feature differences.

## How it is implemented

By making use of the portage USE feature, we can make a specific ebuild in our overlay behave differently in below aspects, if different USE flags are set:

1. Pull in different packages for dependency, thus have different packages installed.

2. Install different files.

3. Enable different build time features.

### In the top level project-flintos overlay

A list of editions we support is defined by the ```FLINTOS_EDITIONS``` use expand flag, in ```profiles/base/make.defaults``` of this overlay. See [this page](https://devmanual.gentoo.org/general-concepts/use-flags/index.html) for what is use expand flag and how to use them.

### In board overlays

In the amd64-flint overlay, several ```editions_*.conf``` files in the top level directory defines what features of each edition should be enabled, according to the editions matrix page above. For example, definition for the ```uk_customer``` edition is in the file ```editions_uk_customer.conf``` file and its content is as below:

```
# This is the edition name
FLINTOS_EDITIONS="uk_customer"

# This is the features should be enabled/disabled for this edition
USE="${USE} chrome_media droplet -docker -shadowsocks flint_daemon flint_policy -psmouse_imps"
```

Then in the ```make.conf``` file in the amd64-flint overlay, one(and only one) of the ```editions_*.conf``` file is sourced in, to instruct which specific edition to build. Content in ```make.conf``` looks like below:

```
... other contents ...
source editions_uk_customer.conf
```

This means the ```uk_customer``` editions will be built.

Besides of overlay-amd64-flint, overlay-tinker is also configured in such way.

### In package ebuilds

Package ebuilds interact with editions in two ways.

#### If the package itself is edition agnostic, it is only about whether a edition should include this package or not

When such packages is pulled in by its depender, the dynamic dependencies feature(see ```man 5 ebuild```) is used to control whether it will be installed. For example, in ```virtual/chromeos-bsp``` ebuild:

```
flint_policy? ( chromeos-base/flintos-group-policy )
flint_daemon? ( net-misc/flint_daemon )
shadowsocks? ( net-proxy/shadowsocks-libev )
```

The USE flags defined in ```editions_*.conf``` files make ```virtual/chromeos-bsp``` ebuild decide whether these packages will be installed or not.

#### If the package itself need to be build differently for different editions

For packages that need to behave differently for different editions, USE flags such as ```flintos_editions_<edition_name>``` are used in their ebuild to control the different logics for different editions.

For example, if ```FLINTOS_EDITIONS=vanilla``` is defined, then portage will automatically set a use flag ```flintos_editions_vanilla```. Ebuilds then can detect this use flag and act accordingly.

The ```chromeos-base/chromeos-chrome``` ebuild is one of such packages.

## How to build different editions

First source correct ```editions_*.conf``` file in amd64-flint/make.conf.

Then build package.

```
./build_packages --board=amd64-flint --nousepkg
```

Then build image as usual. The images for the specific edition will be generated.

If need to build for another edition later, just modify the sourced edition file in make.conf, then re-run the build_packages script. It will rebuild necessary packages that have USE flags changed. The list of packages that need to be rebuilt is usually short, most of the packages remain the same and no rebuild is required.

After build packages for a different edition is finished, build image as usual.