use strict;
use warnings;
use lib './lib/';
use Test::More tests => 6;
use Plack::Test;
use HTTP::Request::Common;
use Weather;

my $test     = Plack::Test->create( Weather->to_app );
my $response = $test->request( GET '/' );

ok( $response->is_success, '[GET /] Successful request' );
like( $response->content, qr/"response":/, '[GET /] Correct content' );

$response = $test->request( GET '/?url=http://www.google.com/' );
like( $response->content, qr/"error":/, '[GET /?url=http://www.google.com] Correct error content' );

$response = $test->request( GET '/?url=http://www.bom.gov.au/invaliddirname/IDN60801/IDN60801.95765.json' );
is( $response->content, '{"error":"404 Not Found"}', '[GET /?url=http://www.bom.gov.au/invaliddirname/IDN60801/IDN60801.95765.json] Correct error content' );

$response = `curl -s http://weather.johnhorner.info`;
like( $response, qr/"response":/, 'curl request to HTTP URL' );

# TODO: there's an issue with the certificate so we need to run with the -k switch, which is insecure
$response = `curl -k -s https://weather.johnhorner.info`;
like( $response, qr/"response":/, 'curl request to HTTPS URL' );

done_testing();
