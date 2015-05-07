package Blog::Controller::Users;
use Moose;
use namespace::autoclean;
use Digest::MD5 qw(md5_hex);

BEGIN { extends 'Catalyst::Controller'; }


sub login :Local {
     my ($self, $c) = @_;

    my $email = $c->request->params->{email};
    my $password = $c->request->params->{password};


    if ($email && $password) {

        if ($c->authenticate({ email => $email, password => md5_hex($password)  } )) {
           
            $c->response->redirect($c->uri_for(
                $c->controller('posts')->action_for('list')));
            return;
        } else {
            
        }
    } else {
        
    }

    $c->stash(template => 'users/login.tt');

}

sub logout :Local {
    my ($self, $c) = @_;
    $c->logout;
    $c->response->redirect($c->uri_for('/'));
}



sub base :Chained('/') :PathPart('users') :CaptureArgs(0) {
	my ($self, $c) = @_;
	$c->stash(resultset => $c->model('DB::User'));

}

sub baseRec :Chained('base') :PathPart('id') :CaptureArgs(1) {
	my ($self, $c, $id) = @_;

	$c->stash(resultset => $c->model('DB::User'),
				user => $c->stash->{resultset}->find($id)
		);

}	

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Users in Users.');
}

sub list :Local {
    my ( $self, $c ) = @_;
	$c->stash(users =>  [$c->model('DB::User')->all]);
	$c->stash(template => 'users/list.tt');
}

sub form_new :Chained('base') :PathPart('new') :Args(0) {
	my ($self, $c) = @_;
	$c->stash(template => 'users/create.tt');
}

sub form_create_do :Chained('base') :PathPart('save') :Args(0) {
	my ($self, $c) = @_;

	my $email = $c->request->params->{email} || 'N/A';
	my $password= $c->request->params->{password} || 'N/A';



	my $user = $c->model('DB::User')->create({
	email => $email,
	password =>  md5_hex($password)
	});

	$c->stash(user => $user,
	template => 'users/show.tt');


}

sub show :Chained('baseRec') :PathPart('show') :Args(0) {
    my ($self, $c) = @_;
    $c->stash(template => 'users/show.tt');
}
    
sub delete :Chained('baseRec') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{user}->delete;

    $c->forward('list');
}

sub edit :Chained('baseRec') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;
    $c->stash(template => 'users/edit.tt');
}

sub form_update :Chained('baseRec') :PathPart('update') :Args(0) {

	my ($self, $c) = @_;

	my $email = $c->request->params->{email} || 'N/A';
	my $password= $c->request->params->{password} || 'N/A';	
	
	$c->stash->{user}->update({
	email => $email,
	password =>  md5_hex($password)
	});
	
	$c->stash(	template => 'users/show.tt');
}


__PACKAGE__->meta->make_immutable;

1;
