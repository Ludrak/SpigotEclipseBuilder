#Makefile used for bukkit project generation for eclipse ide

#Edit this by typing PROJECT=your_name / VERSION=target_version on make command
PROJECT=NONE
VERSION=NONE

SPIGOT_FOLDER=Spigot-Builds
SPIGOT_JAR=$(SPIGOT_FOLDER)/spigot-$(VERSION).jar

ECLIPSE_PROJECT=Builder/eclipse-default

SERVER_ARGS=-Xms1G -Xmx1G -XX:+UseG1GC
RUN_SERVER=java $(SERVER_ARGS) -jar spigot-$(VERSION).jar nogui

all:
	@echo "Spigot builder tool for eclipse\n"
	@echo " make install VERSION=target_version\n -> Install the  specified spigot version and creates a new server.\n    (You will need to accept the eula to actually run it.)\n"
	@echo " make runsrv VERSION=target_version\n -> Runs a server on specified version. If spigot wasn't installed,\n    it will install it automatially.\n"
	@echo " make project VERSION=target_version PROJECT=project_name\n -> Creates an eclipse project for the targeted version.\n"
	@echo "\n - DANGER ZONE -\n"
	@echo " make delete VERSION=target_version PROJECT=project_name\n -> deletes a project in specified version.\n"
	@echo " make deletebuilds\n -> deletes all cached spigot versions\n"
	@echo " make deleteversion VERSION=target_version\n -> deletes a specified version.\n    /!\\ This will delete all eclipse projects related to this version /!\\ \n"
	@echo " make deleteall\n -> Ultimate clean command, remove all created files including all versions and spigot jars\n"

install: $(SPIGOT_JAR)
	@printf "Sucessfully installed Spigot $(VERSION)\n"
	@printf "Setting up spigot server for $(VERSION)\n"
	@cd $(VERSION)/Server/ && $(RUN_SERVER)

runsrv:
	@if [ $(VERSION) = NONE ] ; then \
		printf "[RUN ERROR] : You must specify a version.\n\n" ; \
		exit 1 ; \
	fi
	@cd $(VERSION)/Server/ && $(RUN_SERVER)

project: $(SPIGOT_JAR) get_eclipse
	@printf "Sucessfully created project : $(PROJECT)\n"

delete:
	@if [ $(PROJECT) = NONE -o $(VERSION) = NONE ] ; then \
		printf "[DELETE ERROR] : You must specify a version and project name.\nNot deleted.\n\n" ; \
		exit 1 ; \
	fi
	@rm -rf $(VERSION)/Eclipse/$(PROJECT)

deletebuilds:
	@rm -rf $(SPIGOT_FOLDER)

deleteversion:
	@if [ $(VERSION) = NONE ] ; then \
		printf "[DELETE ERROR] : You must specify a version.\nNot deleted.\n\n" ; \
		exit 1 ; \
	fi
	@rm -rf $(VERSION)

deleteall: deletebuilds
	@printf "This will delete all content created for all versions.\nAre you sure ? (Y/N) : "
	@read input ; if [ $$input = Y ] ; then \
		rm -rf 1.* ; \
		printf "\nAll files deleted.\n" ; \
	else \
		printf "\nCanceled.\n" ; \
	fi

get_eclipse:
	@if [ $(PROJECT) = NONE -o $(VERSION) = NONE ] ; then\
		printf "[ECLIPSE SETUP ERROR] : You must specify a project name.\n\n" ;  \
		exit 1 ; \
	fi
	@mkdir -p $(VERSION)/Eclipse/
	@printf "Setting up eclipse project...\n"
	@cp -r $(ECLIPSE_PROJECT)/ $(VERSION)/Eclipse/$(PROJECT)/
	@sed -i "s/VERSION_HERE/$(VERSION)/g" $(VERSION)/Eclipse/$(PROJECT)/.classpath
	@sed -i "s+ROOT_PATH+$(shell pwd)/$(SPIGOT_FOLDER)+g" $(VERSION)/Eclipse/$(PROJECT)/.classpath

##	SPIGOT JAR DOWNLOAD
$(SPIGOT_JAR): $(SPIGOT_FOLDER)
	@if [ $(VERSION) = NONE ] ; then\
		printf "[JAR INSTALL ERROR] : You must specify a version.\n\n" ; \
		exit 1 ; \
	fi
	@printf "Setting up spigot for : %s ...\n" "$(VERSION)"
	@mkdir -p $(VERSION)
	@mkdir -p $(VERSION)/Server
	@wget -O $</spigot-$(VERSION).jar https://cdn.getbukkit.org/spigot/spigot-$(VERSION).jar
	@cp -r $</spigot-$(VERSION).jar $(VERSION)/Server/

$(SPIGOT_FOLDER):
	@mkdir -p $@
