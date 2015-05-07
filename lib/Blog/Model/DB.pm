package Blog::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Blog::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:catalyst',
        user => 'root',
        password => 'root',
        AutoCommit => q{1},
    }
);

1;
