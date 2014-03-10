use strict;
use warnings;
use Test::More tests => 8;
use Object::Struct;

Object::Struct::make_class("Foo", [qw(foo bar baz)]);

SCOPE: {
  my $f = Foo->new;
  isa_ok($f, "Foo");
  ok(!defined($f->foo), "starts out undefined");
  is($f->foo(42), 42, "setting works");
  is($f->foo(), 42, "getting works");
  $f->bar(12);
  $f->baz(13);
  is($f->bar(), 12);
  is($f->baz(), 13);
  is($f->foo(), 42);
}

pass("Alive");
