#!perl -T

use strict;
use warnings;
use Test::More tests => 18;

BEGIN {
  use_ok ('Bio::LITE::Taxonomy'); # T1
  use_ok ('Bio::LITE::Taxonomy::NCBI'); # T2
}

can_ok ("Bio::LITE::Taxonomy", qw/get_taxonomy get_taxonomy_with_levels get_level_from_name get_taxid_from_name get_taxonomy_from_name/); # T3
can_ok ("Bio::LITE::Taxonomy::NCBI", qw/new get_taxonomy_from_gi get_taxonomy_with_levels_from_gi get_term_at_level_from_gi/); # T4

SKIP: {
  my $datapath = "t/data";

  my $n_block_tests = 14;

  skip "names.dmp file not found", $n_block_tests unless (-e "${datapath}/names.dmp");
  skip "nodes.dmp file not found", $n_block_tests unless (-e "${datapath}/nodes.dmp");
  skip "names.dmp file not readable", $n_block_tests unless (-r "${datapath}/names.dmp");
  skip "nodes.dmp file not readable", $n_block_tests unless (-r "${datapath}/nodes.dmp");

  my $taxNCBI = new_ok ( "Bio::LITE::Taxonomy::NCBI" => [(nodes=>"${datapath}/nodes.dmp",names=>"${datapath}/names.dmp")] ); # T5
  my ($tax,@tax);
  eval {
    @tax = $taxNCBI->get_taxonomy(1442);
  };
  is($@,"",""); # T6
  ok($#tax == 9, "");                   # T7
  is($tax[0],"cellular organisms", "");       # T8

  eval {
    $tax = $taxNCBI->get_taxonomy(1442);
  };
  isa_ok($tax,"ARRAY"); # T9

  my $level;
  eval {
    $level = $taxNCBI->get_level_from_name("Bacillaceae");
  };
  is($@,"",""); # T10
  is($level,"family",""); # T11

  eval {
    $tax = $taxNCBI->get_taxonomy(3);
  };
  is($tax,"",""); # T12

  eval {
    $tax = $taxNCBI->get_taxonomy();
  };
  ok (!defined $tax, ""); # T13

 SKIP: {
    my $n = 5;
    eval { require Bio::LITE::Taxonomy::NCBI::Gi2taxid };
    skip "Bio::LITE::Taxonomy::NCBI::Gi2taxid not installed", $n if $@;
    my $dict_path = "t/data/dict.bin";
    skip "dict sample file not found", $n unless (-e $dict_path);
    skip "dict sample not readable", $n unless (-e $dict_path);
#    skip "dict sample not in binary format", $n unless (-b $dict_path);

    my $taxNCBI = new_ok ( "Bio::LITE::Taxonomy::NCBI" => [(nodes=>"${datapath}/nodes.dmp",names=>"${datapath}/names.dmp",dict=>$dict_path)] );

    my $tax;
    eval {
      $tax = $taxNCBI->get_taxonomy_from_gi(2);
    };
    is($@,"","");
    is($tax->[0],"cellular organisms");

    my $taxid;
    eval {
      $taxid = $taxNCBI->get_taxid(3);
    };
    die $@ if $@;
    ok (defined $taxid, ""); # T14
    ok ($taxid == 3,""); # T15

  }
}

done_testing();
