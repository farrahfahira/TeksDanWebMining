use Lingua::EN::Bigram;
use strict;

my $PATH = "kamus/tren";
open TOFILE, "> $PATH/unigram.txt" or die "cant open file!!!";

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

# get uni-gram counts
my $unigram_count = $ngrams->unigram_count;

my %unigram_freq;
my $total_unigrams = 0;

foreach my $unigram (keys %$unigram_count) {

  # get the tokens of the uni-gram
  my ($first_token) = $unigram;

  # skip punctuation
  next if ( $first_token =~ /[,.?!:;()\-]/ );
  # skip stopwords;
  next if ( $stopwords{ $first_token } );

  # accumulate the count of total unigrams
  $total_unigrams += $$unigram_count{ $unigram };

  # save the count of each unigram
  $unigram_freq{ $unigram } = $$unigram_count{ $unigram };

}

foreach my $unigram (sort{ $unigram_freq{ $b } <=> $unigram_freq{ $a } } keys %unigram_freq) {

  # get the tokens of the uni-gram
  my ($first_token) = $unigram;

  # calculate the normalized frequency
  my $freq_norm = $unigram_freq{ $unigram } / $total_unigrams;

  print TOFILE "$unigram_freq{ $unigram }\t$freq_norm\t$unigram\n";

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
