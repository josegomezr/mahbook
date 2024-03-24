## Perl contexts

--------- -------- -----------------------------------------
 Context   Symbol  Meaning
--------- -------- -----------------------------------------
 Scalar    `$`      _"direct"_ values.      

 List      `@`      A collection of values. 
                    _**Heads-up:** `undef` is not counted as
                    a value._ 

 Hash      `%`      An even-sized collection of items. 
                    Odd elements will be keys, even elements
                    will be values.
                    _Same restrictions as list context._ 
--------- -------- -----------------------------------------


## Perl Class Template

```perl
# lib/My/BaseClass.pm
package My::BaseClass;

use strict;
use warnings;
use utf8;
use v5.26;

sub new {
    my $class = shift;
    my $self = bless((@_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}), ref $class || $class);

    return $self;
}

1;
```

### Usage

#### Extending the base class

```perl
# lib/My/ConcreteClass.pm
package My::ConcreteClass;
use strict;
use warnings;
use utf8;
use v5.26;

use parent 'My::BaseClass';

sub method {
	my ($self) = @_;
	return "value";
}

1;
```
#### Using the class

```perl
use strict;
use warnings;
use utf8;
use v5.26;

use My::ConcreteClass;

$obj = My::ConcreteClass->new();
say $obj->method(); # prints "value"
```

## Handy-dandy lines

### Item in an array

```perl
# @items
# $needle

# as a filter: List context
my @found = grep { $_ eq $needle } @items; 

# in a conditional: Scalar context
if (grep { $_ eq $needle } @items) {
	# ...
}
```
