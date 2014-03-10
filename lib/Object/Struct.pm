package Object::Struct;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Object::Struct', $VERSION);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

1;
__END__

=head1 NAME

Object::Struct - bla bla

=head1 SYNOPSIS

  use Object::Struct;
  blabla

=head1 DESCRIPTION

=head2 EXPORT

=head1 SEE ALSO

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
