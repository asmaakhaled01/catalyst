package Blog::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');


sub auto : Private {
    my ($self, $c) = @_;
    $c->log->debug($c->request->path);

    if ($c->request->path eq "users/login" || $c->request->path eq "users/new" || $c->request->path eq "users/save" ) {
    
        return 1;
    }


    if (!$c->user_exists) {
       
        $c->response->redirect($c->uri_for('/users/login'));

        return 0;
    }

    return 1;
}





sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect($c->uri_for('/posts/list'));

}



sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}



sub end : ActionClass('RenderView') {}



__PACKAGE__->meta->make_immutable;

1;
