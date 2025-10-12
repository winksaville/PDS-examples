# PDS-examples

Initially just one example, Debug_Aux. This is code
that uses the AUX connector, located next to the USB-C
connector, as the destination for println debug statments.

>Note: Use `make help` to see all make commands.

## Initial setup

Do `make uninit` to remove arduino-cli, build/ shared/
```
wink@fwlaptop 25-10-12T20:56:12.196Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ make uninit
rm -rf arduino-cli.yaml build shared
wink@fwlaptop 25-10-12T20:56:15.846Z:~/data/prgs/PDS-examples (ok-with-clangd)
```

Do `make init`, `make c S=Empty`:
```
wink@fwlaptop 25-10-12T20:56:15.846Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ make init
arduino-cli  --config-file "./arduino-cli.yaml" config init
Config file written to: ./arduino-cli.yaml
arduino-cli  --config-file "./arduino-cli.yaml" config set directories.data shared/data
arduino-cli  --config-file "./arduino-cli.yaml" config set directories.user shared

..

Installed ESPAsyncWebServer@3.1.0
Downloading AsyncTCP@1.1.4...
AsyncTCP@1.1.4 downloaded                                                                                                                                                                     
Installing AsyncTCP@1.1.4...
Installed AsyncTCP@1.1.4
arduino-cli  --config-file "./arduino-cli.yaml" lib install "TMC2209"
Downloading TMC2209@10.1.1...
TMC2209@10.1.1 downloaded                                                                                                                                                                     
Installing TMC2209@10.1.1...
Installed TMC2209@10.1.1
wink@fwlaptop 25-10-12T20:57:37.667Z:~/data/prgs/PDS-examples (ok-with-clangd)
```

## Building
Use `make c S=Xxx` where Xxx is a sketch such as Empty
```
wink@fwlaptop 25-10-12T20:57:37.667Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ make c S=Empty
touch Empty/Empty.ino
Compiling sketch 'Empty' for esp32:esp32:esp32s3
Sketch uses 311095 bytes (23%) of program storage space. Maximum is 1310720 bytes.
Global variables use 20656 bytes (6%) of dynamic memory, leaving 307024 bytes for local variables. Maximum is 327680 bytes.
wink@fwlaptop 25-10-12T20:58:06.607Z:~/data/prgs/PDS-examples (ok-with-clangd)
```

## Checking with clangd

There are "unknown argument" errors that clangd LSP server
doesn't understand do the following fixes, using the modified
cpp_flags fixes it:
```
wink@fwlaptop 25-10-12T20:49:21.622Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ cp cpp_flags_remove_unknown-arguments shared/data/packages/esp32/tools/esp32-arduino-libs/idf-release_v5.5-07e9bf49-v1/esp32s3/flags/cpp_flags
wink@fwlaptop 25-10-12T20:51:27.046Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ clangd --check=Empty/main.cpp &> cc0.logs
wink@fwlaptop 25-10-12T20:51:57.258Z:~/data/prgs/PDS-examples (ok-with-clangd)
$ tail -1 cc0.logs
I[13:51:50.660] All checks completed, 0 errors
```

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
