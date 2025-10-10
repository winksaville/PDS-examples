# Empty

This is the same code as Debug_Aux
but Empty.ino is empty and all of the
code is in main.cpp. This works and
the only difference is between Debug_Aux.ino
and main.cpp is including <Arduino.h> and
have main invoke setup and then repeatedly
invoke loop() in a while loop.

So functionality is the same but I had to
change the Makefile so that when compiling
I always touch the <Sketch>.ino file so changes
to main.cpp are noticed. Maybe <Sketch>.yaml
might be an option but this is good enough for
now.

>Note: Use `make help` to see all make commands.

By default the arduino-cli automatically find the "first" ttyACM0
that is an "Expressif" device. If you have only one device this isn't a
problem, but I'm using a Raspberry PI Debug Probe which is a USB
device and if it's the first device `make {c|u|monitor}` will connect to
it by default and you'll need to use the PORT parameter to connect
to the PDS. Another option si to be sure you plug in the PDS first
and then the Debug Probe. That way `make c S=<SketchDir>` and
make u S=<SketchDir>` work without needing PORT, but you will be
it for `make monitor PORT=/dev/ttyACMx` where x is most likey 1 :)

## Compile and upload

Use `make upload S=Debug_Aux` to compile and upload
or `make c` to compile only.
```
$ make u S=Debug_Aux
```

