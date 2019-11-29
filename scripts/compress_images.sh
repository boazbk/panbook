#!/bin/bash
pngquant/pngquant.exe 256 --skip-if-larger --force --ext .png deploy/figure/*.png
rm deploy/figure/*.pptx
