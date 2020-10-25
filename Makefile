#Makefile used for bukkit project generation for Plugins ide

#Edit this by typing PROJECT=your_name / VERSION=target_version on make command
PROJECT=NONE
VERSION=NONE
AUTHOR=Ludrak
PROJECT_VERSION=1.0.0

SPIGOT_FOLDER=Spigot-Builds
SPIGOT_JAR=$(SPIGOT_FOLDER)/spigot-$(VERSION).jar

VS_PROJECT=Builder/vscode-default

SERVER_ARGS=-Xms1024M -Xmx1024M
RUN_SERVER=java $(SERVER_ARGS) -jar spigot-$(VERSION).jar nogui

all:
	@echo "Spigot builder tool for Plugins\n"
	@echo " make install VERSION=target_version\n -> Install the  specified spigot version and creates a new server.\n    (You will need to accept the eula to actually run it.)\n"
	@echo " make runsrv VERSION=target_version\n -> Runs a server on specified version. If spigot wasn't installed,\n    it will install it automatially.\n"
	@echo " make project VERSION=target_version PROJECT=project_name\n -> Creates an Plugins project for the targeted version.\n"
	@echo "\n - DANGER ZONE -\n"
	@echo " make delete VERSION=target_version PROJECT=project_name\n -> deletes a project in specified version.\n"
	@echo " make deletebuilds\n -> deletes all cached spigot versions\n"
	@echo " make deleteversion VERSION=target_version\n -> deletes a specified version.\n    /!\\ This will delete all Plugins projects related to this version /!\\ \n"
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

project: $(SPIGOT_JAR) setup_vscode
	@printf "Sucessfully created project : $(PROJECT)\n"

delete:
	@if [ $(PROJECT) = NONE -o $(VERSION) = NONE ] ; then \
		printf "[DELETE ERROR] : You must specify a version and project name.\nNot deleted.\n\n" ; \
		exit 1 ; \
	fi
	@rm -rf $(VERSION)/Plugins/$(PROJECT)

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
	@read input ; if [ $$input = Y -o $$input = y ] ; then \
		rm -rf 1.* ; \
		printf "\nAll files deleted.\n" ; \
	else \
		printf "\nCanceled.\n" ; \
	fi

build:
	@javac -d $(VERSION)/Plugins/$(PROJECT)/bin -cp ".:./$(SPIGOT_JAR)" $(shell find . | grep .java)
	@printf "Sucessfully compiled project bins.\n"
	@cd $(VERSION)/Plugins/$(PROJECT)/ && ant
	@cp -r $(VERSION)/Plugins/$(PROJECT)/target/$(PROJECT).jar $(VERSION)/Server/plugins/$(PROJECT).jar
	@printf "Build Sucessfully installed on Server.\n"



setup_vscode:
	@if [ $(PROJECT) = NONE -o $(VERSION) = NONE ] ; then\
		printf "[Plugins SETUP ERROR] : You must specify a project name.\n\n" ;  \
		exit 1 ; \
	fi
	@printf "Setting up $(PROJECT) for vscode...\n"
	@mkdir -p $(VERSION)/Plugins/
	@cp -r $(VS_PROJECT)/ $(VERSION)/Plugins/$(PROJECT)/
	@sed -i "s/PROJECT_NAME/$(PROJECT)/g" $(VERSION)/Plugins/$(PROJECT)/plugin.yml
	@sed -i "s/VERSION_HERE/$(PROJECT_VERSION)/g" $(VERSION)/Plugins/$(PROJECT)/plugin.yml
	@sed -i "s/AUTHOR_HERE/$(AUTHOR)/g" $(VERSION)/Plugins/$(PROJECT)/plugin.yml

	@sed -i "s/PROJECT_NAME/$(PROJECT)/g" $(VERSION)/Plugins/$(PROJECT)/build.xml


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
