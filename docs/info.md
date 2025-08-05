<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

The peripheral index is the number TinyQV will use to select your peripheral.  You will pick a free
slot when raising the pull request against the main TinyQV repository, and can fill this in then.  You
also need to set this value as the PERIPHERAL_NUM in your test script.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Your project title

Author: vibhee

Peripheral index: nn

## What it does

This peripheral implements a fixed-point 8-tap Finite Impulse Response (FIR) filter. It takes 8-bit signed input samples, processes them using 8 user-configurable signed 8-bit filter coefficients, and outputs an 8-bit signed filtered result. The filter uses a multiply-accumulate (MAC) operation internally and supports real-time streaming input.

The output is updated every time a new input sample is written, and the oldest sample is discarded, preserving a window of the most recent 8 samples.

## Register map

Document the registers that are used to interact with your peripheral

| Address | Name     | Access | Description                                                   |
| ------- | -------- | ------ | ------------------------------------------------------------- |
| 0x00    | INPUT    | W      | Write the next 8-bit signed input sample                      |
| 0x01    | OUTPUT   | R      | Read the latest filtered 8-bit signed output                  |
| 0x02    | COEFF_0  | W      | Set coefficient 0 (8-bit signed)                              |
| 0x03    | COEFF_1  | W      | Set coefficient 1 (8-bit signed)                              |
| 0x04    | COEFF_2  | W      | Set coefficient 2 (8-bit signed)                              |
| 0x05    | COEFF_3  | W      | Set coefficient 3 (8-bit signed)                              |
| 0x06    | COEFF_4  | W      | Set coefficient 4 (8-bit signed)                              |
| 0x07    | COEFF_5  | W      | Set coefficient 5 (8-bit signed)                              |
| 0x08    | COEFF_6  | W      | Set coefficient 6 (8-bit signed)                              |
| 0x09    | COEFF_7  | W      | Set coefficient 7 (8-bit signed)                              |
| 0x0A    | STATUS   | R      | Read-only status flag (bit 0: output ready = 1)               |
| 0x0B    | RESET    | W      | Write any value to reset the internal buffer and clear output |

| 0x00    | DATA     | R/W    | A byte of data                                                |

## How to test
Initialize coefficients:
Write 8 signed 8-bit coefficients to addresses 0x02–0x09. These define your FIR filter response.

Provide input samples:
For each new 8-bit signed input sample, write to address 0x00.

Check status:
Poll address 0x0A. If bit 0 is high, filtered output is ready.

Read output:
Read the filtered result from address 0x01. This is an 8-bit signed value.

Reset (optional):
Write any value to 0x0B to reset the internal sample history (FIFO).

## External hardware

None required. All functionality is internal to the FPGA.
