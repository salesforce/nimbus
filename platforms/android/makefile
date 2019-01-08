# makefile for ios
#
# this file is not meant to be used directly but as an include in the top-level makefile

# get absolute path to this makefile's directory
mkfile_path := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

android.build:
	cd ${mkfile_path} && \
	./gradlew assembleDebug

android.test:
	cd ${mkfile_path} && \
	./gradlew testDebugUnitTest

android.clean:
	rm -rf ${mkfile_path}build
	rm -rf ${mkfile_path}veil/build

.PHONY: android.build anroid.test android.clean