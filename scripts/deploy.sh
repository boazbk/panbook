#!/bin/bash
# deploy web page
echo "Deploying to web"
echo "Cleaning deploy directory"
rm -rf deploy/public/*
rm -rf deploy/figure/*
echo  "Copying files to deploy"
cp -Rf htmlbase/* deploy/
cp -Rf html/* deploy/public
cp -Rf figure deploy/
echo "Compressing images.."
pngquant/pngquant.exe 256 --verbose --skip-if-larger --force --ext .png deploy/figure/*.png
echo "Removing powerpoint"
rm -f deploy/figure/*.pptx
echo "Pushing to repository"
cd "deploy"
git add -A
git commit -m "deploy page"
git pull --rebase
git push
cd ..
echo "Deploying binaries to s3"
cp -Rf latex-book/lnotes_book.pdf binaries/
cp -Rf binaries/* C:/DBOX/WORK/Homepage/Binary/introtcs/
cd "C:/DBOX/WORK/Homepage/Binary/introtcs"
read -p "Run acrobat? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    "C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
fi
read -p "Sync with s3? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd ..
    aws s3 sync . s3://files.boazbarak.org
fi
