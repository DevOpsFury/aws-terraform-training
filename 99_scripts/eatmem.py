#!/usr/bin/env python3

import os
import psutil
from time import sleep

MEGA = 10 ** 6
MEGA_STR = ' ' * MEGA


def pmem():
    process = psutil.Process(os.getpid())
    print("Process memory (MB): {}".format(process.memory_info().rss / MEGA))


if __name__ == '__main__':
    a = []
    while True:
        print(len(a))
        pmem()
        a.append(' ' * 10**6)
        sleep(1)
