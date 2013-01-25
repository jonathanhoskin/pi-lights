git add .
git commit -m "Edit"
git push
ssh raspberrypi.local 'cd pi-lights; git pull'