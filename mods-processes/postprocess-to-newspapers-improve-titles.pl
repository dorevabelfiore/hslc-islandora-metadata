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

	system("java -Xmx1200M -Xms1200M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:_tmp.1 -s:$infile -xsl:hslc-mods-updates-template.xsl");
	system("java -Xmx1200M -Xms1200M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:_tmp.2 -s:_tmp.1 -xsl:hslc-mods-improve-titles.xsl");
	system("java -Xmx1200M -Xms1200M -cp C:\\Saxonica9.6\\saxon9pe.jar net.sf.saxon.Transform -t -o:$outfile -s:_tmp.2 -xsl:cdm-mods-final-level-to-newspapers.xsl islandora-namespace=papd");

}

# unlink("_tmp.*");

system("time /t"); # time end
