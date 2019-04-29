images/map.png: neon_lakes.R
	Rscript neon_lakes.R

blog.pdf: blog.md images/map.png 
	pandoc blog.md -V geometry:margin=1in -o blog.pdf
