#!/bin/bash

# Exit on error and enable globstar.
set -e
shopt -s globstar

###############################################################################

# Hugo root dir.
hugo_root_dir="$(pwd)"

# Static assets dir.
static_dir="$hugo_root_dir/static/"

###############################################################################

# Clone theme.

echo -e "\nCloning requisite repos..."

mkdir themes
git clone https://github.com/siddhpant/hugo-theme-terminal.git themes/terminal

# Clone main content.
git clone https://github.com/siddhpant/bodha.git main_content_repo

###############################################################################

# Add dates to the posts, since Hugo currently does not consider git repo in
# the content directory, and only sees the working directory.

echo -e "\nAdding creation and last modification date to posts..."

cd main_content_repo/content

for md_file in **/*.md; do
	echo -e "\t$md_file"

	start="---"	# The start of file should be a YAML delimiter.

	timestamps=($(git log --follow --format=%aI -- $md_file))
	created=${timestamps[-1]}
	last_modified=${timestamps[0]}

	if [[ "$created" == "$last_modified" ]]; then
		yaml_dates="date: $created\nshowLastUpdated: False"
	else
		yaml_dates="date: $created\nlastmod: $last_modified"
	fi


	if [[ "$(head -n 1 $md_file)" == "$start" ]]; then
		sed -i "1s/^.*$/$start\n$yaml_dates\n/" $md_file
	else
		sed -i "1s/^/$start\n$yaml_dates\n$start\n/" $md_file
	fi
done

###############################################################################

# Generate hugo website.

echo -e "\nGenerating static website using Hugo..."

cd "$hugo_root_dir"

hugo --gc --minify --cleanDestinationDir

echo -e "\nDone!"

###############################################################################

# End of file.
