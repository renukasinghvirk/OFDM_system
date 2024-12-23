# OFDM system
## Project for the course EE-442 EPFL
The project uses matlab and a pair of speakers as well as a microphone.

## Basics
Orthogonal Frequency Division Multiplexing (OFDM) is a digital communication method to send data over multiple subcarriers, reducing inter-symbol interference (ISI) and making it easier to perform channel estimation and recover the proper data.
## Code overview
This project implements a transmitter which sends bits over to a receiver. The provided code allows to either transmit random bits or a smiley image, but the code can easily be modified to transmit any other bit sequence; to do so, ensure the data type chosen is 'image', and replace `smiley_bitstream` with the desired bitstream.

In order to run the project, simply run the `audiotrans_ofdm.m` file.

### Methods implemented
The project implements channel equalization using a transmitted known BPSK-mapped OFDM training symbol, as well as phase tracking implemented on each subcarrier independently, using the Viterbi-Viterbi algorithm. 

The sent BPSK training symbols/QPSK data symbols can be visualized at the transmitted and receiver, as well as the raw time/frequency signal. 
The bit error rate (BER) is computed at the end of the transmission, which can consist of multiple frames.



## License
© 2024 GitHub, Inc.


EPFL © [Thomas Lenges](https://github.com/thomaslenges), [Renuka Singh Virk](https://github.com/renukasinghvirk)

