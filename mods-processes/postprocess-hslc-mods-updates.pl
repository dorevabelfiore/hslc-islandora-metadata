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
	
	system("java -Xmx1000M -Xms1000M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:_tmp.1 -s:$infile -xsl:hslc-mods-updates-template.xsl");
	system("java -Xmx1000M -Xms1000M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:$outfile -s:_tmp.1 -xsl:cdm-mods-updates-single-children.xsl");

}

unlink("_tmp.*");

system("time /t"); # time end
