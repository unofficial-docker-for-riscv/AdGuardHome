#!/bin/bash
# DO NOT UPSTREAM THIS FILE

build_date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
readonly build_date

dist_dir="dist"
readonly dist_dir

dist_docker="${dist_dir}/docker"
readonly dist_docker

# get commit & version from github api
version=$(curl -s https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | jq -r .tag_name)
readonly version

# get binary
mkdir -p $dist_dir $dist_docker $dist_dir/AdGuardHome_linux_riscv64
curl -Lo $dist_dir/AdGuardHome_linux_riscv64.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/${version}/AdGuardHome_linux_riscv64.tar.gz
tar -xzf $dist_dir/AdGuardHome_linux_riscv64.tar.gz -C $dist_dir/AdGuardHome_linux_riscv64
cp "${dist_dir}/AdGuardHome_linux_riscv64/AdGuardHome/AdGuardHome" \
	"${dist_docker}/AdGuardHome_linux_riscv64_"

repos=(${REPOS:-ngc7331/adguardhome})
tags=()
for repo in ${repos[@]}; do
	tags+=("-t ${repo,,}:${version}")
	tags+=("-t ${repo,,}:latest")
done

docker \
	buildx build \
	--build-arg BUILD_DATE="$build_date" \
	--build-arg DIST_DIR="$dist_dir" \
	--build-arg VCS_REF="$commit" \
	--build-arg VERSION="$version" \
	--push \
	--platform "linux/riscv64" \
	${tags[@]} \
	-f ./docker/Dockerfile .
