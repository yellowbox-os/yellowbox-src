# Makefile

check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

install: system local

system: check_root
	@if [ -d "/System" ]; then \
	  echo "YellowBox System Domain appears to be already installed."; \
	  exit 0; \
	else \
	  WORKDIR=`pwd`; \
	  mkdir -p /System/Library; \
	  cp -R Library/* /System/Library; \
	  . /System/Library/Preferences/GNUstep.conf; \
	  CPUS=`nproc`; \
	  export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	  echo "CPUS is set to: $$CPUS"; \
	  echo "GNUSTEP_INSTALLATION_DOMAIN is set to: $$GNUSTEP_INSTALLATION_DOMAIN"; \
	  echo "WORKDIR is set to: $$WORKDIR"; \
	  cd $$WORKDIR/tools-make && ./configure \
	    --enable-importing-config-file \
	    --with-config-file=/System/Library/Preferences/GNUstep.conf \
	    --with-library-combo=ng-gnu-gnu \
	  && gmake || exit 1 && gmake install; \
	  . /System/Library/Makefiles/GNUstep.sh; \
	  mkdir -p $$WORKDIR/libobjc2/Build; \
	  cd $$WORKDIR/libobjc2/Build && pwd && ls && cmake .. \
	    -DGNUSTEP_INSTALL_TYPE=SYSTEM \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DCMAKE_C_COMPILER=clang \
	    -DCMAKE_CXX_COMPILER=clang++; \
	  gmake -j"${CPUS}" || exit 1; \
	  gmake install; \
	  cd $$WORKDIR/libs-base && ./configure --with-installation-domain=SYSTEM && gmake -j"${CPUS}" || exit 1 && gmake install && gmake clean; \
	  cd $$WORKDIR/libs-gui && ./configure && gmake -j"${CPUS}" || exit 1 || exit 1 && gmake install; \
	  cd $$WORKDIR/libs-back && export fonts=no && ./configure && gmake -j"${CPUS}" || exit 1 && gmake install; \
	  cd $$WORKDIR/apps-gworkspace && ./configure && gmake && gmake install; \
          cd $$WORKDIR/plugins-themes-nesedahrik/NesedahRik.theme && gmake && gmake install && gmake clean; \
	fi;

local: check_root
	@if [ -d "/Local" ]; then \
          echo "YellowBox Local Domain appears to be already installed."; \
          exit 0; \
        else \
          WORKDIR=`pwd`; \
          CPUS=`nproc`; \
	  . /System/Library/Makefiles/GNUstep.sh; \
          export GNUSTEP_INSTALLATION_DOMAIN="LOCAL"; \
          echo "CPUS is set to: $$CPUS"; \
          echo "GNUSTEP_INSTALLATION_DOMAIN is set to: $$GNUSTEP_INSTALLATION_DOMAIN"; \
          echo "WORKDIR is set to: $$WORKDIR"; \
          cd $$WORKDIR/gs-desktop/Applications/WrapperFactory && gmake && gmake install; \
	  mkdir /Local/Applications/Firefox.app && cp -R $$WORKDIR/gs-desktop/extra-apps/Firefox.app/* /Local/Applications/Firefox.app/; \
        fi;


uninstall: check_root
	@removed=""; \
	if [ -d "/System" ]; then \
	  rm -rf /System; \
	  removed="/System"; \
	  echo "Removed YellowBox System Domain /System"; \
	fi; \
	if [ -d "/Local" ]; then \
	  rm -rf /Local; \
	  removed="$$removed /Local"; \
	  echo "Removed YellowBox Local Domain /Local"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  echo "Uninstallation complete: $$removed"; \
	else \
	  echo "YellowBox appears to be already uninstalled. Nothing was removed."; \
	fi
