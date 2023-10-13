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

	timestamps=($(git log --follow --format=%aI -- $md_file))

	created=${timestamps[-1]}
	created_yaml="date: $created"

	last_modified=${timestamps[0]}
	last_modified_yaml="lastmod: $last_modified"

	# Theme has been tweaked to not show last updated if both are equal.
	yaml_dates="$created_yaml\n$last_modified_yaml"

	# Start of file should be the YAML delimiter (---) normally.
	# If not, we just add a new front matter with yaml_dates at top.
	# If it is,
	#	- Check if date already exists (so we don't have to add).
	#	- Add last updated if date already exists.
	#	- Otherwise, prepend yaml_dates to the front matter.

	delimiter="---"

	if [[ "$(head -n 1 $md_file)" != "$delimiter" ]]; then
		sed -i "1s/^/$delimiter\n$yaml_dates\n$delimiter\n\n/" $md_file
	else
		num_delim=0

		while IFS= read -r line; do
			if [[ "$line" == "$delimiter" ]]; then
				num_delim+=1
				if [[ $num_delim == 2 ]]; then
					break
				else
					continue
				fi
			fi

			if [[ "${line:0:6}" == "date: " ]]; then
				yaml_dates="$last_modified_yaml"
				break
			fi
		done < $md_file

		sed -i "1s/^.*$/$delimiter\n$yaml_dates\n/" $md_file
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
