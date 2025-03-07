#!/bin/bash
export CHROME_EXECUTABLE=$(whereis -b -B /bin -f chromium | cut -d ' ' -f2)