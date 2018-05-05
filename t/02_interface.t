#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Kube::Control;

{
  my $control = Kube::Control->new(namespace => 'ns1');
  my $command = $control->command_for('create pod');
  diag $command;
  cmp_ok($command, 'eq', 'kubectl --namespace=ns1 create pod');
}

{
  my $control = Kube::Control->new(
    namespace => 'ns1',
    server => 'https://server1.example.com',
    username => 'u1',
    password => 'p1',
  );
  my $command = $control->command_for('create pod');
  diag $command;
  like($command, qr/--username=u1/);
  like($command, qr/--password=p1/);
  like($command, qr|--server=https://server1.example.com|);
}

{
  my $ok = Kube::Control->new(
    kubectl => 't/fake_kubectl/ok',
    namespace => 'x',
  );
  my $r1 = $ok->run('stub');
  cmp_ok($r1->success, '==', 1);
  cmp_ok($r1->output, 'eq', '');
  ok(not(defined $r1->json));
  my $r2 = $ok->input('stub', 'stub');
  cmp_ok($r2->success, '==', 1);
  cmp_ok($r2->output, 'eq', '');
  ok(not(defined $r2->json));
}

{
  my $error = Kube::Control->new(
    kubectl => 't/fake_kubectl/error',
    namespace => 'x',
  );
  my $r1 = $error->run('stub');
  cmp_ok($r1->success, '==', 0);
  cmp_ok($r1->output, 'eq', '');
  ok(not(defined $r1->json));
  my $r2 = $error->input('stub', 'stub');
  cmp_ok($r2->success, '==', 0);
  cmp_ok($r2->output, 'eq', '');
  ok(not(defined $r2->json));
}

{
  my $json = Kube::Control->new(
    kubectl => 't/fake_kubectl/ok_with_result',
    namespace => 'x',
  );
  my $r1 = $json->run('stub');
  cmp_ok($r1->success, '==', 1);
  ok(not(defined $r1->json));
  like($r1->output, qr/apiVersion/);

  my $r2 = $json->input('stub', 'stub');
  cmp_ok($r2->success, '==', 1);
  ok(not(defined $r2->json));
  like($r2->output, qr/apiVersion/);

  my $r3 = $json->json_command('stub');
  cmp_ok($r3->success, '==', 1);
  ok(ref($r3->json) eq 'HASH');
  cmp_ok($r3->json->{ apiVersion }, 'eq', 'v1');
  ok(ref($r3->json->{ items }) eq 'ARRAY');
  like($r2->output, qr/apiVersion/);
}

done_testing;
