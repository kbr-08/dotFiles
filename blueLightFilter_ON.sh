#!/bin/bash

pkill hyprsunset
hyprsunset --temperature 4000 & disown
echo "Blue light filter enabled (4000K)."
