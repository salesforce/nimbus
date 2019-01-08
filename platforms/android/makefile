# makefile for ios
#
# this file is not meant to be used directly but as an include in the top-level makefile

# get absolute path to this makefile's directory
mkfile_path := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

gradlew ?= ${mkfile_path}/gradlew

android.build:
	${gradlew} assembleDebug

android.test:
	${gradlew} testDebugUnitTest

android.clean:
	rm -rf ${mkfile_path}/build

.PHONY: android.build anroid.test android.clean