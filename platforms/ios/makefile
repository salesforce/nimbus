# makefile for ios
#
# this file is not meant to be used directly but as an include in the top-level makefile

# get absolute path to this makefile's directory
ios_mkfile_path := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

workspace ?= ${ios_mkfile_path}/Veil.xcworkspace
framework-scheme ?= Veil
app-scheme ?= VeilDemoApp
configuration ?= Debug
sdk ?= iphonesimulator
derivedDataPath ?= ${ios_mkfile_path}/DerivedData/build-${configuration}
archiveProvisioningProfile ?= ""
exportProvisioningProfile ?= ""
archiveCodeSignIdentity ?= ""
exportCodeSignIdentity ?= ""
buildNumber ?= 1

ios.build:
	xcodebuild build \
		-workspace ${workspace} \
		-scheme ${framework-scheme} \
		-configuration ${configuration} \
		-sdk ${sdk} \
		-derivedDataPath ${derivedDataPath} \
		-destination 'OS=latest,platform=iOS Simulator,name=iPhone 7'

ios.test:
	xcodebuild test \
		-workspace ${workspace} \
		-scheme ${framework-scheme} \
		-configuration ${configuration} \
		-sdk ${sdk} \
		-derivedDataPath ${derivedDataPath} \
		-destination 'OS=latest,platform=iOS Simulator,name=iPhone 7'

ios.clean:
	rm -rf ${derivedDataPath}

.PHONY: ios.build ios.test ios.clean