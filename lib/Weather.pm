package Weather;
use Dancer2;
our $VERSION = '0.1';
use LWP::UserAgent;
use HTTP::CookieJar::LWP;
use Data::GUID;
# both cookies and a desktop browser user-agent string are need to get
# past Akamai scraper-detection tests
my $jar = HTTP::CookieJar::LWP->new;
my $ua = LWP::UserAgent->new( cookie_jar => $jar );
$ua->agent(
'5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36'
);
get '/' => sub {
    content_type 'text/json';
    my $url = 'http://www.bom.gov.au/fwo/IDN60801/IDN60801.95765.json';

    # in the dev environment, we can test by feeding another URL

    if ( config->{environment} eq 'development' && param('url') ) {
        $url = param('url');
    }
    my $result = $ua->get($url);
    if ( $result->is_success() ) {

        # a success would be a 200
        my $content;
        eval { $content = decode_json( $result->content() ) };

        # we may successfully get content but it may not be JSON
        if ($@) {
            status 503;
            return encode_json( { error => 'Unable to decode as JSON' } );
        }
        my @observations;
        foreach ( @{ $content->{observations}->{data} } ) {
            if ( $_->{apparent_t} > 20 ) {
                my $guid = Data::GUID->new();
                push(
                    @observations,
                    {
                        temperature => $_->{apparent_t},
                        station     => $_->{name},
                        latitude    => $_->{lat},
                        longitude   => $_->{lon},
                        datetime    => $_->{local_date_time_full},
                        guid        => $guid->as_string(),
                    }

                );
            }
        }
        @observations =
          sort( { $a->{temperature} <=> $b->{temperature} } @observations );
        return encode_json( { response => \@observations } );
    } else {

        # a non-200 response like 4xx or 5xx of some kind
        status 503;
        return encode_json( { error => $result->status_line() } );
    }
};

true;

