#!/bin/bash
echo "Top 5 CPU consuming processes:"
ps aux --sort=-%cpu | head -6
echo -e "\nTop 5 memory consuming processes:"
ps aux --sort=-%mem | head -6
echo -e "\nZombie processes:"
ps aux | awk '$8=="Z" {print}'
