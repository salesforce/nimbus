# makefile for android
#
# this file is not meant to be used directly but as an include in the top-level makefile

# get absolute path to this makefile's directory
android_mkfile_path := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

android.build:
	cd ${android_mkfile_path} && \
	./gradlew assembleDebug

android.test:
	cd ${android_mkfile_path} && \
	./gradlew testDebugUnitTest

android.clean:
	rm -rf ${android_mkfile_path}build
	rm -rf ${android_mkfile_path}nimbus/build

.PHONY: android.build anroid.test android.clean