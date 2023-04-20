use Lingua::EN::Bigram;
use strict;

my $PATH = "kamus/tren";
open TOFILE, "> $PATH/trigram.txt" or die "cant open file!!!";

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

# get tri-gram counts
my $trigram_count = $ngrams->trigram_count;

my %trigram_freq;
my $total_trigrams = 0;

foreach my $trigram (keys %$trigram_count) {

  # get the tokens of the trigram
  my ($first_token, $second_token, $third_token) = split / /, $trigram;

  # skip punctuation
  next if ( $first_token =~ /[,.?!:;()\-]/ );
  next if ( $second_token =~ /[,.?!:;()\-]/ );
  next if ( $third_token =~ /[,.?!:;()\-]/ );
  # skip stopwords;
  next if ( $stopwords{ $first_token } );
  next if ( $stopwords{ $second_token } );
  next if ( $stopwords{ $third_token } );;

  # accumulate the count of non-stopword trigrams
  $total_trigrams += $$trigram_count{ $trigram };

  # save the count of each trigram
  $trigram_freq{ $trigram } = $$trigram_count{ $trigram };

}

foreach my $trigram (sort{ $trigram_freq{ $b } <=> $trigram_freq{ $a } } keys %trigram_freq) {

  # get the tokens of the trigram
  my ($first_token, $second_token, $third_token) = split / /, $trigram;

  # calculate the normalized frequency
  my $freq_norm = $trigram_freq{ $trigram } / $total_trigrams;

  print TOFILE "$trigram_freq{ $trigram }\t$freq_norm\t$trigram\n";

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
