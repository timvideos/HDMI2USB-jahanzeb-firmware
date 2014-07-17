


# Using Github Issues

## Label Meanings

#### `type-XXXX` Labels

These label refers to the "type" of the issue.

 * `type-bug`         - This issue talks about something that currently doesn't work, but should.
 * `type-enhancement` - This issue talks about something that should be added but currently not implimented.
 * `type-pie-in-sky`  - This issue talks about something we'd like to have in the future but is still a long way off and not currently being focused on.
 * `type-question`    - This issue is just a question that needs to be answered and probably needs some type of research.

#### Informational Labels

These labels don't really fit into the other categories.

 * `hardware` - This issue relates to the creation and production of a physical device. It probably needs PCB design and electrical knowledge.
 * `software` - This issue relates to the creation of software on a host computer.

 * `new-project` - This issue relates to starting a new project which is related to the HDMI2USB project (and probably reuses / interfaces with the project).
 * `kind-of-related` - This issue is only kind of related to the HDMI2USB project. It could be a tool that would be useful for the HDMI2USB or some other type of thing.

#### `firmware-XXXX` Labels

These label refers to issues which are related to the various firmware which exists in the system.

 * `firmware-fgpa`    - This issue relates to the "gateware" that is loaded onto the FPGA. This means it probably needs VHDL or Verilog experiance to fix.
 * `firmware-cypress` - This issue relates to the firmware loaded onto a Cypress FX2 device (such as found on the Digilent Atlys and HDMI2USB Numato boards). This is written in dialect of C.
 * `firmware-pic`     - This issue relates to firmware loaded onto a PIC device (such as that found on the HDMI2USB Numato boards).

#### `board-XXXX` Labels

These label refers to issues which are related to a **specific** board configuration. If an issue doesn't have a `board-XXXX` label it is relavent to all boards.

 * `board-atlys`             - This issue relates to the Digilent Atlys board.
 * `board-numato`            - This issue relates to *both* the consumer and conference versions of the HDMI2USB Numato boards.
 * `board-numato-conference` - This issue relates to *only* the **conference** version of the HDMI2USB Numato board.
 * `board-numato-consumer`   - This issue relates to *only* the **consumer** version of the HDMI2USB Numato board.
 * `board-zybo`              - This issue relates to the Digilent Zybo board.

#### `expansion-XXXX` Labels

These labels refers to issues which are related so specific *expansion* board.

 * `expansion-vmodvga` - This issue relates to the VGA capture board initially started by @Jahanzeb and then finished by @rohit91
 * `expansion-vmodserial` - This issue relates to the generic serial expansion board created by @ayushXXXX
