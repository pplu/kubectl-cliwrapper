requires 'Moose';
requires 'JSON::MaybeXS';
requires 'IPC::Open3';

on 'test' => sub {
  requires 'Test::More';
};
