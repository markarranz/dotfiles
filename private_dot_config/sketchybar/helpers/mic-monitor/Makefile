BINARY = mic-monitor

.PHONY: all clean

all: $(BINARY)

$(BINARY): main.swift
	swiftc -framework CoreAudio -framework Foundation main.swift -o $(BINARY)

clean:
	rm -f $(BINARY)
