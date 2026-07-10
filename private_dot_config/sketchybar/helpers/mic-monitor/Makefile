BINARY := mic-monitor
PLIST := com.user.mic-monitor.plist
LAUNCH_AGENT := $(HOME)/Library/LaunchAgents/$(PLIST)
GUI_DOMAIN := gui/$$(id -u)

.PHONY: all clean install uninstall restart validate help

all: $(BINARY)

$(BINARY): main.swift
	swiftc -framework CoreAudio -framework Foundation main.swift -o $(BINARY)

clean:
	rm -f $(BINARY)

install: $(BINARY)
	mkdir -p "$(HOME)/Library/LaunchAgents"
	cp "$(PLIST)" "$(LAUNCH_AGENT)"
	launchctl bootout "$(GUI_DOMAIN)" "$(LAUNCH_AGENT)" 2>/dev/null || true
	launchctl bootstrap "$(GUI_DOMAIN)" "$(LAUNCH_AGENT)"

restart: install

uninstall:
	launchctl bootout "$(GUI_DOMAIN)" "$(LAUNCH_AGENT)" 2>/dev/null || true
	rm -f "$(LAUNCH_AGENT)"

validate:
	plutil -lint "$(PLIST)"
	swiftc -typecheck -framework CoreAudio -framework Foundation main.swift

help:
	@echo "make			Build mic-monitor binary"
	@echo "make install		Build and load LaunchAgent"
	@echo "make restart		Rebuild and restart LaunchAgent"
	@echo "make uninstall	Unload LaunchAgent and remove plist"
	@echo "make validate		Validate Swift source and LaunchAgent"
	@echo "make clean		Remove compiled binary"
