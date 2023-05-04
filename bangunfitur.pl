use strict;
use warnings;
use lib 'Lingua-EN-Ngram-0.03/lib/';
use Lingua::EN::Ngram;
use POSIX qw(ceil);

my $ngrams = Lingua::EN::Ngram->new;
my $gram_score;
my $PATH    = "./4000";
my $dirfile = "./fitur";
if ( !$dirfile ) {
    print "Cara jalankan : $0 <directory file>\n";
}

sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

my @dictionary = ("kamus-tanpa-duplikasi/properti_dict.txt", "kamus-tanpa-duplikasi/tren_dict.txt");

print "Load & Hash Dictionary\n";
my ( %hashproperti, %hashtren );

foreach my $dictfile (@dictionary) {

    open my $dict, "<", $dictfile or die "Cannot open $dictfile: $!";
    while ( my $line = <$dict> ) {

        chomp($line);
        next if ( $line =~ /^#|^$/ );
        my @formats = split /:/, trim($line);
        if ( !exists( $hashproperti{ $formats[0] } ) && $dictfile =~ /properti/ ) {
            $hashproperti{ $formats[0] } = 1;
        }
        elsif ( !exists( $hashtren{ $formats[0] } ) && $dictfile =~ /tren/ ) {
            $hashtren{ $formats[0] } = 1;
        }
    }
}

my $process = 0;
foreach my $dir ( ( "$PATH/properti", "$PATH/tren" ) ) {
    my @srcfile = split /\//, $dir;
    open OUT, "> $dirfile/feature_$srcfile[2].dat"
      or die "Can't open file...";
    open ARFF, "> $dirfile/feature_$srcfile[2].arff"
      or die "Can't open file...";
    print ARFF "\@relation feature_$srcfile[2]\n\n";
    foreach my $iterate ( 1 .. 36 ) {
        print ARFF "\@attribute feature$iterate numeric\n";
    }
    print ARFF "\@attribute class {properti,tren}\n\n\@DATA\n";

    my @files = glob( $dir . '/*' )
      or die "No input files found in $dir";
    print $dir;
    my $number = 1;

    foreach my $file (@files) {
        $process++;

        open F, $file or die "Can't open input: $!\n";
        my $text = do { local $/; <F> };
        close F;
        $text =~ s/\n+//gs;

        if ( $file =~ /properti/ ) {
            print OUT "properti ";
        }
        else {
            print OUT "tren ";
        }

        my @sections = (
            get_text( $text, "title" ),
            get_text( $text, "bagian1" ),
            get_text( $text, "bagian2" ),
            get_text( $text, "bagian3" ),
            get_text( $text, "bagian4" ),
            get_text( $text, "bagian5" ),
        );
        my @weight = ( 1, 0.2, 0.2, 0.2, 0.2, 0.2 );
        for ( my $sec = 0 ; $sec < @sections ; $sec++ ) {
            for ( my $dict = 0 ; $dict < @dictionary ; $dict++ ) {
                foreach my $n ( 1 .. 3 ) {
                    $gram_score = 0;
                    if ( $dictionary[$dict] =~ /properti/ ) {
                        $gram_score =
                          count_section( $sections[$sec], \%hashproperti, $n ) *
                          $weight[$sec];
                    }
                    elsif ( $dictionary[$dict] =~ /tren/ ) {
                        $gram_score =
                          count_section( $sections[$sec], \%hashtren, $n ) *
                          $weight[$sec];
                    }

                    print ARFF sprintf( "%.4f", $gram_score ) . ",";
                    print OUT "$number:" . sprintf( "%.4f", $gram_score ) . " ";
                    $number++;
                }
            }
        }
        if ( $file =~ /properti/ ) {
            print ARFF "properti\n";
        }
        else {
            print ARFF "tren\n";
        }
        print OUT "\n";
        $number = 1;
        if ( $process % 1000 == 0 ) {
            print "\nDone : $process\n";
        }
    }
    close OUT;
    close ARFF;
}

sub get_text {
    my ( $text, $regex ) = @_;

    if ( $text =~ /<$regex>(.*?)<\/$regex>/ ) {
        return $1;
    }
}

sub count_section {
    my ( $section, $hash, $n ) = @_;
    my $count = 0;
    my $sect  = clean_string($section);

    $ngrams->text( $sect . "." );
    my $txt     = $ngrams->text;
    my $grams   = $ngrams->ngram($n);
    my $gramlen = 0;

    foreach my $gram ( sort { $$grams{$b} <=> $$grams{$a} } keys %$grams ) {
        $gramlen++;
        chomp($gram);

        next if ( $gram =~ /^#/ || $gram =~ /^$/ );

        if ( defined $$hash{$gram} ) {
            $count++;
        }
        else {
            $count = 1;
        }
    }

    if ( $count == 0 ) {
        return 0;
    }
    else {
        return ( $count / $gramlen );
    }
}

sub clean_string {
    my $file = shift;
    $file =~ s/<.*?>//g;
    $file =~ s/\s\w+=.*?>/ /g;
    $file =~ s/>//g;
    $file =~ s/&.*?;//g;
    $file =~ s/[\:\]\|\[\?\!\@\#\$\%\*\&\,\/\\\(\)\;]+//g;
    $file =~ s/-/ /g;
    $file =~ s/\s+/ /g;
    $file = lc($file);
    return $file;
}