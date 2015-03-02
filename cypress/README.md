
## Existing HDMI2USB USB endpoint usage

FIXME: Check this is correct!!!

| Endpoint | Direction | Transfer type | Used? | Comments                              |
| -------- | --------- | ------------- | ----- | --------------------------------------|
|     0    |     -     | CONTROL       | No    | USB Reserved                          |
|     1    |    IN     | INT           | Yes   | CDC Polling/Int?                      |
|     2    |    OUT    | BULK          | Yes   | Used for UART TX                      |
|     4    |    IN     | BULK          | Yes   | Used for UART RX                      |
|     6    |    IN     | BULK          | Yes   | Used for sending UVC camera data      |
|     8    |     -     | -             | No    | Unused, can be freed                  |


## What Cypress FX2LP supports

| Endpoint | Direction  | Transfer type | Comments                              |
| -------- | ---------- | ------------- | --------------------------------------|
|     0    |      -     | Control       | Reserved |
|     1    | IN and OUT | INT/BULK      | 64-byte buffers for smaller payloads |
|     2    | IN or OUT  | BULK/ISO/INT  | 512 or 1024 byte buffers for larger payloads |
|     4    | IN or OUT  | BULK/ISO/INT  |  |
|     6    | IN or OUT  | BULK/ISOINT   |  |
|     8    | IN or OUT  | BULK/ISO/INT  |  |


# Building

The firmware uses the Open Source fx2lib, which will be downloaded as part of
the build proccess.

`make`

# Flasing

Use fx2loader from the libfpgalink project:

`fx2loader -v 0925:3881 firmware.hex ram`


# References
    Create a USB Virtual COM Port: http://janaxelson.com/usb_virtual_com_port.htm
    USBCDC1.2 Spec PSTN120.pdf Page

