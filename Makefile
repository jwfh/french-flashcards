NOM_DU_DOCUMENT=	cartes
FICHIERS=		mots phrases verbes conjugaisons

tout: ${NOM_DU_DOCUMENT}.pdf

source: ${NOM_DU_DOCUMENT}.tex

${NOM_DU_DOCUMENT}.tex: csv-to-cards.awk ${FICHIERS:@f@contenu/$f.csv@}
	gawk -f csv-to-cards.awk ${FICHIERS:@f@contenu/$f.csv@} > ${NOM_DU_DOCUMENT}.tex

${NOM_DU_DOCUMENT}.pdf: ${NOM_DU_DOCUMENT}.tex
	pdflatex -interaction=nonstopmode ${NOM_DU_DOCUMENT}

nettoyer:
	rm -f texput.*