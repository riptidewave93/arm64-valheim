# Builds the docker images, used by CI and for local builds. Variables can be
# overridden on the command line, e.g.:
#   make pi5 DOCKER=podman
#   make all NO_CACHE=1

DOCKER ?= docker
PLATFORM ?= linux/arm64
# Every image name gets the variant tags, the base image only gets the first
IMAGES ?= ghcr.io/riptidewave93/arm64-valheim docker.io/library/riptidewave93/arm64-valheim
IMAGE := $(firstword $(IMAGES))
# Set to build without cache, e.g. to pick up new Debian and box64 packages
NO_CACHE ?=

# Variant tags, with the box64 package for each. CPU_AFFINITY is only set for
# SoCs with mixed fast/slow cores, the others (pi4: 4x A72, pi5: 4x A76,
# tegra-t194: Carmel) are uniform.
VARIANTS := arm64 pi4 pi5 pi5-16k rk3588 tegra-t194
BOX64_arm64 := box64
BOX64_pi4 := box64-rpi4arm64
BOX64_pi5 := box64-rpi5arm64
BOX64_pi5-16k := box64-rpi5arm64ps16k
BOX64_rk3588 := box64-rk3588
BOX64_tegra-t194 := box64-tegra-t194
# Pin to the Cortex-A76 cores
CPU_AFFINITY_rk3588 := 4-7

REVISION := $(shell git rev-parse HEAD 2>/dev/null)
BUILD_FLAGS := --platform $(PLATFORM) $(if $(NO_CACHE),--no-cache) \
	--label org.opencontainers.image.source=https://github.com/riptidewave93/arm64-valheim \
	$(if $(REVISION),--label org.opencontainers.image.revision=$(REVISION))

.PHONY: all base $(VARIANTS) push shellcheck

all: $(VARIANTS)

# Shared base image for all variants
base:
	$(DOCKER) build $(BUILD_FLAGS) -f Dockerfile-base -t $(IMAGE):base .

$(VARIANTS): base
	$(DOCKER) build $(BUILD_FLAGS) \
		--build-arg BASE_IMAGE=$(IMAGE):base \
		--build-arg BOX64_PACKAGE=$(BOX64_$@) \
		--build-arg CPU_AFFINITY=$(CPU_AFFINITY_$@) \
		$(foreach image,$(IMAGES),-t $(image):$@) \
		.

# Pushes the images built by make all
push:
	$(DOCKER) push $(IMAGE):base
	for variant in $(VARIANTS); do \
		for image in $(IMAGES); do \
			$(DOCKER) push "$$image:$$variant" || exit 1; \
		done; \
	done

# Pinned, as newer versions add checks. Uses .shellcheckrc.
shellcheck:
	$(DOCKER) run --rm --security-opt label=disable -v "$(CURDIR):/mnt:ro" -w /mnt docker.io/koalaman/shellcheck:v0.11.0 src/*
