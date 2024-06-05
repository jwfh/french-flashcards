FICHIERS!=	find contenu -type f -name '*.csv' -exec sh -c '[ $$(wc -l < "{}") -gt 0 ]' \; -print0 | xargs -0 -n1 basename | xargs -L1 -n1 -I'{}' basename '{}' '.csv'

tout: ${FICHIERS:@.f.@${.f.}.pdf@}

source: ${FICHIERS:@.f.@${.f.}.tex@}

.for fichier in ${FICHIERS}
${fichier}.tex: csv-to-cards.awk contenu/${fichier}.csv
	gawk -f csv-to-cards.awk contenu/${fichier}.csv > ${fichier}.tex

${fichier}.pdf: ${fichier}.tex
	pdflatex -interaction=nonstopmode ${fichier}
.endfor

publication: tout
	tar cJvf cartes.txz ${FICHIERS:@.f.@${.f.}.pdf@}

propre:
	rm -f *.aux *.log *.tex *.synctex.gz