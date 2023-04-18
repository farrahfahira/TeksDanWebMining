use strict;
use warnings;
use File::Basename;
use HTML::ExtractContent;
use HTML::Split;
use File::Slurper qw(read_dir);

# Directory where clean data are stored, it's better to set this in config file
my $PATHCLEAN = "clean/tren/";

my $dir = "crawling_data/tren";
my @files = read_dir($dir);

foreach my $file (@files) {
    next if ($file =~ /^\./); # skip hidden files
    
    my $file_path = "$dir/$file";
    my $fileout = basename($file) . ".clean.dat";

    print "Processing file $file_path\n";

    # read file
    open my $fh, '<', $file_path or die "Cannot open file $file_path: $!";
    my $html = do { local $/; <$fh> };
    close $fh;

    # clean html
    $html =~ s/\^M//g;

    # get title
    my $title;
    if ($html =~ /<title.*?>(.*?)<\/title>/) {
        $title = $1;
        $title = clean_str($title);
        print "<title>$title</title>\n";
    }

    # get content and divide into top, middle, and bottom
    my $content = extract_content($html);
    my ($top, $middle, $bottom) = split_content($content);

    # write cleaned html to file
    $fileout = "$PATHCLEAN/$fileout";
    open my $out_fh, '>', $fileout or die "Cannot create file $fileout: $!";
    print $out_fh "<title>$title</title>\n";
    print $out_fh "<atas>$top</atas>\n";
    print $out_fh "<tengah>$middle</tengah>\n";
    print $out_fh "<bawah>$bottom</bawah>\n";
    close $out_fh;

    print "File $fileout has been created.\n";
}

sub extract_content {
    my $html = shift;

    # remove text inside <div class="photo__caption"></div>, <strong></strong>, and <i></i>
    $html =~ s/<div class="photo__caption">.*?<\/div>//g;
    $html =~ s/<strong>.*?<\/strong>//g;
    $html =~ s/<i>.*?<\/i>//g;

    my $extractor = HTML::ExtractContent->new;
    $extractor->extract($html);
    my $content = $extractor->as_text;
    $content = clean_str($content);

    return $content;
}


sub split_content {
    my $content = shift;
    print $content;

    my @sentences = split /([.?!])\s*/, $content;
    my $num_sentences = scalar @sentences;

    my $num_top = int($num_sentences/3);
    my $num_middle = $num_top;
    my $num_bottom = $num_sentences - ($num_top*2);

    my $top = join('', @sentences[0..$num_top-1]); # Join the first num_top sentences as top section
    my $middle = join('', @sentences[$num_top..$num_top+$num_middle-1]); # Join the next num_middle sentences as middle section
    my $bottom = join('', @sentences[$num_top+$num_middle..$num_sentences-1]); # Join the remaining sentences as bottom section

    return ($top, $middle, $bottom);
}


sub clean_str {
    my $str = shift;
    $str =~ s/>//g;
    $str =~ s/&.*?;//g;
    $str =~ s/[\]\|\[\@\#\$\%\*\&\\\(\)\"]+//g;
    $str =~ s/-/ /g;
    $str =~ s/\n+//g;
    $str =~ s/\s+/ /g;
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
    $str =~ s/^$//g;
    $str =~ s/-&nbsp;//g;


    return $str;
}
