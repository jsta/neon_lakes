all: blog.pdf

images/nl_map.png: neon_lakes.R
	Rscript neon_lakes.R

blog.pdf: blog.md images/nl_map.png 
	pandoc blog.md -V geometry:margin=1in -o blog.pdf
