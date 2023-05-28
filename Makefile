all: cards.pdf

cards.pdf: csv-to-cards.awk content.csv
	gawk -f csv-to-cards.awk content.csv | pdflatex
	mv texput.pdf $@

clean:
	rm -f texput.*