# Microcontroller Unit (MCU) Design

The controller we used is the STM32L432KC, which all students in E155 used. The MCU communicated with the inertial measurement unit (IMU) to obtain the roll angle. The IMU calculated this angle by fusing together readings from an accelerometer, a magnetometer, and a gyroscope, leading to a highly robust reading. The MCU then used universal asynchronous receiver-transmitter (UART) protocol to communicate with the IMU. 

We then converted the angle to the number of encoder ticks the wheel had to rotate, and sent that value to the FPGA. This conversion was done through the following steps:

1. Convert the value of the raw data to rotations by dividing by 5760.   
2. Convert rotations to encoder ticks by multiplying by 80.
3. Convert the angular displacement of the body to the wheel. This is done through the formula: *x<sub>w</sub>=x<sub>b</sub>(1+m<sub>b</sub>/m<sub>w</sub>)* derived through physics. *x<sub>w</sub>* is the desired rotation of the motor, *x<sub>b</sub>* is the desired displacement of the body, *m<sub>b</sub>* is the moment of inertia of the body, and *m<sub>w</sub>* is the moment of inertia of the wheel.

After these values were converted, the data was sent to the FPGA through SPI (serial peripheral interface).
