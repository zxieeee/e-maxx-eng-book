# Label from file path
my $fname=@ARGV[0];
$fname =~ m#src/(.*).md$#;
my $label = $1;
$label = "sec:".$label;
$label =~ y#/#_#;
my $imgpath = $fname;
$imgpath =~ s#/[^/]+$##;

my @lines;
my $in_admonition = 0;

my $i = 0;
while (<>) {
    $i=$i+1;

    if (/^===\s+["'][^"']+["']\s*$/) {
        $_ = "";
        next;
    }

    if (/^(?:!!!|\?\?\?)\s+([A-Za-z]+)(?:\s+"([^"]+)")?/) {
        my $kind = lc($1);
        my $title = defined $2 ? $2 : ucfirst($kind);
        $_ = "**$title.**\n";
        $in_admonition = 1;
    }

    if ($in_admonition) {
        if (/^\s*$/) {
            $in_admonition = 0;
        } else {
            s/^ {4}//;
        }
    }

    # strip MkDocs-specific data-toc-label attributes from headings
    s/\s*data-toc-label="[^"]*"//g;
    s/\s*data-toc-label='[^']*'//g;
    s/\{\s*\}//g;

    # clean simple HTML wrappers that are not useful in LaTeX output
    s#<div[^>]*>##g;
    s#</div>##g;
    s#<br\s*/?>#\n\n#g;

    if ($_ !~ /^#+ .*\{#.*\}.*$/) {
        # Top level headers
        s/^# (.*)/# \1 {#$label}/;
        # Make lower level headers something unique
        s/^#(#+) (.*)$/#\1 \2 {#$label$i}/;
    }

    # Make relative html links into section links
    s#\[([^\]]*)\]\(\.{0,2}?/([^)]+)/([^)]+).html\)#\\hyperref[sec:\2_\3]{\1}#g;

    # Try to fix some other internal links
    s#\[([^\]]*)\]\((?!http)[^)]*\#([^)]*)\)#\\hyperref[\2]{\1}#g;

    # environment fix
    s/eqnarray/align/g;

    # pandoc is bad with subscripts at times (can we even fix this?)
    s/\\_\\text\{/_\\text\{/g;
    s/\\_\{/_{/g;

    # escape _ in text mode
    s/\\text\{([^}_]*)_([^}_]*)\}/\\text\{\1\\_\2\}/g;

    # Convert extrnal urls to base name
    #
    #                             <- base->
    #  <- label -><----------- url ------->
    s#!\[([^]]*)\]\(http([^/)]*/)*([^)]+)\)#![\1](\&imgroot\&/\3)#g;
    #                         <- base->
    # Non http images. Assumed to be images in the aux repo.
    s#!\[([^]]*)\]\((?!http\/)([^)]+)\)#![\1]($imgpath/\2)#g;

    # Gif doesn't play well with latex
    s#!\[Visual\]\(.*minkowski.gif\)#[minkowski.gif](https://raw.githubusercontent.com/e-maxx-eng/e-maxx-eng/master/img/minkowski.gif)#;
    # URL args after images doesn't work, fix some cases.
    s#(\.jpeg)\?w=[0-9]*#\1#g;

    # Expand image root
    s#&imgroot&#../../static/img#g;

    # code fixes
    s! ?<span class="toggle-code">[^<]*</span>!!g;

    # Linebreaks in titles are weird
    s!<br/>! -- !g;

    # code fixes (standardized format, handles caption)
    s/~{3,}/```/g;
    s/^```(cpp|java|python) (.+)/```{caption="\2" .\1}/g;
    s/^```(cpp|java|python)/```{.\1}/g;

    # amsmath fix
    s/\\over\b/\\youreallyshouldnotuseover/g;

    # try_kuhn hotfix
    s/\\textrm\{try_kuhn\}/\\textrm\{try\\_kuhn\}/g;

    # Fix possesives in urls. Pandoc does not handle these properly.
    s/Lucas's_theorem/Lucas%27s_theorem/g;
    s/Fermat's_little_theorem/Fermat%27s_little_theorem/g;
    s/Graeffe's_method/Graeffe%27s_method/g;
 
    # math backslash inconsistency fix
    # normalize 2 or more backslashes to be 2 backslashes
    s/\\\\+/\\\\/g;

    # Seems the repo now also uses \[ \] math after the engine change.
    s/\\\[/\$\$/g;
    s/\\\]/\$\$/g;

    # Pls don't use unicode symbols like this in math mode.
    s/−/-/g;
# Normalize unicode whitespace and invisible characters
s/\x{200A}/ /g;
s/\x{2009}/ /g;
s/\x{202F}/ /g;
s/\x{00A0}/ /g;
s/\x{200B}//g;
    s/&ensp;/\\enspace/g;
    
    push(@lines, $_);
}

$content = join('',@lines);

# use unnumbered environments (special, match is allowed between lines)
$content =~ s/\$\$\s*\\begin\{(align|eqnarray)\}/\\begin{\1*}/g;
$content =~ s/\\end\{(align|eqnarray)\}\s*\$\$/\\end{\1*}/g;

print $content;

print "\n\n";
