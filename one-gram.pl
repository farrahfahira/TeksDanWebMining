use lib '../lib';
use Lingua::EN::Bigram;
use strict;

my $PATH = "kamus/tren";
open TOFILE, "> $PATH/1-gram.txt" or die "cant open file!!!";

my %stopwords;

load_stopwords(\%stopwords);

# ambil daftar file dari direktori yang diinginkan
my $dir = "clean/tren";
opendir(DIR, $dir) or die "Can't open directory: $!\n";
my @files = grep { /\.dat$/ } readdir(DIR);
closedir(DIR);

my $index = 0;

# proses setiap file secara terpisah
foreach my $file (@files) {
  open F, "$dir/$file" or die "Can't open input: $!\n";
  my $text = do { local $/; <F> };
  close F;

  # menghilangkan tag html
  $text =~ s/<[^>]+>//g;

  # build n-grams
  my $ngrams = Lingua::EN::Bigram->new;
  $ngrams->text( $text );

  # get bi-gram counts
  my $onegram_count = $ngrams->onegram_count;

  foreach my $onegram (keys %$onegram_count ) {

    # get the tokens of the bigram
    my ( $first_token ) = $onegram;

    # skip stopwords and punctuation
    next if ( $stopwords{ $first_token } );
    next if ( $first_token =~ /[,.?!:;()\-]/ );

    $index++;

    print TOFILE "$$onegram_count{ $onegram }\t$onegram\n";

  }
}

sub load_stopwords 
{
  my $hashref = shift;
  open IN, "stopword.txt" or die "Cannot Open File!!!";
  while (<IN>)
  {
    chomp;
    if(!defined $$hashref{$_})
    {
       $$hashref{$_} = 1;
    }
  }  
}
