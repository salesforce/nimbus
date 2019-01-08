# makefile for ios
#
# this file is not meant to be used directly but as an include in the top-level makefile

# get absolute path to this makefile's directory
mkfile_path := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

workspace ?= ${mkfile_path}/Veil.xcworkspace
framework-scheme ?= Veil
app-scheme ?= VeilDemoApp
configuration ?= Debug
sdk ?= iphonesimulator
derivedDataPath ?= ${mkfile_path}/DerivedData/build-${configuration}
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

# archive targets default to device release builds
ios.%archive: configuration = Release
ios.%archive: sdk = iphoneos
ios.%archive: versionNumber = $(shell expr 1000000 + ${buildNumber})

ios.archive:
	xcodebuild archive \
		-workspace ${workspace} \
		-scheme ${app-scheme} \
		-sdk ${sdk} \
		-configuration ${configuration} \
		-derivedDataPath ${derivedDataPath} \
		-archivePath ${derivedDataPath}/archive/${app-scheme}.xcarchive \
		APP_PROVISIONING_PROFILE="${archiveProvisioningProfile}" \
		CODE_SIGN_IDENTITY="${archiveCodeSignIdentity}" \
		-UseModernBuildSystem=NO \
		-quiet \
		label=${versionNumber}

ios.export-archive: exportPlist = ./objc/FeedSDKSampleApp/FeedSDKSampleApp/Resources/exportOptions.plist
ios.export-archive: ios.archive
	xcodebuild \
		-exportArchive \
		-archivePath ${derivedDataPath}/archive/${app-scheme}.xcarchive \
		-exportOptionsPlist ${exportPlist} \
		-exportPath ${derivedDataPath}/artifacts \
		PROVISIONING_PROFILE="${exportProvisioningProfile}" \
		CODE_SIGN_IDENTITY="${exportCodeSignIdentity}" \
		-UseModernBuildSystem=NO \
		-quiet

ios.clean:
	rm -rf build*

.PHONY: ios.build ios.test ios.archive ios.export-archive ios.clean