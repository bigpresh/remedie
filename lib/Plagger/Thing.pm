package Plagger::Thing;
use strict;
use base qw( Class::Accessor::Fast );

use Plagger::Text;
use Scalar::Util qw(blessed);

sub has_tag {
    my($self, $want_tag) = @_;
    for my $tag (@{$self->tags}) {
        return 1 if $tag eq $want_tag;
    }
    return 0;
}

sub add_tag {
    my($self, $tag) = @_;
    push @{$self->tags}, $tag
        unless $self->has_tag($tag);
}

sub clone {
    my $self = shift;
    my $clone = Storable::dclone($self);
    $clone;
}

sub mk_date_accessors {
    my $class = shift;

    for my $key (@_) {
        no strict 'refs';
        *{"$class\::$key"} = sub {
            my $obj = shift;
            if (@_) {
                my $date = $_[0];
                unless (ref($date)) {
                    $date = Plagger::Date->parse_dwim($date);
                }
                $obj->{$key} = $date;
            } else {
                return $obj->{$key};
            }
        };
    }
}

sub mk_text_accessors {
    my $class = shift;
    for my $key (@_) {
        no strict 'refs';
        *{"$class\::$key"} = sub {
            my $obj = shift;
            if (@_) {
                my $text = $_[0];
                unless ( blessed($text) && $text->isa('Plagger::Text') ) {
                    $text = Plagger::Text->new_from_text($text);
                }
                $obj->{$key} = $text;
            } else {
                return $obj->{$key};
            }
        };
    }
}

sub thumbnail {
    my $self = shift;
    if (@_) {
        my $image = shift;
        if (blessed($image) && $image->isa('URI')) {
            $image = { url => $image };
        }
        $self->{thumbnail} = $image;
    }

    $self->{thumbnail};
}

1;
