package Blog::Controller::Posts;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {

    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Posts in Posts.');
}

sub base :Chained('/') :PathPart('posts') :CaptureArgs(0) {

	my ($self, $c) = @_;

	$c->stash(resultset => $c->model('DB::Post'));

}

sub baseRec :Chained('base') :PathPart('id') :CaptureArgs(1) {

	my ($self, $c, $id) = @_;


	$c->stash(resultset => $c->model('DB::Post'),
				post => $c->stash->{resultset}->find($id)
		);

}	

sub list :Local {
    
    my ( $self, $c ) = @_;
	
	$c->stash(posts =>  [$c->model('DB::Post')->all]);

	$c->stash(template => 'posts/list.tt');
}

sub show :Chained('baseRec') :PathPart('show') :Args(0) {

    my ($self, $c) = @_;
    my $postid = $c->stash->{post}->id;
    my @comments = $c->model( 'DB::Comment' )->search(  { post_id => $postid } );
    
    $c->stash(template => 'posts/show.tt',
    		comments => [@comments]
    	);
}

sub addcomment :Chained('baseRec') :PathPart('addcomment') :Args(0) {
    my ($self, $c) = @_;
    my $postid = $c->stash->{post}->id;

	my $body = $c->request->params->{body} || 'N/A';

	my $comment = $c->model('DB::Comment')->create({
	body => $body,
	user_id =>  $c->user->get("id"),
	post_id =>  $postid
	});

    my @comments = $c->model( 'DB::Comment' )->search( { post_id => $postid } );

    $c->stash(template => 'posts/show.tt',
    		comments => [@comments]
    	);
}

sub deletecomment :Chained('baseRec') :PathPart('deletecomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

	my $comment = $c->model('DB::Comment')->find($commentid);
    $comment->delete;
   	my @comments = $c->model( 'DB::Comment' )->search( { post_id => $c->stash->{post}->id } );

   	$c->stash(	template => 'posts/show.tt',
   				comments => [@comments]);

}
sub editcomment :Chained('baseRec') :PathPart('editcomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

	my $comment = $c->model('DB::Comment')->find($commentid);

   	$c->stash(template => 'posts/editcomment.tt',
   			  comment  => $comment );

}

sub updatecomment :Chained('baseRec') :PathPart('updatecomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

	my $comment = $c->model('DB::Comment')->find($commentid);

	my $body = $c->request->params->{body} || 'N/A';

	$comment->update({ body => $body });
	
	my @comments = $c->model( 'DB::Comment' )->search( { post_id => $c->stash->{post}->id } );

	$c->stash(	template => 'posts/show.tt',
				comments => [@comments]);

}   

sub delete :Chained('baseRec') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{post}->delete;

    $c->stash->{status_msg} = "post deleted.";

    $c->forward('list');
}

sub edit :Chained('baseRec') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'posts/edit.tt');
  
}

sub form_new :Chained('base') :PathPart('new') :Args(0) {
	my ($self, $c) = @_;
	$c->stash(template => 'posts/create.tt');
}

sub form_create_do :Chained('base') :PathPart('save') :Args(0) {
	my ($self, $c) = @_;
	 my $title = $c->request->params->{title} || 'N/A';
	 my $body = $c->request->params->{body} || 'N/A';

	my $post = $c->model('DB::Post')->create({
	title => $title,
	body => $body,
	user_id =>  $c->user->get("id")
	});
	
	$c->stash(post => $post,
	template => 'posts/show.tt');
	
}

sub form_update :Chained('baseRec') :PathPart('update') :Args(0) {
	my ($self, $c) = @_;

	my $title = $c->request->params->{title} || 'N/A';
	my $body = $c->request->params->{body} || 'N/A';

	$c->stash->{post}->update({
	title => $title,
	body => $body
	});

	$c->stash(	template => 'posts/show.tt');

}


__PACKAGE__->meta->make_immutable;

1;
