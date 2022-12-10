# Results

The robot cat can self-correct its orientation while suspended from wires. We have not yet reached our final goal, to drop the robot from two meters and have it land on its “feet.” This was primarily due to the mechanical design, as we were not confident that our electrical components would survive the fall.

Individually, our components worked quite well. The IMU quickly and accurately read data to the microcontroller (MCU), and the MCU sent the data successfully to the FPGA through SPI. The FPGA also successfully read motor position data from the encoder and ran PID control quite well. Some issues we encountered:

- The motor driver could only reach around 2A even if we disabled current limiting, despite the motor driver’s rated peak current of 6A 
- The PID and mechanical constants needed more tuning

Overall, the project was working quite well. If we could do things differently, we would place more importance on the mechanical design and parallelize that development process with the electrical side. Since we started mechanical design after most of our electrical components were working, we did not leave enough time for iterations. Of course, working in parallel is a challenge when the components intended to go on the robot body are not completed, but their weights could have been simulated. 

This project was a great learning experience and we accomplished a lot.


### Video Result
<iframe width="560" height="315" src="hhttps://www.youtube.com/embed/Tys6jcHki30" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe> 