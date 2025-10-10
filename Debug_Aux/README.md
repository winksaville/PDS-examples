# Debug_Aux

Example of using the AUX connecter as the
sink for prinln statments.

This was developed with the [Bot](https://chatgpt.com/share/68e938a2-96d4-800c-9c56-295256e4a1cb)
and works reasonably well.

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

