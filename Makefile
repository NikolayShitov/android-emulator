SHELL := /bin/bash
ALIAS = "android"
EXISTS := $(shell docker ps -a -q -f name=$(ALIAS))
RUNNED := $(shell docker ps -q -f name=$(ALIAS))
ifneq "$(RUNNED)" ""
IP := $(shell docker inspect $(ALIAS) | grep "IPAddress\"" | head -n1 | cut -d '"' -f 4)
endif
STALE_IMAGES := $(shell docker images | grep "<none>" | awk '{print($$3)}')
EMULATOR ?= "API28"
ARCH ?= "x86_64"

COLON := :

.PHONY = all run ports kill ps

run: clean
	@docker run -e "ANDROID_EMULATOR_API_VERSION_FOR_START=$(EMULATOR)" --privileged \
	 -p 5037:5037 \
	 -p 5554:5554 \
	 -p 5555:5555 \
	 -p 80:80 \
	 -p 443:443 \
	 -p 5902:5902 \
	 --log-driver=json-file dtdservices/android-emulator\:v1.0.2

ports:
ifneq "$(RUNNED)" ""
	$(eval ADBPORT := $(shell docker port $(ALIAS) | grep '5555/tcp' | awk '{split($$3,a,"$(COLON)");print a[2]}'))
	@echo -e "Use:\n adb kill-server\n adb connect $(IP):$(ADBPORT)"
	@echo -e "or\n adb connect 0.0.0.0:$(ADBPORT)"
else
	@echo "Run container"
endif

clean: kill
	@docker ps -a -q | xargs -n 1 -I {} docker rm -f {}
ifneq "$(STALE_IMAGES)" ""
	@docker rmi -f $(STALE_IMAGES)
endif

kill:
ifneq "$(RUNNED)" ""
	@docker kill $(ALIAS)
endif

ps:
	@docker ps -a -f name=$(ALIAS)

all:
	@docker build -t dtdservices/android-emulator\:v1.0.2 .
	@docker images
