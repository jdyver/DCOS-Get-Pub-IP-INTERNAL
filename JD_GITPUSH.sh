# Generic Update Push to PWD's Github Repo
echo " JD-GIT: Message is $1 $2 $3 $4 $5"

git add -A
git commit -am "JD-GIT AUTO: $1 $2 $3 $4 $5"
git push

echo " JD-GIT: This was pushed to:"
git branch
