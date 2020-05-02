// SPDX-License-Identifier: MIT
//
// Copyright (c) 2020 Vladimir Stoilov <vladimir.stoilov@protonmail.com>

const uart = @import("uart.zig");

export fn main() noreturn {
    uart.init();
    uart.puts(
        \\
        \\ In Penny Lane there is a barber showing photographs
        \\ Of every head he's had the pleasure to know
        \\ And all the people that come and go
        \\ Stop and say hello
        \\ 
        \\ On the corner is a banker with a motorcar
        \\ The little children laugh at him behind his back
        \\ And the banker never wears a mac
        \\ In the pouring rain
        \\ Very strange
        \\ 
        \\ Penny Lane is in my ears and in my eyes
        \\ There beneath the blue suburban skies
        \\ I sit and meanwhile back
        \\ 
        \\ In Penny Lane there is a fireman with an hourglass
        \\ And in his pocket is a portrait of the Queen
        \\ He likes to keep his fire engine clean
        \\ It's a clean machine
        \\ 
        \\ Penny Lane is in my ears and in my eyes
        \\ Four of fish and finger pies
        \\ In summer, meanwhile back
        \\
        \\ Behind the shelter in the middle of a roundabout
        \\ A pretty nurse is selling poppies from a tray
        \\ And though she feels as if she's in a play
        \\ She is anyway
        \\ 
        \\ In Penny Lane the barber shaves another customer
        \\ We see the banker sitting, waiting for a trim
        \\ And then the fireman rushes in
        \\ From the pouring rain
        \\ Very strange
        \\ 
        \\ Penny Lane is in my ears and in my eyes
        \\ There beneath the blue suburban skies
        \\ I sit, and meanwhile back
        \\ 
        \\ Penny Lane is in my ears and in my eyes
        \\ There beneath the blue suburban skies
        \\ Penny Lane
        \\
    );

    while(true) {
        uart.send(uart.getc());
    }

}