#!/bin/bash

echo $GITHUB_REPOSITORY
echo $GITHUB_EVENT_NAME
echo $GITHUB_WORKFLOW
echo $GITHUB_REF

realActor=""
realRepo=""

while IFS='/' read -ra ADDR; do
	for i in "${ADDR[@]}"; do
		# process "$i"
		realActor="${ADDR[0]}"
		realRepo="${ADDR[1]}"
	done
done <<< $GITHUB_REPOSITORY
 
echo $realActor
echo $realRepo

git clone https://github.com/$realActor/$realRepo.git
buildExist="$(cd $realRepo && git tag | grep build)"

tag=""
if [[ $buildExist ]]; then
    echo "buildnr increment"
	lastestBuildNr="$(cd $realRepo && git tag | grep build | sort -V -r | head -n1 | cut -c 7-)"
	echo $lastestBuildNr
	lastestBuildNr=$((lastestBuildNr+1))
	echo $lastestBuildNr
	tag="build-${lastestBuildNr}"
	echo $tag
else
    echo "no buildnr"
	tag="build-1"
fi

cd $realRepo
git remote set-url --push origin https://$realActor:$GITHUB_TOKEN@github.com/$realActor/$realRepo
git tag $tag

git push origin $tag
