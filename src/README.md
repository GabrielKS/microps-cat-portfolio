---
layout: page
title: Documentation
permalink: /src/
---

# Code details
This directory, which you can browse on GitHub [here](https://github.com/GabrielKS/microps-cat-portfolio/tree/main/src), contains the most relevant source code we wrote for this project. You can also browse our full project directory trees, with all the files needed to run the project, at our development repository [here](https://github.com/GabrielKS/microps-cat).

The MCU code consists of:

  * `main.c`: the main routine, which consists of reading the IMU using USART and sending the processed roll/setpoint data over SPI to the FPGA
  * `main.h`: a simple header for `main.c`
  * `spi_demo.c`: some code to test simple SPI communications with the FPGA

The FPGA code (in order of logical dependency) consists of:

  * `motor_demo.sv`: demonstration of basic motor control: drives an H-bridge with two of the incoming SPI bits
  * `spi_demo.sv`: top-level module for a demonstration of SPI: receives a byte and displays the low nybble on a seven-segment display
  * `pwm_demo.sv`: demonstration of PWM: drives the motor at a duty cycle depending on the SPI input nybble
  * `p_control_demo.sv`: runs a P controller using SPI input as the setpoint, 0 as the current value, and PWM to the motor as output
  * `quadrature_decoder.sv`: decodes the quadrature encoder signal
  * `encoder_demo.sv`: top-level module for a demonstration of reading a quadrature encoder: displays the count mod 16 as a nybble on the seven-segment display
  * `encoder_p_control_demo.sv`: top-level module for a demonstration of a real P control loop using a quadrature encoder to send the motor to a DIP switch-determined position
  * `pid.sv`: PID control with 16-bit signed integers
  * `encoder_pid_demo.sv`: top-level module to run a full PID controller with DIP switch setpoint, encoder input, and PWM motor output
  * `imu_motor_demo.sv`: runs PID using IMU input from the MCU
  * `imu_correct_demo.sv`: final code: adds IMU input to current position to comport with physics
