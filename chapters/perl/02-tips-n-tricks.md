# Perl tips & Tricks

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

## Manipulate STDIN/OUT streams from sub processes

With an easy-enough permutation of params in native perl `open` function you can
manipulate from **EITHER** (_important_) `STDIN` or `STDOUT` in child processes.

The notation is:

```perl
my $pid = open(my $file_handle, CHILD_PIPE_EXPR, qw(command to run))
# ... your code ...
close($file_handle);
waitpid($pid, 0);

# CHILD_PIPE_EXPR : { STDOUT_READ | STDIN_WRITE }
# STDOUT_READ : '-|' # Reads as: Read the output of command into $file_handle
# STDIN_WRITE : '|-' # Reads as: Write the output from perl into the command
```

### Manipulate STDOUT (`-|` _dash-pipe_)

```perl
# Dash-pipe => read stdout from subprocess
my $pid = open(my $git_output_fh, "-|", qw(git config --get user.name)) or die "Could not fork: $!";
# Read from the file handle
my $content = <$git_output_fh>;
# or: slurp all contents
{
    local $/ = undef;
    my $content = <$git_output_fh>;
}
# Remember to close your open files
close($git_output_fh) || die "close failed: $!";
# OPT: you may want to trim that very last newline in the output
chomp($content);
# Wait for the process to finish
waitpid($pid, 0);
```

### Manipulate STDIN (`-|` _pipe-dash_)

```perl
my $pid = open(my $stdin_fh, "|-", qw(cat -)) or die "Could not fork: $!";

# Write to it directly
say $stdin_fh "data from perl";

# Remember to close your open files
close($stdin_fh) || die "close failed: $!";
# Wait for the process to finish
waitpid($pid, 0);
```

### Bonus: Manipulate STDIN, STDOUT, STDERR

`IPC::Open3` is _available enough_ to be used:

```perl
use Symbol;

my $pid = open3(my $stdin_fh, my $chld_out, my $chld_err = Symbol::gensym(),
                qw(command to be run));

# reap zombie and retrieve exit status
waitpid($pid, 0);
my $child_exit_status = $? >> 8;
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
