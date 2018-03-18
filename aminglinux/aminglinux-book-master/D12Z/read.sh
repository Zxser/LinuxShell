#! /bin/bash

## Using 'read' in shell script.
## Aming 2017-02-23.

read -p "Please input a number: " x
read -p "Please input another number: " y
sum=$[$x+$y]
echo "The sum of the two numbers is: $sum"

