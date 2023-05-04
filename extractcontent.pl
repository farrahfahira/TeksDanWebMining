use strict;
use warnings;
use File::Basename;
use HTML::ExtractContent;
use HTML::Split;
use File::Slurper qw(read_dir);

# Directory where clean data are stored, it's better to set this in config file
my $PATHCLEAN = "4000/";

my $dir = "crawling_data/tren";
my @files = read_dir($dir);

my $hitung = 0;

foreach my $file (@files) {
    last if ($hitung == 2000); # hentikan loop jika sudah memproses 2000 file
    $hitung++;

    next if ($file =~ /^\./); # skip hidden files
    
    my $file_path = "$dir/$file";
    my $fileout = basename($file) . ".tren.txt";

    # read file
    open my $fh, '<', $file_path or die "Cannot open file $file_path: $!";
    my $html = do { local $/; <$fh> };
    close $fh;

    # clean html
    $html =~ s/\^M//g;
    # remove text inside <div class="photo__caption"></div>, <strong></strong>, and <i></i>
    $html =~ s/<strong>.*?<\/strong>//g;
    $html =~ s/<i>.*?<\/i>//g;

    # get title
    my $title;
    if ($html =~ /<title.*?>(.*?)<\/title>/) {
        $title = $1;
        $title = clean_str($title);
    }

    # get content and divide 
    my $content = extract_content($html);
    my ($first, $second, $third, $fourth, $fifth) = split_content($content);

    # write cleaned html to file
    $fileout = "$PATHCLEAN/$fileout";
    open my $out_fh, '>', $fileout or die "Cannot create file $fileout: $!";
    print $out_fh "<title>$title</title>\n";
    print $out_fh "<first>$first</first>\n";
    print $out_fh "<second>$second</second>\n";
    print $out_fh "<third>$third</third>\n";
    print $out_fh "<fourth>$fourth</fourth>\n";
    print $out_fh "<fifth>$fifth</fifth>\n";
    close $out_fh;

}

sub extract_content {
    my $html = shift;

    my $extractor = HTML::ExtractContent->new;
    $extractor->extract($html);
    my $content = $extractor->as_text;
    $content = clean_str($content);

    return $content;
}

# split jadi 3 bagian
# sub split_content {
#     my $content = shift;
#     print $content;

#     my @sentences = split /([.?!])\s*/, $content;
#     my $num_sentences = scalar @sentences;

#     my $num_top = int($num_sentences/3);
#     my $num_middle = $num_top;
#     my $num_bottom = $num_sentences - ($num_top*2);

#     my $top = join('', @sentences[0..$num_top-1]); # Join the first num_top sentences as top section
#     my $middle = join('', @sentences[$num_top..$num_top+$num_middle-1]); # Join the next num_middle sentences as middle section
#     my $bottom = join('', @sentences[$num_top+$num_middle..$num_sentences-1]); # Join the remaining sentences as bottom section

#     return ($top, $middle, $bottom);
# }

# split jadi 5 bagian
sub split_content {
    my $content = shift;
    print $content;

    my @sentences = split /([.?!])\s*/, $content;
    my $num_sentences = scalar @sentences;

    my $num_first = int($num_sentences/5);
    my $num_second = $num_first;
    my $num_third = $num_first;
    my $num_fourth = $num_first;
    my $num_fifth = $num_sentences - ($num_first*4);

    my $first = join('', @sentences[0..$num_first-1]); # Join the first num_first sentences as first section
    my $second = join('', @sentences[$num_first..$num_first+$num_second-1]); # Join the next num_second sentences as second section
    my $third = join('', @sentences[$num_first+$num_second..$num_first+$num_second+$num_third-1]); # Join the next num_third sentences as third section
    my $fourth = join('', @sentences[$num_first+$num_second+$num_third..$num_first+$num_second+$num_third+$num_fourth-1]); # Join the next num_fourth sentences as fourth section
    my $fifth = join('', @sentences[$num_first+$num_second+$num_third+$num_fourth..$num_sentences-1]); # Join the remaining sentences as fifth section

    return ($first, $second, $third, $fourth, $fifth);

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
    $str =~ s/<div class="photo__caption">.*?<\/div>//g;
    $str =~ s/-&nbsp;//g;


    return $str;
}
