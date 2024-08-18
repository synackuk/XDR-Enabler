CC = gcc
SOURCES=main.m
FRAMEWORKS:= -F/System/Library/PrivateFrameworks -framework Foundation -framework Cocoa -framework AppKit -framework MonitorPanel -framework SkyLight
LIBRARIES:= -lobjc
CFLAGS=-Wall -Werror -I./headers $(SOURCES)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=-o xdr_enabler

all: $(SOURCES) $(OUT)

$(OUT): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LDFLAGS) $(OUT)

.m.o: 
	$(CC) -c -Wall $< -o $@

clean:
	@rm -rf xdr_enabler