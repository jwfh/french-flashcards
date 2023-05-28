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
    print "\\begin{document}"
    print "    \\sffamily"
}

{
    flashcard($1, $2)
}

END {
    print "\\end{document}";
}