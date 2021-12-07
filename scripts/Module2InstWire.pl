#!/bin/perl
if ($#ARGV<1) {
  print "\n*** Bad usage, please use the command as the following line:\n";
  print "Module2InstWire.pl -InputFile <Input file name> -Block_Name <block name>\n";
  print "example:\n Module2Inst\.pl -InputFile input_file_name\.txt -Block_Name block_name\n";
  exit;
}
$token=$ARGV[0];
while ($ARGV=shift) {
  if ($token =~ /^-InputFile/) {
    print "input_file= $ARGV[0] \t";
    $input_file=$ARGV[0];
  }
  if ($token =~ /^-Block_Name/) {
    print "Block Name : $ARGV[0] \n";
    $Block_Name=$ARGV[0];
  }
  shift;
  $token=$ARGV[0];
}
$InstFile = "$Block_Name\_Inst\.txt";
$WireInputFile = "$Block_Name\_WireIN\.txt";
$WireOutputFile = "$Block_Name\_WireOUT\.txt";
$WireIOFile = "$Block_Name\_IO\.txt";
print "\n";
print "inst file       : $InstFile\n";
print "WireInput file  : $WireInputFile\n";
print "WireOutput file : $WireOutputFile\n";
print "WireIO file     : $WireIOFile\n";

open (READ_FILE,$input_file) || die "error: Can't open $flash_file ";
open (WRITE_wireIN_FILE,">$WireInputFile") || die "error: Can't open $WireInputFile ";
open (WRITE_wireOUT_FILE,">$WireOutputFile") || die "error: Can't open $WireOutputFile ";
open (WRITE_inst_FILE,">$InstFile") || die "error: Can't open $InstFile ";
open (WRITE_IO_FILE,">$WireIOFile") || die "error: Can't open $WireIOFile ";

while ($line = <READ_FILE>) {
	if ($line =~ /input\s*(\S+)\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$4\($4\)\,\t\t\/\/input \[$2\:$3\] $4\n";
		print WRITE_wireIN_FILE "$1 \[$2\:$3\] $4 \= 0\;\t\t\/\/input \[$2\:$3\] $4\;\n";
		print WRITE_IO_FILE "input \[$2\:$3\] $4\,\n";
	}
	elsif ($line =~ /output\s*(\S+)\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$4\($4\)\,\t\t\/\/output \[$2\:$3\] $4\n";
		print WRITE_wireOUT_FILE "$1 \[$2\:$3\] $4\;\t\t\/\/output \[$2\:$3\] $4\;\n";
		print WRITE_IO_FILE "output \[$2\:$3\] $4\,\n";
	}
	elsif ($line =~ /inout\s*(\S+)\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$4\($4\)\,\t\t\/\/inout \[$2\:$3\] $4\n";
		print WRITE_wireOUT_FILE "$1 \[$2\:$3\] $4\;\t\t\/\/inout \[$2\:$3\] $4\;\n";
		print WRITE_IO_FILE "inout \[$1\:$2\] $3\,\n";
	}
	elsif ($line =~ /input\s*(\S+)\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$2\($2\)\,\t\t\/\/input  $2\n";
		print WRITE_wireIN_FILE "$1 $2 \= 0;\t\t\/\/input  $2\;\n";
		print WRITE_IO_FILE "input  $2\,\n";
	}
	elsif ($line =~ /output\s*(\S+)\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$2\($2\)\,\t\t\/\/output  $2\n";
		print WRITE_wireOUT_FILE "$1 $2\;\t\t\/\/output  $2\;\n";
		print WRITE_IO_FILE "output  $2\,\n";
	}
	elsif ($line =~ /inout\s*(\S+)\s*(\S+)\s*\,/){
		print WRITE_inst_FILE "\t\.$2\($2\)\,\t\t\/\/inout  $2\n";
		print WRITE_wireOUT_FILE "$1 $2\;\t\t\/\/inout  $2\;\n";
		print WRITE_IO_FILE "inout  $2\,\n";
	}
}
close(WRITE_IO_FILE);
close(WRITE_inst_FILE);
close(WRITE_wireOUT_FILE);
close(WRITE_wireIN_FILE);
close(READ_FILE);

