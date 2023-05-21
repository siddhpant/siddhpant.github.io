# Bodha Website Generator

This repo consists of configuration files and final structure for Hugo to
generate the files of my blog's website to serve on GitHub pages.

`generate.sh` bash script is used to fetch the content (pages and posts) from
[siddhpant/bodha](https://github.com/siddhpant/bodha/), and the theme from
[siddhpat/hugo-theme-terminal](https://github.com/siddhpant/hugo-theme-terminal/),
and then generate the website appropriately.

A GitHub action is used to run the script and push the public folder to GitHub
pages.

---
