#! perl -w
use strict;

system("time /t"); # time begin

my $inputdir = "in";
my $outputdir = "out";

my @files = glob("$inputdir/*.xml");


foreach my $infile (@files)
{
    my $outfile = $infile;
    $outfile =~ s/^$inputdir/$outputdir/o;
	
	system("java -Xmx1350M -Xms1350M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:\"$outfile\" -s:\"$infile\" -xsl:split-mods-files.xsl objects-per-file=10000");

}

# unlink("_tmp.*");

system("time /t"); # time end
