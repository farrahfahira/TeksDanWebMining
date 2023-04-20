use Lingua::EN::Bigram;
use strict;

my $PATH = "kamus/tren";
open TOFILE, "> $PATH/bigram.txt" or die "cant open file!!!";

my %stopwords;
load_stopwords(\%stopwords);

# ambil daftar file dari direktori yang diinginkan
my $dir = "clean/tren";
opendir(DIR, $dir) or die "Can't open directory: $!\n";
my @files = grep { /\.dat$/ } readdir(DIR);
closedir(DIR);

# inisialisasi variabel text
my $text = '';

# proses setiap file secara terpisah
foreach my $file (@files) {
  open F, "$dir/$file" or die "Can't open input: $!\n";
  my $file_text = do { local $/; <F> };
  close F;

  # menghilangkan tag html
  $file_text =~ s/<[^>]+>//g;

  # gabungkan file_text ke variabel $text
  $text .= $file_text;

}

# build n-grams
my $ngrams = Lingua::EN::Bigram->new;
$ngrams->text( $text );

# get bigram counts
my $bigram_count = $ngrams->bigram_count;

my %bigram_freq;
my $total_bigrams = 0;

foreach my $bigram (keys %$bigram_count) {

  # get the tokens of the bigram
  my ( $first_token, $second_token ) = split / /, $bigram;

  # skip stopwords and punctuation
  next if ( $stopwords{ $first_token } );
  next if ( $first_token =~ /[,.?!:;()\-]/ );
  next if ( $stopwords{ $second_token } );
  next if ( $second_token =~ /[,.?!:;()\-]/ );

  # accumulate the count of non-stopword bigrams
  $total_bigrams += $$bigram_count{ $bigram };

  # save the count of each bigram
  $bigram_freq{ $bigram } = $$bigram_count{ $bigram };

}

foreach my $bigram (sort{ $bigram_freq{ $b } <=> $bigram_freq{ $a } } keys %bigram_freq) {

  # get the tokens of the bigram
  my ( $first_token, $second_token ) = split / /, $bigram;

  # calculate the normalized frequency
  my $freq_norm = $bigram_freq{ $bigram } / $total_bigrams;

  print TOFILE "$bigram_freq{ $bigram }\t$freq_norm\t$bigram\n";

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
