package Net::MundiPagg;

use Moo;
use XML::Compile::SOAP11;
use XML::Compile::WSDL11;
use XML::Compile::Transport::SOAPHTTP;

use File::ShareDir qw{ module_file };

has 'client' => (
    is      => 'ro',
    builder => sub {
        my $wsdl = module_file( ref $_[0], 'mundipagg.wsdl' );
        my $client = XML::Compile::WSDL11->new($wsdl);

        foreach my $i ( 0 .. 2 ) {
            my $xsd = module_file( ref $_[0], "schema$i.xsd" );
            $client->importDefinitions($xsd);
        }

        $client->compileCalls;

        return $client;
    },
);

sub BUILD {
    my ($self) = @_;

    no strict 'refs';    ## no critic(TestingAndDebugging::ProhibitNoStrict)
    foreach my $method ( map { $_->name } $self->client->operations ) {
        *{$method} = sub {
            my ( $this, %args ) = @_;
            return $this->client->call( $method, %args );
        };
    }

    return;
}

1;

#ABSTRACT: Net::MundiPagg - Documentation coming soon :)

=method BUILD

Private method
