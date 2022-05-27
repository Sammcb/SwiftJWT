.PHONY: help clean

# target: help - Display callable targets
help:
	@egrep "^# target:" Makefile | cut -c 10-
	
# target: build - Build an executable
build:
	swift build -c release

# target: clean - Remove build directorys
clean:
	rm -rf .build
	rm -rf .swiftpm
	rm -f Package.resolved
