BINARY = mic-monitor

.PHONY: all clean install uninstall help

all: $(BINARY)

$(BINARY): main.swift
	swiftc -framework CoreAudio -framework CoreMediaIO -framework Foundation main.swift -o $(BINARY)

clean:
	rm -f $(BINARY)

install: $(BINARY)
	cp com.user.mic-monitor.plist ~/Library/LaunchAgents/
	launchctl load ~/Library/LaunchAgents/com.user.mic-monitor.plist

uninstall:
	launchctl unload ~/Library/LaunchAgents/com.user.mic-monitor.plist 2>/dev/null || true
	rm -f ~/Library/LaunchAgents/com.user.mic-monitor.plist

help:
	@echo "make						Build mic-monitor binary"
	@echo "make install		Build and load LaunchAgent"
	@echo "make uninstall Unload LaunchAgent and remove plist"
	@echo "make clean			Remove compiled binary"
