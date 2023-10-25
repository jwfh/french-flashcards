function flashcard(prompt, answer)
{
    printf "    \\begin{flashcard}{%s}\n", prompt
    print "        " answer
    print "    \\end{flashcard}"
}

BEGIN {
    FS = "|"
    print "\\documentclass[avery5371,frame]{flashcards}"
    print
    print "\\usepackage[T1]{fontenc}"
    print "\\usepackage[french]{babel}"
    print "\\usepackage[autolanguage]{numprint}"
    print "\\usepackage{hyphenat}"
    print "\\hyphenation{mate-mática recu-perar}"
    print
    print "\\let\\dot\\textperiodcentered"
    print
    print "\\begin{document}"
    print "    \\sffamily"
}

{
    flashcard($1, $2)
}

END {
    print "\\end{document}";
}
