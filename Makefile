.PHONY: get analyze format test ios android

get:
	flutter pub get

analyze:
	dart analyze

format:
	dart format --line-length 120 lib test example/lib

test: get analyze format
	flutter test

build: get
	cd example && flutter build ios --debug --no-codesign
	cd example && flutter build apk --debug

ios:
	flutter emulators --launch apple_ios_simulator
	cd example && flutter run -d "iPhone"
