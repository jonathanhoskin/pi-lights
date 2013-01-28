git add .
git commit -m "Edit"
git push
ssh pi 'cd pi-lights; git pull'
