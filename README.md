UART Digital Oscilloscope: Signal War Arena
A digital oscilloscope that streams signals over UART and turns phase control into a game. Two waveforms are generated in hardware (Verilog), plotted against each other on the X and Y axes, and the user controls the phase of one signal to decide the outcome of a "war" between them.
> **Status:** In development. See [Project Status](#project-status) below.
---
Table of Contents
Overview
How It Works
The War Arena
Tech Stack
System Architecture
Repository Structure
Getting Started
Hardware Extension (Optional)
Project Status
Team
License
---
Overview
A conventional oscilloscope displays a single waveform against time. This project takes a different approach:
Two signals are generated and displayed together, one driving the X axis and the other the Y axis.
The user controls the phase of one signal using a control input (software, or a physical knob in the hardware version).
The relationship between the two signals drives a "war arena" visualization, where the phase relationship decides the result.
The same scene is rendered in two different ways: on a MATLAB display and (if time permits) on an Arduino + OLED hardware display.

How It Works
Signal generation (Verilog): Two waveforms are generated digitally on an FPGA. The phase offset of one is adjustable.
UART transmission: Samples are sent serially to the host over UART.
Visualization (MATLAB): The host receives the samples, plots the two signals on the X and Y axes, and renders the war scene.
Phase control: The user adjusts the phase of one signal, which changes the outcome in real time.
The War Arena
The game logic is based on the phase relationship between the two signals:
Phase difference	Relationship	Outcome
0°	Both signals in phase	Case 1 (win/lose: TBD)
180°	Signals out of phase	Case 2 (win/lose: TBD)
When two equal-frequency signals are plotted against each other (X vs Y), in-phase signals trace a straight diagonal line and out-of-phase signals trace the opposite diagonal. Intermediate phases open up into ellipses and circles, which gives the arena a natural visual language.

Tech Stack
Software
Verilog: signal generation and UART transmitter
MATLAB: UART receiver, X-Y plotting, and war scene output
Hardware (if time permits)
Arduino
OLED display
Physical knob (potentiometer or rotary encoder) for phase control

System Architecture
```
┌──────────────┐   UART    ┌──────────────┐
│ Verilog      │ ────────► │ MATLAB       │
│ Signal Gen   │           │ X-Y Display  │
│ (2 signals)  │           │ + War Arena  │
└──────────────┘           └──────────────┘
       ▲
       │ phase control
┌──────┴───────┐
│ User input   │
│ (knob / UI)  │
└──────────────┘

Optional: Arduino + OLED + knob renders the same scene on hardware.
```
Repository Structure
> Update this section to match your actual folders.
```
.
├── verilog/        # Signal generation, phase control, UART TX
├── matlab/         # UART receiver, plotting, war arena
├── arduino/        # (Optional) Arduino + OLED code
├── docs/           # Diagrams, notes, reports
└── README.md
```
Getting Started
Prerequisites
FPGA toolchain for Verilog synthesis and simulation (e.g., Vivado or Quartus)
MATLAB (with Instrument Control Toolbox for serial communication)
USB-UART connection between FPGA and PC
(Optional) Arduino IDE and an OLED display

Run MATLAB: open the main script in `matlab/`, set the COM port and baud rate, and run it.
Adjust the phase and watch the war arena respond.
Hardware Extension (Optional)
The Arduino + OLED version mirrors the MATLAB output with a physical knob controlling the phase of one signal. MATLAB and the hardware display show the same scene in different ways.


Team
Vamsi
Zikra
Ashvanth
Adwaid
License

