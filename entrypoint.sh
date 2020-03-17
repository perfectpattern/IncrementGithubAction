#!/bin/bash

echo $GITHUB_REPOSITORY

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

buildExist=""
if [[ $GITHUB_REF == *dev ]]; then
    echo "dev branch action"
	git checkout dev
	echo "after dev checkout"
	buildExist="$(cd $realRepo && git tag | grep dev)"
else
    echo "master branch action"
	buildExist="$(cd $realRepo && git tag | grep build)"
fi

tag=""
if [[ $buildExist ]]; then
	echo "buildnr increment"
	if [[ $GITHUB_REF == *dev ]]; then
		lastestBuildNr="$(cd $realRepo && git tag | grep dev | sort -V -r | head -n1 | cut -c 7-)"
		echo $lastestBuildNr
		lastestBuildNr=$((lastestBuildNr+1))
		echo $lastestBuildNr
		tag="dev-${lastestBuildNr}"
		echo $tag
	else
		lastestBuildNr="$(cd $realRepo && git tag | grep build | sort -V -r | head -n1 | cut -c 7-)"
		echo $lastestBuildNr
		lastestBuildNr=$((lastestBuildNr+1))
		echo $lastestBuildNr
		tag="build-${lastestBuildNr}"
		echo $tag
	fi
else
    echo "no buildnr"
	if [[ $GITHUB_REF == *dev ]]; then
		tag="dev-1"
	else
		tag="build-1"
	fi
	echo $tag
fi

cd $realRepo
git remote set-url --push origin https://$realActor:$GITHUB_TOKEN@github.com/$realActor/$realRepo
git tag $tag

git push origin $tag
