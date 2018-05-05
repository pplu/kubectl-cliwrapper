package Kubectl::CLIWrapper {
  use Moose;
  use JSON::MaybeXS;
  use IPC::Open3;
  use Kubectl::CLIWrapper::Result;

  has server => (is => 'ro', isa => 'Str');
  has username => (is => 'ro', isa => 'Str');
  has password => (is => 'ro', isa => 'Str');
  has token => (is => 'ro', isa => 'Str');
  has insecure_tls => (is => 'ro', isa => 'Bool', default => 0);
  has namespace => (is => 'ro', isa => 'Str', default => 'default');

  has kubectl => (is => 'ro', isa => 'Str', default => 'kubectl');

  has kube_options => (is => 'ro', isa => 'Str', lazy => 1, default => sub {
    my $self = shift;

    my %options = ();
    $options{ server } = $self->server if (defined $self->server);
    $options{ username } = $self->username if (defined $self->username);
    $options{ password } = $self->password if (defined $self->password);
    $options{ namespace } = $self->namespace;
    $options{ 'insecure-skip-tls-verify' } = 'true' if ($self->insecure_tls);

    return join ' ', map { "--$_=$options{ $_ }" } keys %options;
  });

  sub command_for {
    my ($self, $command) = @_;
    return join ' ', $self->kubectl, $self->kube_options, $command;
  }

  sub run {
    my ($self, $command) = @_;
    return $self->input($command);
  }

  sub json {
    my ($self, $command) = @_;

    $command .= ' -o=json';

    my $result = $self->run($command);
    my $struct = eval {
      JSON->new->decode($result->output);
    };
    if ($@) {
      return Kubectl::CLIWrapper::Result->new(
        rc => $result->rc,
        output => $result->output,
        success => 0
      );
    }

    return Kubectl::CLIWrapper::Result->new(
      rc => $result->rc,
      output => $result->output,
      json => $struct
    );
  }

  sub input {
    my ($self, $input, @params) = @_;

    my $final_command = $self->command_for(@params);

    my ($stdin, $stdout, $stderr);
    my $pid = open3($stdin, $stdout, $stderr, $final_command);
    print $stdin $input  if(defined $input);
    close $stdin;

    my $out = join '', <$stdout>;
    my $err = join '', <$stderr> if ($stderr);

    die "Unexpected contents in stderr $err" if ($err);

    waitpid( $pid, 0 );
    my $rc = $? >> 8;

    return Kubectl::CLIWrapper::Result->new(
      rc => $rc,
      output => $out,
    );
  }

}
1;
