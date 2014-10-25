#!/usr/bin/perl -w

use strict;
use Graphics::Magick;


# provincias
open(PRV,"provincias.tsv")||die"PRV:$!";
my@prv=<PRV>;
chomp@prv;
my%prv=map{my@a=split(/\t/,$_); $a[0]=>$a[1]}@prv;
close PRV;


# get data
open(TSV,$ARGV[0])||die"TSV: $!";
my@tsv=<TSV>;
chomp@tsv;
@tsv=map{my@a=split(/\t/,$_); 
         {provincia=>$a[0],
          fuente=>$a[1],
          fechahora=>$a[2],
          titulo=>$a[3] 
         } }@tsv;
close TSV;


# transform the dates to floating point
@tsv = map { my $d=$_->{fechahora}; 
             my ($f,$h) = $d=~m/^([^ ]+) (.*)/;
             $_->{fecha} = $f;
             my @ff=split(/\//,$f);
             my $ac = $ff[0] + $ff[1] * 31 + $ff[2];
             my ($hh,$apm)= $h=~m/^([^ ]+) (.*)/;
             my @hh=split(/\:/,$hh);
             if($apm eq "p.m."){
                 $hh[0] += 12;
             }
             $ac = $ac * 10000 + $hh[0] * 100 + $hh[1] * 10 + $hh[2];
             $_->{fechahoran} = $ac;
             $_ } @tsv;

@tsv = sort { $a->{fechahoran} <=> $b->{fechahoran} } @tsv;


my $image = Graphics::Magick->new;
$image->Set(size=>'390x828');
$image->Read('mapa_2.jpg');
my $base = Graphics::Magick->new;
$base->Set(size=>'390x828');
$base->Read('mapa_2.jpg');

my$prevfecha=0;
my$r;
my$c=0;
foreach my$t(@tsv){
    if($prevfecha && (!($prevfecha eq $t->{fecha}))){
        $image->Annotate(font=>'/usr/share/fonts/truetype/ttf-isabella/Isabella.ttf', pointsize=>30,
                         fill=>"#777777", stroke=>"black",
                         text=>$prevfecha, 'y' => 30, x=>50);
        $prevfecha =~ s/\///g;
        my$cc = $c;
        $cc = "0$cc" if($c<100);
        $cc = "0$cc" if($c<10);
        $r = $image->Write(filename=>"frames/$cc.$prevfecha.jpg", compression=>"jpeg", quality=>9);
        die $r if $r;
        $prevfecha = $t->{fecha};
        $image->Draw(fill=>"white", stroke=>"white",
                     primitive=>"polygon", points=>"0,0,0,828,390,828,390,0");
        $image->Composite(image=>$base, compose=>'Over', x=>0, 'y'=>0, opacity=>100);
        #$image->Read('mapa_2.jpg');
        $c++;
    }elsif(!$prevfecha){
        $prevfecha = $t->{fecha};
    }

    if($t->{titulo}){
        open(TMP,">/tmp/render.tmp")||die "TMP: $!";
        print TMP $t->{titulo}."\n";
        close TMP;
        $t->{granizo} = `cat /tmp/render.tmp | dbacl -v -c ./train3/models/granizo -c ./train3/models/normal` eq "granizo\n";
        if($t->{granizo}){
            $image->Draw(fill=>"#333333", stroke=>"black",
                         primitive=>"polygon", points=>$prv{$t->{provincia}});
        }
        print $t->{fechahora}."\t".$t->{provincia}."\t".$t->{titulo}."\n" if($t->{granizo});
    }
}
$r = $image->Write(filename=>"frames/$c.$prevfecha.jpg", compression=>"jpeg", quality=>9);

`mencoder "mf://frames/*.jpg" -mf fps=43 -o render.avi -ovc lavc -lavcopts vcodec=mpeg4`;
