requires 'perl', '5.014';
requires 'Moo';
requires 'Types::Standard';
requires 'JSON::MaybeXS';
requires 'IPC::Open3';

on 'test' => sub {
  requires 'Test::More';
};

