#!/bin/sh -l
set -e

file_name=$1
tag_version=$2
echo "\nInput file name: $file_name : $tag_version"

echo "Git Head Ref: ${GITHUB_HEAD_REF}"
echo "Git Base Ref: ${GITHUB_BASE_REF}"
echo "Git Event Name: ${GITHUB_EVENT_NAME}"

echo "\nStarting Git Operations"
git config --global user.email "obynodavid12@gmail.com"
git config --global user.name "Obinna"
git config --global --add safe.directory '*'  # added this line to make sure the script works with any directory
#https://devhints.io/git-log-format
# git config --global user.name "$(git --no-pager log --format=format:'%an' -n 1)"
# git config --global user.email "$(git --no-pager log --format=format:'%ae' -n 1)"
# git config --global --add safe.directory "$GITHUB_WORKSPACE"


github_ref=""

if test "${GITHUB_EVENT_NAME}" = "push"
then
    github_ref=${GITHUB_REF}
else
    github_ref=${GITHUB_HEAD_REF}
    git checkout $github_ref
fi


echo "Git Checkout"

if test -f $file_name; then
    content=$(cat $file_name)
else
    content=$(echo "-- File doesn't exist --")
fi

echo "File Content: $content"
extract_string=$(echo $content | awk '{print}')
echo "Extracted string: $extract_string"

if [[ "$extract_string" == "" ]]; then 
    echo " Invalid version string "
    exit 0
else
    echo " Valid version string found "
fi

oldver=$(echo $extract_string | rev | cut -d "." -f2- | rev);
newver=$(echo $extract_string | rev | cut -d "." -f1 | rev | xargs | expr "$(cat)" + 1);

newver="${oldver}.${newver}";

echo "\nOld Ver: $oldver"
echo "\nUpdated version: $newver" ;

echo $newver > $file_name

git add -A 
git commit -m "Incremented to ${newver}"  -m "[skip ci]"
([ -n "$tag_version" ] && [ "$tag_version" = "true" ]) && (git tag -a "${newver}" -m "[skip ci]") || echo "No tag created"

git show-ref
echo "Git Push"

git push --follow-tags "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:$github_ref


echo "\nEnd of Action\n\n"
exit 0