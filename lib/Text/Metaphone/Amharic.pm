package Text::Metaphone::Amharic;

# If either of these next two lines are inside
# the BEGIN block the package will break.
#
use utf8;
use Regexp::Ethiopic::Amharic qw(:forms overload setForm);

BEGIN
{
	use strict;
	use vars qw( $VERSION %IMExpected %IMError %plosives $GRANDULARITY $STYLE );

	$VERSION = "0.05";

	%plosives = (
		k => 'ቀ',
		t => 'ጠ',
		ʧ => 'ጨ',
		s => 'ጸ',
		p => 'ጰ',
	);
	%IMExpected =(
		ስ => "s",
		ጽ => "s'",
		ቅ => "k'",
		ቕ => "q",
		ት => "t",
		ጥ => "t'",
		ች => "ʧ",
		ጭ => "ʧ",
		ን => "n",
		ክ => "k",
		ዝ => "z",
		ዥ => "ʒ",
		ጵ => "p'",
		ፕ => "p"
	);
	%IMError  =(
		ስ => [ "ጽ", "s'" ],
		ጽ => [ "ስ", "s"  ],
		ቅ => [ "ቕ", "q"  ],
		ቕ => [ "ቅ", "k'" ],
		ት => [ "ጥ", "t'" ],
		ጥ => [ "ት", "t"  ],
		ች => [ "ጭ", "ʧ'" ],
		ጭ => [ "ች", "ʧ"  ],
		ን => [ "ኝ", "ɲ"  ],
		ክ => [ "ኽ", "x"  ],
		ዝ => [ "ዥ", "ʒ"  ],
		ዥ => [ "ዝ", "z"  ],
		ጵ => [ "ፕ", "p"  ],
		ፕ => [ "ጵ", "p'" ]
	);
	$GRANDULARITY = "low";
	$STYLE       = "ethio";
}


sub import
{
my ( $pkg, %args ) = @_;

	$STYLE        = lc($args{style})        if ( $args{style}         );
	$GRANDULARITY = lc($args{grandularity}) if ( $args_{grandularity} );
}


sub new
{
my $class = shift;
my $self = { style => 0, _style => $STYLE, _grandularity => $GRANDULARITY };

	my $blessing = bless ( $self, $class );

	%_ = @_;

	$self->{_grandularity} = lc($_{grandularity}) if ( $_{grandularity}        );
	$self->{_style}        = lc($_{style})        if ( $_{style}               );
	$self->{style}         = 1                    if ( $self->{_style} eq "ipa" );

	$blessing;
}


sub metaphone
{
my $self = shift;

	$_ = $self->simplify($_[0]);
	my ($re, @keys) = $self->glyphs ( $_ );
	($re, @keys)    = $self->phono  ( $re, @keys );
	($re, @keys)    = $self->im     ( $re, @keys );

	if ( @keys ) {
		push ( @keys, qr/$re/ );	
	}

	(wantarray) ? @keys : $keys[0];
}


sub simplify
{
my $self = shift;

	$_ = $_[0];

	#
	# strip out all but first vowel:
	#
	if ( $self->{style} ) {
		s/^[=#አ#=]/a/;
		s/[=#ሀ#=]/h/g;
	}
	else {
		s/^[=#አ#=]/አ/;
		s/[=#ሀ#=]/ሀ/g;
	}

	s/(.)[=#አ#=]/$1/g;
	s/([#11#])/setForm($1,$ሳድስ)."ዋ"/eg;
	s/[=#ሰ#=]/ሰ/g;
	s/[=#ጸ#=]/ጸ/g;

	#
	# now strip vowels, this simplies later code:
	#
	s/(\p{InEthiopic})/ ($1 eq 'ኘ') ? $1 : setForm($1,$ሳድስ)/eg;

	tr/ልምርሽብቭውይድጅግፍ/lmrʃbvwjdʤgf/ if ( $self->{style} );

	$_;
}


sub glyphs
{
my $self = shift;


	my @keys = ( $_[0] );
	my $re = $_[0];

	if ( $self->{style} ) {
	#
	#  Confusion with ዽ
	#
	if ( $keys[0] =~ /ዽ/ ) {
		$keys[2] = $keys[1] = $keys[0];
		$keys[0] =~ s/ዽ/d/;    # caps problem
		$keys[1] =~ s/ዽ/ɗ/;    # literal
		$keys[2] =~ s/ዽ/p'/;   # mistaken glyph
		$re =~ s/ዽ/([dɗ]|p')/g;
	}
	#
	#  Confusion with ኘ
	#
	if ( $keys[0] =~ /ኘ/ ) {
		my (@newKeysA, @newKeysB);
		for (my $i=0; $i < @keys; $i++) {
			$newKeysA[$i] = $newKeysB[$i] = $keys[$i];  # copy old keys
			$keys[$i]     =~ s/ኘ/ɲ/;    # literal
			$newKeysA[$i] =~ s/ኘ/n/;    # caps problem
			$newKeysB[$i] =~ s/ኘ/p/;    # mistaken glyph
		}
		push (@keys,@newKeysA);  # add new keys to old keys
		push (@keys,@newKeysB);  # add new keys to old keys
		$re =~ s/ኘ/[nɲp]/g;
	}
	#
	} else {
	#
	#  Confusion with ዽ
	#
	if ( $keys[0] =~ /ዽ/ ) {
		$keys[2] = $keys[1] = $keys[0];
		$keys[0] =~ s/ዽ/ድ/;    # caps problem
		                       # $keys[1] literal
		$keys[2] =~ s/ዽ/ጵ/;    # mistaken glyph
		$re =~ s/ዽ/([ድዽጵ])/g;
	}
	#
	#  Confusion with ኘ
	#
	if ( $keys[0] =~ /ኘ/ ) {
		my (@newKeysA, @newKeysB);
		for (my $i=0; $i < @keys; $i++) {
			$newKeysA[$i] = $newKeysB[$i] = $keys[$i];  # copy old keys
			                            # $keys[$i] literal
			$newKeysA[$i] =~ s/ኘ/ን/;    # caps problem
			$newKeysB[$i] =~ s/ኘ/ፕ/;    # mistaken glyph
		}
		push (@keys,@newKeysA);  # add new keys to old keys
		push (@keys,@newKeysB);  # add new keys to old keys
		$re =~ s/ኘ/[ኘንፕ]/g;
	}
	#
	}  # end if ( $self->{sytle} )

	($re, @keys);
}


sub phono
{
my ( $self, $re, @keys ) = @_;


	if ( $self->{style} ) {
		#
		#  handle phonological problems
		#
		if ( $keys[0] =~ /mb/ ) {
			my @newKeys;
			for (my $i=0; $i < @keys; $i++) {
				$newKeys[$i] = $keys[$i];  # copy old keys
				$newKeys[$i] =~ s/mb/nb/;  # update old keys for primary mapping
			}
			push (@keys,@newKeys);  # add new keys to old keys
			$re =~ s/mb/[mn]b/g;
		}
	} else {

		if ( $keys[0] =~ /ምብ/ ) {
			my @newKeys;
			for (my $i=0; $i < @keys; $i++) {
				$newKeys[$i] = $keys[$i];  # copy old keys
				$newKeys[$i] =~ s/ምብ/ንብ/;  # update old keys for primary mapping
			}
			push (@keys,@newKeys);  # add new keys to old keys
			$re =~ s/ምብ/[ምን]ብ/g;
		}
	}

	($re, @keys);
}


sub im
{
my ( $self, $re, @keys ) = @_;

	#
	#  Handle IM problems
	#  try to keep least probable keys last:
	#
	$_ = $keys[0];                                       # fold upper   # bidi folding
	my $keyboard = ( $self->{_grandularity} eq "low" ) ? qr/([ቕዥጥጭጽጵ])/ : qr/([ስቅቕትችንክዝዥጥጭጽጵፕ])/ ;
	while ( /$keyboard/ ) {
		my $a = $1;
		my @newKeys;
		s/$a/$IMExpected{$a}/;
		for (my $i=0; $i < @keys; $i++) {
			$newKeys[$i] = $keys[$i];           # copy old keys
			$keys[$i] =~ s/$a/$IMExpected{$a}/  # update old keys for primary mapping
				if ( $self->{style} );
		}
		$newKeys[0] =~ s/$a/ሀ$IMError{$a}->[$self->{style}]/;  # update new keys for alternative
		for (my $i=1; $i < @newKeys; $i++) {
			$newKeys[$i] =~ s/([^ሀ])$a/$1ሀ$IMError{$a}->[$self->{style}]/;  # update new keys for alternative
		}
		push (@keys,@newKeys);   # add new keys to old keys

		if ( $self->{style} ) {
			if ( $plosives{$IMExpected{$a}} || $plosives{$IMError{$a}} ) {
				$re =~ s/$a/($IMExpected{$a}|$IMError{$a}->[$self->{style}])/g;
			}
			else {
				$re =~ s/$a/[$IMExpected{$a}$IMError{$a}->[$self->{style}]]/g;
			}
		}
		else {
			$re =~ s/$a/[$a$IMError{$a}->[$self->{style}]]/g;
		}
	}


	#
	# convert symbols that were missed in low grandularity mode:
	#
	if ( $self->{style} && ($self->{_grandularity} eq "low") ) {
		$re =~ s/([ስቅትችንክዝፕ])/$IMExpected{$1}/g;
		foreach my $i (0..$#keys) {
			$keys[$i] =~ s/([ስቅትችንክዝፕ])/$IMExpected{$1}/g;
		}
	}
	foreach my $i (1..$#keys) {
		$keys[$i] =~ s/ሀ//g;
	}

	($re, @keys);
}


sub reverse_ipa_key
{
my $self = shift;

	$_ = $_[0];
	
	s/([stʧkp])'/$plosives{$1}/g;
	tr/hlmrsʃqbvtʧnɲakwjdɗʤzʒgɲfp/ሀለመረሰሸቐበቨተቸነኘአከወየደዸጀዘዠገጘፈፐ/;
	s/(\p{InEthiopic})/[#$1#]/g;
	s/ዸ/ደዸ/g;
	s/ጘ/ገጘ/g;

	$_;
}


sub style
{
my $self = shift;

	if (@_) {
		$self->{_style} = lc($_[0]);
		$self->{style} = ( ($_[0] =~ /ipa/i) ) ? 1 : 0
	}

	$self->{_style};
}


sub grandularity
{
my $self = shift;

	$self->{_grandularity} = lc($_[0]) if (@_);

	$self->{_grandularity};
}



#########################################################
# Do not change this, Do not put anything below this.
# File must return "true" value at termination
1;
##########################################################

__END__



=head1 NAME

Text::Metaphone::Amharic - The Metaphone Algorithm for Amharic.

=head1 SYNOPSIS

  use utf8;
  require Text::Metaphone::Amharic;

  my $mphone = new Text::Metaphone::Amharic;

  my @keys  = $mphone->metaphone ( "ሥላሴ" );

  foreach (@keys) {
      print "$_\n";
  }

  my $key = $mphone->metaphone ( "ፀሐይ" );
  print "key => $key\n";

  $mphone->style ( "ipa" );

  @keys  = $mphone->metaphone ( "ሥላሴ" );

  foreach (@keys) {
      print "$_\n";
  }

  $mphone->style ( "ethiopic" );
    :
    :

  
  The key "style" and Metaphone "grandularity" can be set at import time:

    use Text::Metaphone::Amharic ( style => "ipa", grandularity => "high" );

  at instantiation time:

    my $mphone = new Text::Metaphone::Amharic ( style => "ipa", grandularity => "high" );

  or anytime there after:

    $mphone->style ( "ethiopic" );
    $mphone->grandularity ( "low" );

=head1 DESCRIPTION

The Text::Metaphone::Amharic module is a reimplementation of the Amharic
Metaphone algorithm of the L<Text::TransMetaphone> package.  This implementation
uses an object oriented interface and will generate keys in Ethiopic script by
default.  IPA keys remain available and may be set at instantiation or import time
or afterwards with the "style" method.

By default the keys are generated in "low" grandularity mode.  The grandularity
setting effects only how the keys for input method errors are generated.  In "high"
grandularity mode a key is returned for every possibly permutation, per key, in
the substitutions of upper for lower and lower for upper mistrikes.  In the default
"low" grandularity mode a single key representing the "lowest common denominator"
of the "high" mode keys is generated.

Like L<Text::TransMetaphone::am> the terminal key returned under list context is a
regular expression.  Amharic character classes will be applied in the RE key
as per the conventions of L<Regexp::Ethiopic::Amharic>.

A C<reverse_key_ipa> method is also provided to convert an IPA symbol key into  
a regular expression that would phonological sequence under Amharic orthography.

=head1 REQUIRES

L<Regexp::Ethiopic>.

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 BUGS

None presently known.

=head1 AUTHOR

Daniel Yacob,  L<dyacob@cpan.org|mailto:dyacob@cpan.org>

=head1 SEE ALSO

L<Text::TransMetaphone>

Included with this package:

  examples/amphone.pl         examples/ipa-phone.pl
  examples/amphone-high.pl    examples/ipa-phone-high.pl

=cut
