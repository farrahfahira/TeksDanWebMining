use strict;

# membuka file kamus unigram untuk kategori properti
open my $properti_file, '<', 'kamus/properti/unigram.txt' or die "Cannot open file: $!";

# membuka file kamus unigram untuk kategori tren
open my $tren_file, '<', 'kamus/tren/unigram.txt' or die "Cannot open file: $!";

# membaca nilai normalisasi frekuensi dari file dan menyimpannya dalam bentuk hash (untuk properti)
my %properti_freq_norm;
while (my $line = <$properti_file>) {
  chomp($line);
  my ($count, $freq, $word) = split(/\t/, $line);
  $properti_freq_norm{$word} = $freq;
}

# membaca nilai normalisasi frekuensi dari file dan menyimpannya dalam bentuk hash (untuk tren)
my %tren_freq_norm;
while (my $line = <$tren_file>) {
  chomp($line);
  my ($count, $freq, $word) = split(/\t/, $line);
  $tren_freq_norm{$word} = $freq;
}

# menutup file
close $properti_file;
close $tren_file;

# inisialisasi hash untuk kata-kata yang tereliminasi
my %eliminated_words;

# threshold untuk eliminasi rasio
my $threshold = 0.5;

# inisialisasi hash untuk kata-kata yang tereliminasi
my %eliminated_ratios;

# eliminasi kata yang duplikat dan melakukan eliminasi rasio
foreach my $word (keys %properti_freq_norm) {
  if (exists $tren_freq_norm{$word}) {
    my $ratio = ($properti_freq_norm{$word} > $tren_freq_norm{$word}) ? $tren_freq_norm{$word} / $properti_freq_norm{$word} : $properti_freq_norm{$word} / $tren_freq_norm{$word};
    $eliminated_ratios{$word} = $ratio;
    if ($ratio >= 0.5) {
      delete $properti_freq_norm{$word};
      delete $tren_freq_norm{$word};
      # tambahkan kata ke hash untuk kata-kata yang tereliminasi dan keterangan kamusnya
      $eliminated_words{$word} = "kedua kamus";
    } elsif ($ratio < 0.5) {
      if ($properti_freq_norm{$word} < $tren_freq_norm{$word}) {
        delete $properti_freq_norm{$word};
        # tambahkan kata ke hash untuk kata-kata yang tereliminasi dan keterangan kamusnya
        $eliminated_words{$word} = "properti";
      } else {
        delete $tren_freq_norm{$word};
        # tambahkan kata ke hash untuk kata-kata yang tereliminasi dan keterangan kamusnya
        $eliminated_words{$word} = "tren";
      }
    }
  }
}

# simpan kamus properti yang sudah dieliminasi ke file txt
open my $properti_outfile, '>', 'kamus-tanpa-duplikasi/properti/unigram.txt' or die "Cannot open output properti file: $!";
foreach my $word (sort keys %properti_freq_norm) {
  print $properti_outfile "$properti_freq_norm{$word}\t$word\n";
}

# menutup file
close $properti_outfile;

# simpan kamus tren yang sudah dieliminasi ke file txt
open my $tren_outfile, '>', 'kamus-tanpa-duplikasi/tren/unigram.txt' or die "Cannot open output tren file: $!";
foreach my $word (sort keys %tren_freq_norm) {
  print $tren_outfile "$tren_freq_norm{$word}\t$word\n";
}

# menutup file
close $tren_outfile;

# simpan kata-kata yang tereliminasi ke file txt
open my $eliminated_outfile, '>', 'kamus-tanpa-duplikasi/eliminated_words.txt' or die "Cannot open eliminated words file: $!";
foreach my $word (sort keys %eliminated_words) {
  print $eliminated_outfile "$eliminated_ratios{$word}\t$word dihapus dari $eliminated_words{$word}\n";
}

# menutup file
close $eliminated_outfile;

print "Eliminasi selesai. Kamus properti dan tren yang telah dieliminasi serta kata-kata yang tereliminasi tersimpan dalam file txt.\n";