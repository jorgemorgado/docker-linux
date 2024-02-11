# Makefile

# Default image/container
NAME	?= rhel
VER		?= 8.x
TAG		?= generic

# Some examples on how to build other images:
#
# Red Hat Enterprise Linux
# 	make build; make run; make enter; make stop
# 	make build TAG=test; make run TAG=test; make enter TAG=test; make stop TAG=test
#
# CentOS
# 	make build NAME=centos VER=8.x; make run NAME=centos VER=8.x; make enter NAME=centos VER=8.x; make stop NAME=centos
#
# Fedora
#	make build NAME=fedora VER=33; make run NAME=fedora VER=33; make enter NAME=fedora VER=33; make stop NAME=fedora
#	make build NAME=fedora VER=38; make run NAME=fedora VER=38; make enter NAME=fedora VER=38; make stop NAME=fedora
#	make build NAME=fedora VER=latest; make run NAME=fedora VER=latest; make enter NAME=fedora VER=latest; make stop NAME=fedora
#
# Ubuntu
#	make build NAME=ubuntu VER=20.04 TAG=20_04; make run NAME=ubuntu VER=20.04 TAG=20_04; make enter NAME=ubuntu VER=20.04 TAG=20_04; make stop NAME=ubuntu TAG=20_04; make cleanimage NAME=ubuntu TAG=20_04
#	make build NAME=ubuntu VER=22.04; make run NAME=ubuntu VER=22.04; make enter NAME=ubuntu VER=22.04; make stop NAME=ubuntu
#
# Debian
# 	make build NAME=debian VER=10; make run NAME=debian VER=10; make enter NAME=debian VER=10; make stop NAME=debian
#
# Archlinux
#	make build NAME=archlinux VER=latest; make run NAME=archlinux; make enter NAME=archlinux; make stop NAME=archlinux
#
# Opensuse
#	make build NAME=opensuse VER=tumbleweed; make run NAME=opensuse; make enter NAME=opensuse; make stop NAME=opensuse

LXC_NAME	?= lxc-$(NAME)
DOCKERFILE	?= Dockerfile.$(NAME)-$(VER)


################################################################################
# Initial variables are assigned just once
################################################################################

shell		:= /bin/bash
BOLD		:= \033[1m
BOLDX		:= \033[0m

UID			:= $(shell id -u)
GID			:= $(shell id -g)

include setup.conf
export $(shell sed 's/=.*//' setup.conf)

# Image details
# REGISTERY	:= hub.domain.com
# ENV		:= dev
# REG_PATH	:= docker/env/$(ENV)
# IMG_NAME	:= $(REGISTERY)/$(REG_PATH)/$(LXC_NAME):$(TAG)
IMG_NAME	:= $(LXC_NAME):$(TAG)

# Container details
CT_NAME		:= $(LXC_NAME)-$(TAG)
CT_USERNAME	:= $(USERNAME)
CT_PASSWORD	:= $(PASSWORD)
CT_HOMEDIR	:= $(HOMEDIR)/

.PHONY: all
all:
	@printf "\n"; \
	 printf "\n Choose target from:\n"
	@cat Makefile | grep -E '^[a-zA-Z0-9]*:' | \
	 grep -vE '^all' | sed -e 's/:[^#]*//' | \
	 awk -F# '{if($$1==hit){printf("%s ->",b);}else{printf("%s   ",bx)}; \
	 printf(" %-10s %s\n",$$1,$$2)}' b="$(BOLD)" bx="$(BOLDX)" hit=$$lasttarget; \
	 printf "\n"

build: # build a Docker image from a Dockerfile
	@docker build \
		--build-arg username="$(CT_USERNAME)" \
		--build-arg password="$(CT_PASSWORD)" \
		--build-arg uid="$(UID)" \
		--build-arg gid="$(GID)" \
		-f $(DOCKERFILE) \
		. -t "$(IMG_NAME)"

scout: # Build a Docker image from a Dockerfile
	@docker scout quickview

run: # Create and run a new container from an image
	@docker run \
		-t --rm --privileged \
		--name "$(CT_NAME)" \
		--hostname "$(CT_NAME)" \
		-d -p "$(ct_ssh_port):22" \
		--workdir "/home/$(CT_USERNAME)" \
		-v "$(CT_HOMEDIR):/home/$(CT_USERNAME):z" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		"$(IMG_NAME)" /bin/bash

show: # List containers
	@docker ps

start: # Start a stopped container
	@docker start "$(CT_NAME)"

stop: # Stop a running container
	@docker stop "$(CT_NAME)"

root: # Enter a container as root
	@docker exec \
		-it -u 0 \
		"$(CT_NAME)" /bin/bash

enter: # Access (enter) a container
	@docker exec \
		-it -u "$(CT_USERNAME)" \
		"$(CT_NAME)" /bin/bash

clean: # Stop and remove a container
	@docker stop "${CT_NAME}"; \
	 docker image rm "${IMG_NAME}"

cleanimage: # Remove an image
	@docker image rm "$(IMG_NAME)"

cleancache: # Remove all dangling build cache
	@docker buildx prune

logs: # Fetch the logs of a container
	@docker logs "${CT_NAME}"
