#!/bin/perl
if ($#ARGV<1) {
  print "\n*** Bad usage, please use the command as the following line:\n";
  print "Module2Inst.pl -InputFile <Input file name> -Block_Name <block name>\n";
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
	if ($line =~ /input\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$3\($3\)\,\t\t\/\/input \[$1\:$2\] $3\n";
		print WRITE_wireIN_FILE "wire \[$1\:$2\] $3 \= 0\;\t\t\/\/input \[$1\:$2\] $3\;\n";
		print WRITE_IO_FILE "input \[$1\:$2\] $3\,\n";
	}
	elsif ($line =~ /output\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$3\($3\)\,\t\t\/\/output \[$1\:$2\] $3\n";
		print WRITE_wireOUT_FILE "wire \[$1\:$2\] $3\;\t\t\/\/output \[$1\:$2\] $3\;\n";
		print WRITE_IO_FILE "output \[$1\:$2\] $3\,\n";
	}
	elsif ($line =~ /inout\s*\[\s*(\S+)\s*\:\s*(\S+)\s*\]\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$3\($3\)\,\t\t\/\/inout \[$1\:$2\] $3\n";
		print WRITE_wireOUT_FILE "wire \[$1\:$2\] $3\;\t\t\/\/inout \[$1\:$2\] $3\;\n";
		print WRITE_IO_FILE "inout \[$1\:$2\] $3\,\n";
	}
	elsif ($line =~ /input\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$1\($1\)\,\t\t\/\/input  $1\n";
		print WRITE_wireIN_FILE "wire $1 \= 0;\t\t\/\/input  $1\;\n";
		print WRITE_IO_FILE "input  $1\,\n";
	}
	elsif ($line =~ /output\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$1\($1\)\,\t\t\/\/output  $1\n";
		print WRITE_wireOUT_FILE "wire $1\;\t\t\/\/output  $1\;\n";
		print WRITE_IO_FILE "output  $1\,\n";
	}
	elsif ($line =~ /inout\s*(\S+)\s*\;/){
		print WRITE_inst_FILE "\t\.$1\($1\)\,\t\t\/\/inout  $1\n";
		print WRITE_wireOUT_FILE "wire $1\;\t\t\/\/inout  $1\;\n";
		print WRITE_IO_FILE "inout  $1\,\n";
	}
}
close(WRITE_IO_FILE);
close(WRITE_inst_FILE);
close(WRITE_wireOUT_FILE);
close(WRITE_wireIN_FILE);
close(READ_FILE);

